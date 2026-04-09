import 'package:elgarage/core/services/api_service.dart';
import 'package:elgarage/providers/app_provider.dart';
import 'package:flutter/material.dart';
import '../core/models/car_model.dart';
import '../core/models/fleet_analytics_model.dart'; 

class FleetProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool _isLoadingStats = false; 
  
  String? _error;
  Car? _authenticatedCar; 
  FleetAnalytics? _fleetStats;

  bool get isLoading => _isLoading;
  bool get isLoadingStats => _isLoadingStats;
  String? get error => _error;
  Car? get authenticatedCar => _authenticatedCar;
  FleetAnalytics? get fleetStats => _fleetStats;

  Future<bool> verifyVehicle(String barcode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.verifyBarcode(barcode);
      _authenticatedCar = Car.fromJson(data);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = "Barcode Error: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

 // ✅ الدالة المعدلة في lib/providers/fleet_provider.dart
Future<void> loadFleetStats(List<Car> allCars) async {
  _isLoadingStats = true;
  notifyListeners();
  try {
    // 1. جلب ملخص الأرقام الكبيرة
    final summary = await _apiService.getFleetDashboard();
    final List<dynamic> breakdownsFromApi = await _apiService.getVehiclesAnalytics();
    final List<Map<String, dynamic>> finalBreakdown = allCars.map((car) {
      final apiData = breakdownsFromApi.firstWhere(
        (element) => element['carId'] == car.id,
        orElse: () => {}, // لو ملهاش داتا نرجع Map فاضية
      );

      // بناء هيكل البيانات الموحد لكل عربية
      return {
        "carId": car.id,
        "plateNumber": car.licensePlate ?? "---",
        "brand": car.make,
        "model": car.model,
        // لو مفيش داتا من السيرفر بنحط 0
        "totalFuelCost": apiData['totalFuelCost'] ?? 0,
        "totalLiters": apiData['totalLiters'] ?? 0,
        "lastOdometer": car.mileageKm, // نستخدم العداد الحقيقي الموجود في الـ Provider
      };
    }).toList();

    // 4. دمج الملخص مع القائمة الكاملة (الـ 29 عربية)
    final Map<String, dynamic> combinedData = Map<String, dynamic>.from(summary);
    combinedData['vehicleBreakdown'] = finalBreakdown;

    _fleetStats = FleetAnalytics.fromJson(combinedData);
    
    // تم حذف الـ ! واستخدام ?? لضمان عدم حدوث خطأ لو القائمة فارغة
    debugPrint("🚀 Analytics Loaded: ${_fleetStats?.vehicleBreakdown.length ?? 0} vehicles mapped.");
    
  } catch (e) {
    debugPrint("❌ Analytics Error: $e");
  } finally {
    _isLoadingStats = false;
    notifyListeners();
  }
}


Future<bool> linkDriverToVehicle(String barcode, String password) async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  // ✅ ضيف السطرين دول عشان نشوف الداتا اللي رايحة للسيرفر في اللوج
  debugPrint("🚀 DEBUG: Sending Barcode: '$barcode'");
  debugPrint("🚀 DEBUG: Sending Password: '$password'");

  try {
    final data = await _apiService.verifyBarcodeWithPassword(barcode, password);
    _authenticatedCar = Car.fromJson(data);
    _isLoading = false;
    notifyListeners();
    return true;
  } catch (e) {
    // هنا السيرفر رد بـ Error
    debugPrint("❌ DEBUG: Server Error: $e");
    _error = "بيانات غير صحيحة، تأكد من الكود وكلمة المرور";
    _isLoading = false;
    notifyListeners();
    return false;
  }
}
  
void setAuthenticatedCar(Car? car) {
  _authenticatedCar = car;
  _error = null;
  notifyListeners();
}

// داخل fleet_provider.dart

  Future<bool> submitFuelLog({
    required int newOdometer,
    required double liters,
    required double cost,
    required String fuelType,
    required AppProvider appProvider, // ✅ أضفنا الـ AppProvider هنا
  }) async {
    if (_authenticatedCar == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint("DEBUG_FLEET: Submitting Fuel for Car: ${_authenticatedCar!.id}");
      
      await _apiService.addFuelLog({
        "carId": _authenticatedCar!.id,
        "odometerKms": newOdometer,
        "fuelType": fuelType,
        "liters": liters,
        "totalCost": cost,
      });

      // ✅ التحديث السحري: نحدث العداد في الـ AppProvider والـ FleetProvider معاً
      await appProvider.updateCarCurrentKm(newOdometer); 
      _authenticatedCar = _authenticatedCar!.copyWith(mileageKm: newOdometer);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint("DEBUG_FLEET: Error submitting fuel: $e");
      return false;
    }
  }
  
  void resetOnLogout() {
    _authenticatedCar = null;
    _fleetStats = null;
    _error = null;
    _isLoading = false;
    _isLoadingStats = false;
    notifyListeners();
  }
}