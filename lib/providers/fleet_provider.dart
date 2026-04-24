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

  DateTime? _startDate;
DateTime? _endDate;

DateTime? get startDate => _startDate;
DateTime? get endDate => _endDate;

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

 Future<void> loadFleetStats(List<Car> allCars, {DateTime? start, DateTime? end}) async {
  _startDate = start;
  _endDate = end;
  _isLoadingStats = true;
  notifyListeners();

  try {
    // 1. تحويل التواريخ لنصوص بصيغة (YYYY-MM-DD) المتوقعة في الباك إند
    String? startStr = start?.toIso8601String().split('T')[0];
    String? endStr = end?.toIso8601String().split('T')[0];

    // 2. جلب البيانات مع تمرير فلاتر التاريخ للـ API
    final summary = await _apiService.getFleetDashboard(
      startDate: startStr, 
      endDate: endStr
    );
    final List<dynamic> breakdownsFromApi = await _apiService.getVehiclesAnalytics(
      startDate: startStr, 
      endDate: endStr
    );

    final List<Map<String, dynamic>> finalBreakdown = allCars.map((car) {
      final apiData = breakdownsFromApi.firstWhere(
        (element) => element['carId'] == car.id,
        orElse: () => {},
      );

      return {
        "carId": car.id,
        "plateNumber": car.licensePlate ?? "---",
        "brand": car.make,
        "model": car.model,
        "totalFuelCost": apiData['totalFuelCost'] ?? 0,
        "totalLiters": apiData['totalLiters'] ?? 0,
        "lastOdometer": car.mileageKm,
        // ملاحظة: الباك إند سيقوم بحساب التكاليف بناءً على الفلتر الزمني الممرر
      };
    }).toList();

    // 3. دمج البيانات وتحويلها للموديل
    final Map<String, dynamic> combinedData = Map<String, dynamic>.from(summary);
    combinedData['vehicleBreakdown'] = finalBreakdown;

    _fleetStats = FleetAnalytics.fromJson(combinedData);
    
    debugPrint("🚀 Analytics Loaded for period: $startStr to $endStr");
    
  } catch (e) {
    debugPrint("❌ Analytics Error: $e");
  } finally {
    _isLoadingStats = false;
    notifyListeners();
  }
}
Future<bool> linkDriverToVehicle(String barcode, AppProvider appProvider) async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    // 1. طلب الـ ID من الباك إند عن طريق الباركود
    final response = await _apiService.verifyBarcode(barcode);
    
    // تأمين القراءة (لو الرد مضغوط جوه data أو جاي مباشر)
    final Map<String, dynamic>? carData = (response['data'] ?? response);

    if (carData == null || carData['id'] == null) {
      throw Exception("بيانات الباركود غير صحيحة");
    }

    String scannedCarId = carData['id'];

    // 2. البحث عن السيارة في القائمة الأصلية اللي فيها العداد (Mileage) والبيانات كاملة
    // إحنا بنستخدم القائمة اللي حملها AppProvider وقت تسجيل الدخول
    Car? fullCar;
    try {
      fullCar = appProvider.myCars.firstWhere((c) => c.id == scannedCarId);
    } catch (e) {
      // لو السواق ملوش صلاحية يشوف العربية دي في القائمة العامة
      // هنضطر نستخدم البيانات اللي جاية من الـ API ونعالج المسميات يدوياً
      fullCar = Car(
        id: carData['id'],
        licensePlate: carData['plateNumber'] ?? carData['licensePlate'],
        make: carData['brand'] ?? carData['make'] ?? "Unknown",
        model: carData['model'] ?? "Unknown",
        year: carData['year'] ?? 0,
        mileageKm: carData['mileageKm'] ?? 0,
      );
    }

    _authenticatedCar = fullCar;
    
    _isLoading = false;
    notifyListeners();
    return true;
  } catch (e) {
    debugPrint("❌ Fleet API Error: $e");
    _error = "هذه السيارة لا تنتمي لمؤسستك أو الكود غير صحيح";
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

Future<bool> submitFuelLog({
  required int newOdometer,
  required double liters,
  required double cost,
  required String fuelType,
  required AppProvider appProvider,
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

    // ✅ التعديل: نمرر 'this' لضمان تحديث إحصائيات الأسطول محلياً فوراً
    await appProvider.updateCarCurrentKm(newOdometer, fleetProvider: this); 
    
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

void updateVehicleMileageLocally(String carId, int newKm) {
  if (_fleetStats == null) return;
  // البحث عن العربية جوه قائمة التحليلات
  final index = _fleetStats!.vehicleBreakdown.indexWhere((v) => v.carId == carId);

  if (index != -1) {
    final oldData = _fleetStats!.vehicleBreakdown[index];
    
    // حساب الـ remaining الجديد بناءً على نفس الحسبة  اللي في الموديل
    int newRemaining = 10000 - (newKm % 10000); 

    // تحديث العنصر في القائمة
    _fleetStats!.vehicleBreakdown[index] = VehicleAnalytic(
      carId: oldData.carId,
      plateNumber: oldData.plateNumber,
      brand: oldData.brand,
      model: oldData.model,
      totalCost: oldData.totalCost,
      fuelLiters: oldData.fuelLiters,
      kms: newKm, // العداد الجديد
      remainingKms: newRemaining, // المتبقي الجديد للصيانة
      nextMaintenanceCost: oldData.nextMaintenanceCost,
    );

    notifyListeners(); // إخطار الواجهة بالتحديث فوراً
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