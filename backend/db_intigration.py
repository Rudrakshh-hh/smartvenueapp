"""
SmartVenue auth backend: Flask REST API on top of an Oracle database.

The Flutter app cannot talk to Oracle directly, so it calls these endpoints:

    POST /api/register   {"name": "...", "identifier": "<email or student id>", "password": "..."}
    POST /api/login      {"identifier": "<email or student id>", "password": "..."}
    GET  /api/health

Configuration comes from environment variables (never hard-code DB passwords):

    ORACLE_USER      e.g. smartvenue
    ORACLE_PASSWORD  (required)
    ORACLE_DSN       e.g. localhost:1521/XEPDB1   (host:port/service_name)
    API_PORT         default 5000

Run:
    pip install -r requirements.txt
    python db_intigration.py
"""

import os
import re

import oracledb
from flask import Flask, jsonify, request
from werkzeug.security import check_password_hash, generate_password_hash

# ---------------------------------------------------------------------------
# Database connection
# ---------------------------------------------------------------------------

ORACLE_USER = os.environ.get("ORACLE_USER", "smartvenue")
ORACLE_PASSWORD = os.environ.get("ORACLE_PASSWORD")
ORACLE_DSN = os.environ.get("ORACLE_DSN", "localhost:1521/XEPDB1")

EMAIL_RE = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")
STUDENT_ID_RE = re.compile(r"^[A-Za-z0-9-]{4,20}$")
MIN_PASSWORD_LEN = 6

_pool = None


def get_pool():
    """Create the connection pool once and reuse it for every request."""
    global _pool
    if _pool is None:
        if not ORACLE_PASSWORD:
            raise RuntimeError("Set the ORACLE_PASSWORD environment variable.")
        # Thin mode: pure Python, no Oracle Instant Client needed.
        _pool = oracledb.create_pool(
            user=ORACLE_USER,
            password=ORACLE_PASSWORD,
            dsn=ORACLE_DSN,
            min=1,
            max=5,
            increment=1,
        )
    return _pool


def init_schema():
    """Create the USERS table if it does not exist yet (Oracle 12c+)."""
    ddl = """
        CREATE TABLE users (
            user_id        NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
            full_name      VARCHAR2(100)  NOT NULL,
            email          VARCHAR2(255)  UNIQUE,
            student_id     VARCHAR2(20)   UNIQUE,
            password_hash  VARCHAR2(255)  NOT NULL,
            created_at     TIMESTAMP      DEFAULT SYSTIMESTAMP NOT NULL,
            CONSTRAINT users_has_identifier
                CHECK (email IS NOT NULL OR student_id IS NOT NULL)
        )
    """
    with get_pool().acquire() as conn:
        with conn.cursor() as cur:
            try:
                cur.execute(ddl)
            except oracledb.DatabaseError as e:
                (error,) = e.args
                if error.code != 955:  # ORA-00955: name is already used
                    raise


# ---------------------------------------------------------------------------
# Auth logic
# ---------------------------------------------------------------------------


def parse_identifier(identifier):
    """
    Decide whether the user typed an email or a student ID.
    Returns (column_name, normalized_value) or (None, None) if invalid.
    """
    identifier = (identifier or "").strip()
    if "@" in identifier:
        if EMAIL_RE.match(identifier):
            return "email", identifier.lower()
    elif STUDENT_ID_RE.match(identifier):
        return "student_id", identifier.upper()
    return None, None


def register_user(name, identifier, password):
    """Returns (ok, message, user_dict_or_None)."""
    name = (name or "").strip()
    column, value = parse_identifier(identifier)

    if not name:
        return False, "Name is required.", None
    if column is None:
        return False, "Enter a valid email or student ID.", None
    if len(password or "") < MIN_PASSWORD_LEN:
        return False, f"Password must be at least {MIN_PASSWORD_LEN} characters.", None

    password_hash = generate_password_hash(password)

    # `column` comes from parse_identifier (only "email" or "student_id"),
    # never from user input, so formatting it into the SQL is safe.
    sql = f"""
        INSERT INTO users (full_name, {column}, password_hash)
        VALUES (:name, :value, :pw)
        RETURNING user_id INTO :new_id
    """
    with get_pool().acquire() as conn:
        with conn.cursor() as cur:
            new_id = cur.var(oracledb.NUMBER)
            try:
                cur.execute(sql, name=name, value=value, pw=password_hash, new_id=new_id)
            except oracledb.IntegrityError:
                return False, "An account with this email / student ID already exists.", None
        conn.commit()

    user = {"id": int(new_id.getvalue()[0]), "name": name, column: value}
    return True, "Registration successful.", user


def login_user(identifier, password):
    """Returns (ok, message, user_dict_or_None)."""
    column, value = parse_identifier(identifier)
    if column is None or not password:
        return False, "Invalid credentials.", None

    sql = f"""
        SELECT user_id, full_name, email, student_id, password_hash
        FROM users
        WHERE {column} = :value
    """
    with get_pool().acquire() as conn:
        with conn.cursor() as cur:
            cur.execute(sql, value=value)
            row = cur.fetchone()

    # Same message for "no such user" and "wrong password" so attackers
    # can't probe which emails / IDs are registered.
    if row is None or not check_password_hash(row[4], password):
        return False, "Invalid credentials.", None

    user = {"id": row[0], "name": row[1], "email": row[2], "student_id": row[3]}
    return True, "Login successful.", user


# ---------------------------------------------------------------------------
# HTTP API
# ---------------------------------------------------------------------------

app = Flask(__name__)


@app.after_request
def add_cors_headers(response):
    # Needed when the Flutter app runs in a browser (flutter run -d chrome).
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Allow-Headers"] = "Content-Type"
    response.headers["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS"
    return response


@app.get("/api/health")
def health():
    try:
        with get_pool().acquire() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT 1 FROM dual")
        return jsonify(status="ok", database="connected")
    except Exception as e:
        return jsonify(status="error", database=str(e)), 503


@app.route("/api/register", methods=["POST", "OPTIONS"])
def register():
    if request.method == "OPTIONS":
        return "", 204
    data = request.get_json(silent=True) or {}
    ok, message, user = register_user(
        data.get("name"), data.get("identifier"), data.get("password")
    )
    status = 201 if ok else (409 if "already exists" in message else 400)
    return jsonify(success=ok, message=message, user=user), status


@app.route("/api/login", methods=["POST", "OPTIONS"])
def login():
    if request.method == "OPTIONS":
        return "", 204
    data = request.get_json(silent=True) or {}
    ok, message, user = login_user(data.get("identifier"), data.get("password"))
    return jsonify(success=ok, message=message, user=user), (200 if ok else 401)


if __name__ == "__main__":
    init_schema()
    # 0.0.0.0 so a phone / emulator on the same network can reach it.
    app.run(host="0.0.0.0", port=int(os.environ.get("API_PORT", 5000)), debug=True)
