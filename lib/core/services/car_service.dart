// --- FILE: lib/core/services/car_service.dart ---

import 'dart:convert';
import 'package:elgarage/core/constants/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/car_model.dart';
import 'package:flutter/foundation.dart';

class CarService {
  final String baseUrl = AppConfig.baseUrl; 
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      sharedPreferencesName: 'ElGarage_Secure_Final',
    ),
  );

  // جلب التوكن من التخزين الآمن
  Future<String?> _getToken() async => await _storage.read(key: 'accessToken');

  void _checkUnauthorized(http.Response response) {
    if (response.statusCode == 401) {
      debugPrint("🚫 Unauthorized! Token expired or invalid.");
      throw Exception('UNAUTHORIZED'); 
    }
  }

  // إعداد الهيدر الموحد للطلبات
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // ✅ الدالة الموحدة والوحيدة لجلب السيارات (تلقائياً للمانجر والسائق)
  // تم إلغاء getFleetCars لأنها كانت تسبب خطأ 404
  Future<List<Car>> getMyCars() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cars'),
        headers: await _getHeaders(),
      );

      _checkUnauthorized(response);

      if (response.statusCode == 200) {
        final dynamic decodedBody = json.decode(response.body);
        final List<dynamic> data = decodedBody is Map ? (decodedBody['data'] ?? []) : decodedBody;
        return data.map((json) => Car.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("❌ CarService getMyCars Error: $e");
      if (e.toString().contains('UNAUTHORIZED')) rethrow;
      return [];
    }
  }

  // 1. جلب الماركات (Brands)
  Future<List<dynamic>> getBrands() async {
    final url = '$baseUrl/admin/brands'; 
    try {
      final response = await http.get(Uri.parse(url), headers: await _getHeaders());
      _checkUnauthorized(response);
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return body['data'] ?? body; 
      }
    } catch (e) {
      debugPrint("❌ Error fetching brands: $e");
    }
    return [];
  }

  // 2. جلب الموديلات (Models)
  Future<List<dynamic>> getModels(String brandId) async {
    final url = '$baseUrl/admin/brands/models?brandId=$brandId';
    try {
      final response = await http.get(Uri.parse(url), headers: await _getHeaders());
      _checkUnauthorized(response);
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return body['data'] ?? body;
      }
    } catch (e) {
      debugPrint("❌ Error fetching models: $e");
    }
    return [];
  }

  // 3. إضافة سيارة جديدة
  Future<void> addCar(Map<String, dynamic> carData) async {
    final payload = {
      "modelId": carData['modelId'],
      "year": carData['year'],
      "color": carData['color'],
      "mileageKm": carData['mileageKm'], 
      "plateNumber": carData['plateNumber'] ?? "No Plate"
    };

    final response = await http.post(
      Uri.parse('$baseUrl/cars'),
      headers: await _getHeaders(),
      body: jsonEncode(payload),
    );
    
    _checkUnauthorized(response);
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to add car: ${response.body}');
    }
  }

  // 4. جلب الصيانات المستحقة
  Future<List<dynamic>> getDueMaintenance(String carId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/maintenance/status/$carId'), 
        headers: await _getHeaders(),
      );
      
      _checkUnauthorized(response);

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body is Map && body['data'] is List) {
          return body['data'];
        }
      }
    } catch (e) {
      debugPrint("❌ Maintenance Status API Error: $e");
    }
    return [];
  }

  // 5. تحديث عداد السيارة
  Future<bool> updateCarMileage(String carId, int mileageKm) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/cars/$carId'),
        headers: await _getHeaders(),
        body: json.encode({'mileageKm': mileageKm}),
      );
      
      _checkUnauthorized(response);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("❌ Update Mileage API Error: $e");
      return false;
    }
  }

  // 6. جلب سجل الصيانة
  Future<List<dynamic>> getServiceHistory(String carId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/maintenance/history/$carId'),
        headers: await _getHeaders(),
      );
      _checkUnauthorized(response);
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return body is Map ? (body['data'] ?? []) : body;
      }
    } catch (e) {
      debugPrint("❌ History API Error: $e");
    }
    return [];
  }

  // 7. حذف سيارة
  Future<bool> deleteCar(String carId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/cars/$carId'),
        headers: await _getHeaders(),
      );
      _checkUnauthorized(response);
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint("❌ Delete Car Error: $e");
      return false;
    }
  }
}