import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // ✅ استخدام نفس إعدادات التخزين لضمان تزامن التوكن
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      sharedPreferencesName: 'ElGarage_Secure_Final',
    ),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  final String baseUrl = "https://elgaragebackend-production.up.railway.app/api/v1"; 

  Future<Map<String, String>> _getAuthHeaders() async {
    String? token = await _storage.read(key: 'accessToken');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ✅ تحديث: دعم الفلترة الزمنية للداشبورد (Start & End Date)
  Future<Map<String, dynamic>> getFleetDashboard({String? startDate, String? endDate}) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final uri = Uri.parse('$baseUrl/admin/reports/fleet/dashboard')
        .replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: await _getAuthHeaders(),
    );
    
    return response.statusCode == 200 ? jsonDecode(response.body)['data'] : {};
  }

  // ✅ تحديث: دعم الفلترة الزمنية لتحليلات المركبات
  Future<List<dynamic>> getVehiclesAnalytics({String? startDate, String? endDate}) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final uri = Uri.parse('$baseUrl/fleet/analytics/vehicles')
        .replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
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

  // حفظ التوكن في التخزين الآمن فوراً عند دخول السائق بالباركود
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