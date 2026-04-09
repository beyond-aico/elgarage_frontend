import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // ✅ تعديل: استخدام نفس إعدادات التخزين الموجودة في AuthProvider لضمان قراءة نفس البيانات
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      sharedPreferencesName: 'ElGarage_Secure_Final',
    ),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // ✅ نستخدم AppConfig.baseUrl أو نتأكد من المسار الصحيح
  final String baseUrl = "https://elgaragebackend-production.up.railway.app/api/v1"; 

  Future<Map<String, String>> _getAuthHeaders() async {
    // ✅ تصحيح: المفتاح هو accessToken وليس jwt_token
    String? token = await _storage.read(key: 'accessToken');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getFleetDashboard() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/reports/fleet/dashboard'),
      headers: await _getAuthHeaders(),
    );
    return response.statusCode == 200 ? jsonDecode(response.body)['data'] : {};
  }

  // ✅ جلب تحليلات العربيات (للجداول والرسومات)
  Future<List<dynamic>> getVehiclesAnalytics() async {
    final response = await http.get(
      Uri.parse('$baseUrl/fleet/analytics/vehicles'),
      headers: await _getAuthHeaders(),
    );
    return response.statusCode == 200 ? jsonDecode(response.body)['data'] : [];
  }
  // التحقق من الباركود (للسائق)
  Future<Map<String, dynamic>> verifyBarcode(String barcode) async {
    final response = await http.post(
      Uri.parse('$baseUrl/fleet/auth-barcode'),
      headers: await _getAuthHeaders(),
      body: jsonEncode({'barcode': barcode}),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    throw Exception('Invalid Barcode');
  }

// ✅ التعديل: حفظ التوكن في التخزين الآمن فوراً
  Future<Map<String, dynamic>> verifyBarcodeWithPassword(String barcode, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/fleet/auth-barcode'),
      headers: {'Content-Type': 'application/json'}, 
      body: jsonEncode({
        'barcode': barcode,
        'password': password,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final data = responseData['data'];

      // 🔐 حفظ التوكن الجديد عشان السواق يفضل مسجل دخول
      if (data['accessToken'] != null) {
        await _storage.write(key: 'accessToken', value: data['accessToken']);
        debugPrint("🔐 Token Saved from Barcode Login!");
      }
      return data; 
    }
    throw Exception('Invalid Barcode or Password');
  }

  // تسجيل وقود وتحديث عداد (للسائق)
  Future<void> addFuelLog(Map<String, dynamic> logData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/fleet/logs'),
      headers: await _getAuthHeaders(),
      body: jsonEncode(logData),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add fuel log');
    }
  }
}