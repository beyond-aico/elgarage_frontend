import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/car_model.dart';

class CarService {
  final String baseUrl = 'http://192.168.8.15/api/v1'; 
  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async => await _storage.read(key: 'accessToken');

 // ... داخل CarService

  Future<List<Car>> getMyCars() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/cars'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final dynamic decodedBody = json.decode(response.body);
      
      // 🔥 سطر الطباعة المهم جداً: هيورينا شكل الداتا في التيرمنال
      print("📦 RAW CARS DATA: $decodedBody"); 

      List<dynamic> data;
      if (decodedBody is Map<String, dynamic> && decodedBody.containsKey('data')) {
        data = decodedBody['data'];
      } else if (decodedBody is List) {
        data = decodedBody;
      } else {
        return [];
      }
      return data.map((json) => Car.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load cars');
    }
  }
  // ... (باقي الدوال القديمة زي ما هي)

  // ... داخل CarService

  Future<List<dynamic>> getMaintenanceDue(String carId) async {
    final token = await _getToken();
    final url = '$baseUrl/maintenance/$carId/due';
    print("🚀 Fetching Due Maintenance from: $url");

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      print("📡 Maintenance Status: ${response.statusCode}");
      print("📦 RAW MAINTENANCE DATA: ${response.body}");

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        
        // المتغير اللي هنخزن فيه القائمة النهائية
        List<dynamic> itemsList = [];

        // 1. فحص الهيكل العام للرد
        if (body is Map && body.containsKey('data')) {
          final dataContent = body['data'];

          // ✅ التعديل الجوهري هنا:
          // الهيكل الجديد: data عبارة عن Map جواها مفتاح اسمه items
          if (dataContent is Map && dataContent.containsKey('items')) {
             itemsList = dataContent['items'];
             
             // ملاحظة: لو حابب توصل لمعلومة الـ nextServiceAt ممكن تطبعها هنا
             // print("Next Service at: ${dataContent['nextServiceAt']}");
          } 
          // الهيكل القديم (احتياطي): data عبارة عن List مباشرة
          else if (dataContent is List) {
             itemsList = dataContent;
          }
        } 
        // حالة نادرة: الرد عبارة عن List مباشرة بدون data wrapper
        else if (body is List) {
          itemsList = body;
        }

        return itemsList;
      }
    } catch (e) {
      print("❌ Error fetching maintenance: $e");
    }
    return [];
  }
  // 2. Get Brands (التعديل: استخدام المسار العام cars/brands)
  Future<List<dynamic>> getBrands() async {
    final token = await _getToken();
    // المسار الصحيح للمستخدمين (مش Admin)
    final url = '$baseUrl/cars/brands'; 
    print("🚀 Fetching Brands from: $url");

    try {
      final response = await http.get(
        Uri.parse(url), 
        headers: {'Authorization': 'Bearer $token'},
      );

      print("📡 Brands Status: ${response.statusCode}");
      print("📦 Brands Body: ${response.body}");

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body is Map && body.containsKey('data')) {
          return body['data']; 
        } else if (body is List) {
          return body;
        }
      }
    } catch (e) {
      print("❌ Error fetching brands: $e");
    }
    return [];
  }

  // 3. Get Models (التعديل: استخدام المسار العام cars/models)
  Future<List<dynamic>> getModels(String brandId) async {
    final token = await _getToken();
    // المسار الصحيح للموديلات
    final url = '$baseUrl/cars/models/$brandId';
    print("🚀 Fetching Models from: $url");

    try {
      final response = await http.get(
        Uri.parse(url), 
        headers: {'Authorization': 'Bearer $token'},
      );

      print("📡 Models Status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body is Map && body.containsKey('data')) {
          return body['data']; 
        } else if (body is List) {
          return body;
        }
      }
    } catch (e) {
      print("❌ Error fetching models: $e");
    }
    return [];
  }

  // 4. Add Car
  Future<void> addCar(Map<String, dynamic> carData) async {
    final token = await _getToken();
    
final payload = {
      // لازم المفاتيح دي تكون مطابقة للي كتبناه في الباك إند
      "carModelId": carData['modelId'], // لاحظ: هنا بنبعت modelId بس الباك إند بيستقبله كـ carModelId
      "year": carData['year'],
      "color": carData['color'],
      "currentKm": carData['currentKm'], 
      "plateNumber": "No Plate" // قيمة افتراضية لو مش موجودة
    };

    final response = await http.post(
      Uri.parse('$baseUrl/cars'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to add car: ${response.body}');
    }
  }
}