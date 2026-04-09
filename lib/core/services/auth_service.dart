import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_config.dart'; 
import '../models/auth_response_model.dart';

class AuthService {
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

  // ✅ تعديل: استقبال identifier (إيميل أو هاتف)
  Future<AuthResponse> login(String identifier, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': identifier, // نرسله تحت مفتاح email ليتوافق مع الـ API الحالي
        'password': password,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }
  // داخل كلاس AuthService
Future<void> changePassword(String currentPassword, String newPassword, String token) async {
  final response = await http.post(
    Uri.parse('$baseUrl/change-password'), // تأكد من وجود هذا المسار في الباك إند
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'oldPassword': currentPassword,
      'newPassword': newPassword,
    }),
  );
  if (response.statusCode != 200 && response.statusCode != 201) {
    throw Exception('Failed to change password');
  }
}

Future<void> requestEmailVerification(String token) async {
  await http.post(
    Uri.parse('$baseUrl/send-email-otp'), // مسار إرسال كود الإيميل
    headers: {'Authorization': 'Bearer $token'},
  );
}
}