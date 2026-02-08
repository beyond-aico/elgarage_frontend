import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_config.dart'; // ✅ استيراد الإعدادات
import '../models/auth_response_model.dart';

class AuthService {
  // ✅ استخدام الرابط المركزي
  final String baseUrl = AppConfig.auth;

  Future<AuthResponse> register(String name, String email, String phone, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  Future<AuthResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }
}