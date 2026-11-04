
require("dotenv").config();
const mysql = require("mysql2/promise");
const bcrypt = require("bcrypt");

async function main() {
  const db = await mysql.createConnection({
    host: process.env.DB_HOST,
    port: Number(process.env.DB_PORT || 3306),
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
  });

  const name = "Test Student";
  const email = "student@example.com";
  const password = "CampusTest123!";
  const hash = await bcrypt.hash(password, 12);

  await db.execute(
    `INSERT INTO users (name, email, password, role)
     VALUES (?, ?, ?, ?)`,
    [name, email, hash, "student"]
  );

  console.log("Test user created successfully.");
  console.log("Email:", email);
  console.log("Test password:", password);

  await db.end();
}

main().catch((err) => {
  console.error("Could not create test user:", err.message);
  process.exitCode = 1;
});
