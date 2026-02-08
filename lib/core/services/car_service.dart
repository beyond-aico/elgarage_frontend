// --- FILE: lib/core/services/car_service.dart ---

import 'dart:convert';
import 'package:elgarage/core/constants/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/car_model.dart';
import 'package:flutter/foundation.dart';

class CarService {
  final String baseUrl = AppConfig.baseUrl; 
  final _storage = const FlutterSecureStorage();

  // جلب التوكن من التخزين الآمن
  Future<String?> _getToken() async => await _storage.read(key: 'accessToken');

  // إعداد الهيدر الموحد للطلبات
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // 1. جلب سيارات الأسطول (للمديرين)
  Future<List<Car>> getFleetCars() async {
    final response = await http.get(
      Uri.parse('$baseUrl/cars/fleet'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final dynamic decodedBody = json.decode(response.body);
      final List<dynamic> data = decodedBody is Map ? (decodedBody['data'] ?? []) : decodedBody;
      return data.map((json) => Car.fromJson(json)).toList();
    }
    return [];
  }

  // 2. جلب سيارات المستخدم الشخصية
  Future<List<Car>> getMyCars() async {
    final response = await http.get(
      Uri.parse('$baseUrl/cars'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final dynamic decodedBody = json.decode(response.body);
      // التعامل مع الـ Wrapper الذي يضيفه NestJS
      final List<dynamic> data = decodedBody is Map ? (decodedBody['data'] ?? []) : decodedBody;
      
      debugPrint("📦 Cars loaded successfully, count: ${data.length}");
      return data.map((json) => Car.fromJson(json)).toList();
    }
    return [];
  }

  // 3. تحديث عداد الكيلومترات (خاص بالسائق)
  Future<Map<String, dynamic>?> updateMileage(String carId, int mileage) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/cars/$carId/mileage'),
      headers: await _getHeaders(),
      body: jsonEncode({'mileage': mileage}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return null;
  }

  // في ملف car_service.dart، حدث الدوال التالية:

// 1. جلب الماركات (Brands)
Future<List<dynamic>> getBrands() async {
  final url = '$baseUrl/admin/brands'; // المسار الجديد
  try {
    final response = await http.get(Uri.parse(url), headers: await _getHeaders());
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      // NestJS بيلف الداتا في حقل data بسبب الـ Interceptor
      return body['data'] ?? body; 
    }
  } catch (e) {
    debugPrint("❌ Error fetching brands: $e");
  }
  return [];
}

// 2. جلب الموديلات (Models)
Future<List<dynamic>> getModels(String brandId) async {
  // استخدام الـ Query Parameter كما حددنا في الباك إند (?brandId=)
  final url = '$baseUrl/admin/brands/models?brandId=$brandId';
  try {
    final response = await http.get(Uri.parse(url), headers: await _getHeaders());
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return body['data'] ?? body;
    }
  } catch (e) {
    debugPrint("❌ Error fetching models: $e");
  }
  return [];
}

 // --- FILE: lib/core/services/car_service.dart ---

Future<void> addCar(Map<String, dynamic> carData) async {
  
  // تجهيز البيانات بالمفتاح الذي يتوقعه DTO الباك إند على الأرجح
  final payload = {
    "modelId": carData['modelId'],
    "year": carData['year'],
    "color": carData['color'],
    "mileageKm": carData['currentKm'], // ✅ تغيير من mileage إلى mileageKm
    "plateNumber": carData['plateNumber'] ?? "No Plate"
  };

  debugPrint("🚀 Final Add Car Attempt Payload: ${jsonEncode(payload)}");

  final response = await http.post(
    Uri.parse('$baseUrl/cars'),
    headers: await _getHeaders(), // استخدام الهيدر الموحد لضمان التوكن
    body: jsonEncode(payload),
  );

  if (response.statusCode != 201 && response.statusCode != 200) {
    debugPrint("❌ Backend Still Rejecting: ${response.body}");
    throw Exception('Failed to add car: ${response.body}');
  }
}

// --- FILE: lib/core/services/car_service.dart ---

Future<List<dynamic>> getMaintenanceDue(String carId) async {
  // ✅ تعديل المسار ليطابق اللوج: /api/v1/maintenance/status/:carId
  final url = '$baseUrl/maintenance/status/$carId'; 
  
  try {
    final response = await http.get(Uri.parse(url), headers: await _getHeaders());

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      // NestJS بيلف الداتا في حقل data
      final dataContent = body is Map ? body['data'] : body;
      
      // السيرفر غالباً يرجع قائمة بقطع الغيار وحالتها (Status)
      return dataContent is List ? dataContent : (dataContent['items'] ?? []);
    }
  } catch (e) {
    debugPrint("❌ Maintenance System Error: $e");
  }
  return [];
}

  // 8. حذف سيارة
  Future<bool> deleteCar(String carId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/cars/$carId'),
        headers: await _getHeaders(),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint("❌ Delete Car Error: $e");
      return false;
    }
  }
}