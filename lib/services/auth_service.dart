
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  // Android emulator. Change this for a physical phone or web.
  static const String baseUrl = 'http://192.168.29.7:3000';

  static const _storage = FlutterSecureStorage();

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http
        .post(
      Uri.parse('$baseUrl/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email.trim(),
        'password': password,
      }),
    )
        .timeout(const Duration(seconds: 15));

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Login failed.');
    }

    final token = data['token'] as String?;
    if (token == null || token.isEmpty) {
      throw Exception('The server did not return a token.');
    }

    await _storage.write(key: 'auth_token', value: token);
    return data;
  }

  static Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }

  static Future<String> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http
        .post(
      Uri.parse('$baseUrl/api/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
      }),
    )
        .timeout(const Duration(seconds: 15));

    final Map<String, dynamic> data;

    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('The server returned an invalid response.');
    }

    if (response.statusCode != 201 || data['success'] != true) {
      throw Exception(
        data['message'] ?? 'Registration failed.',
      );
    }

    return data['message'] as String? ??
        'Account created successfully.';
  }

}
