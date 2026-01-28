import 'package:flutter/material.dart';
import '../data/models/car_model.dart';
import '../data/services/car_service.dart';
import '../data/models/maintenance_item_model.dart';

class AppProvider with ChangeNotifier {
  final CarService _carService = CarService();
  
  // --- CARS SECTION ---
  List<Car> _myCars = [];
  bool _isLoadingCars = false;
  String? _carError;

  // ✅ 1. تعريف متغير حقيقي لتخزين العربية المختارة
  Car? _selectedCar; 

  List<Car> get myCars => _myCars;
  bool get isLoadingCars => _isLoadingCars;
  String? get carError => _carError;
  
  // ✅ 2. تعديل الـ Getter عشان يرجع المتغير الحقيقي
  Car? get selectedCar => _selectedCar;

  // --- MAINTENANCE SECTION ---
  List<MaintenanceItem> _dueMaintenance = [];
  bool _isLoadingMaintenance = false;

  List<MaintenanceItem> get dueMaintenance => _dueMaintenance;
  bool get isLoadingMaintenance => _isLoadingMaintenance;

  // --- FUNCTIONS ---

  // ✅ 3. دالة تحديد السيارة (أهم دالة كانت ناقصة)
  void setSelectedCar(Car car) {
    _selectedCar = car;
    _dueMaintenance = []; // تصفير الصيانة القديمة عشان ميبانش داتا غلط لحد ما الجديدة تحمل
    notifyListeners(); // تحديث الواجهة فوراً
  }

  // دالة جلب الصيانات المستحقة
  Future<void> fetchDueMaintenance({required String carId}) async {
    // لو مفيش عربية مختارة، نستخدم الـ ID اللي مبعوت في الدالة
    // ولو الـ ID مش مبعوت (نادر)، نرجع
    if (_selectedCar == null && _myCars.isNotEmpty) {
       // لو لسة مفيش اختيار، نختار العربية صاحبة الـ ID ده
       _selectedCar = _myCars.firstWhere((element) => element.id == carId, orElse: () => _myCars.first);
    }

    _isLoadingMaintenance = true;
    notifyListeners();

    try {
      // ✅ نستخدم carId المبعوت للدالة لضمان الدقة، بدلاً من الاعتماد على selectedCar فقط
      final rawData = await _carService.getMaintenanceDue(carId);
      
      _dueMaintenance = rawData.map((item) => MaintenanceItem.fromJson(item)).toList();
      
    } catch (e) {
      print("Error loading maintenance: $e");
    } finally {
      _isLoadingMaintenance = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyCars() async {
    _isLoadingCars = true;
    _carError = null;
    notifyListeners();

    try {
      _myCars = await _carService.getMyCars();
      // ✅ لو فيه عربيات واليوزر لسة مختارش، نختار أول واحدة افتراضياً
      if (_myCars.isNotEmpty && _selectedCar == null) {
        _selectedCar = _myCars.first;
      }
    } catch (e) {
      _carError = e.toString();
      print("Error fetching cars: $e");
    } finally {
      _isLoadingCars = false;
      notifyListeners();
    }
  }

  // --- DROPDOWNS HELPERS ---
  Future<List<dynamic>> fetchBrands() async {
    return await _carService.getBrands();
  }

  Future<List<dynamic>> fetchModels(String brandId) async {
    return await _carService.getModels(brandId);
  }

  Future<bool> addNewCarv2(Map<String, dynamic> carData) async {
    try {
      await _carService.addCar(carData);
      await fetchMyCars();
      return true;
    } catch (e) {
      print("Error adding car: $e");
      return false;
    }
  }

  // ==========================================================
  // --- REMAINING PLACEHOLDERS (Cart, etc.) ---
  // ==========================================================

  List<dynamic> get cartItems => []; 
  double get cartTotal => 0.0;
  List<dynamic> get serviceCenters => [];
  List<dynamic> get marketProducts => [];
  List<dynamic> get categories => []; 
  List<dynamic> get historyLogs => [];
  
  void addServiceLog(dynamic log) {}
  void removeFromCart(item) {}
  void addToCart(List<dynamic> list) {} 
  List<dynamic> getEmergencyByType(String type) => [];
  int get currentMilestone => 0;
  List<dynamic> getMaintenanceItemsFor(int mileage) => [];
}