import 'package:flutter/material.dart'; // تم تغيير cupertino إلى material لدعم ChangeNotifier بشكل أفضل
import 'package:flutter/cupertino.dart';
// استيراد الموديلات بناءً على شجرة الملفات
import '../data/models/car_model.dart';
import '../data/models/maintenance_item_model.dart';
import '../data/models/product_model.dart';
import '../data/models/service_log_model.dart';
import '../data/models/emergency_model.dart';
import '../data/services/car_service.dart';

class AppProvider with ChangeNotifier {
  final CarService _carService = CarService();
  
  // ==========================================================
  // --- 1. CAR SECTION (Backend Integrated) ---
  // ==========================================================
  List<Car> _myCars = [];
  bool _isLoadingCars = false;
  String? _carError;
  Car? _selectedCar; 

  List<Car> get myCars => _myCars;
  bool get isLoadingCars => _isLoadingCars;
  String? get carError => _carError;
  Car? get selectedCar => _selectedCar;

  // Fleet Logic
  List<Car> get fleetCars => _myCars;
  Car? get assignedDriverCar => _selectedCar; // للسواق

  // إحصائيات وهمية للأدمن (Analytics)
  Map<String, dynamic> get fleetAnalytics => {
    "total_units": _myCars.length,
    "active_now": (_myCars.length * 0.8).floor(),
    "maintenance_due": _myCars.where((c) => (c.currentKm % 10000) > 9000).length,
    "monthly_cost": "45,000 EGP",
    "efficiency": "94%"
  };

  void setSelectedCar(Car car) {
    _selectedCar = car;
    _dueMaintenance = []; // تصفير الصيانة القديمة
    notifyListeners();
  }

  // دعم المسمى القديم لتجنب الأخطاء في الواجهات
  void selectCar(Car car) => setSelectedCar(car);

  // تم إصلاح الخطأ هنا: تعريف متغير التحميل كخاصية في الكلاس وليس متغير محلي
  bool _isUpdatingMileage = false;
  bool get isUpdatingMileage => _isUpdatingMileage;

  Future<bool> updateDriverMileage(String carId, int newMileage) async {
    _isUpdatingMileage = true; // تغيير الحالة العامة للتحميل
    notifyListeners();
    try {
      // تفعيل مناداة الـ API (تأكد من وجود الدالة في car_service)
      await _carService.updateMileage(carId, newMileage);
      
      // تحديث البيانات محلياً بعد نجاح العملية
      await fetchMyCars(); 
      
      return true;
    } catch (e) {
      print("Error updating mileage: $e");
      return false;
    } finally {
      _isUpdatingMileage = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyCars() async {
    _isLoadingCars = true;
    _carError = null;
    notifyListeners();
    try {
      _myCars = await _carService.getMyCars();
      if (_myCars.isNotEmpty && _selectedCar == null) {
        _selectedCar = _myCars.first;
      }
    } catch (e) {
      _carError = e.toString();
    } finally {
      _isLoadingCars = false;
      notifyListeners();
    }
  }

  // ==========================================================
  // --- 2. MAINTENANCE LOGIC (Matrix & Intelligent Check) ---
  // ==========================================================
  List<MaintenanceItem> _dueMaintenance = [];
  bool _isLoadingMaintenance = false;
  List<MaintenanceItem> get dueMaintenance => _dueMaintenance;
  bool get isLoadingMaintenance => _isLoadingMaintenance;

  // مصفوفة الصيانة (Maintenance Matrix)
  final Map<int, List<String>> _maintenanceMatrix = {
    10000: ['Engine Oil', 'Oil Filter'],
    20000: ['Engine Oil', 'Oil Filter', 'Air Filter', 'Pollen Filter', 'Spark Plugs'],
    30000: ['Engine Oil', 'Oil Filter', 'Coolant Water'],
    40000: ['Engine Oil', 'Oil Filter', 'Air Filter', 'Pollen Filter', 'Spark Plugs', 'Fuel Filter', 'Gearbox Oil'],
    50000: ['Engine Oil', 'Oil Filter', 'Gearbox Oil'],
    60000: ['Engine Oil', 'Oil Filter', 'Air Filter', 'Spark Plugs', 'Drive Belt (Kit)'],
  };

  // جلب الصيانات من الباك إند
  Future<void> fetchDueMaintenance({required String carId}) async {
    if (_selectedCar == null && _myCars.isNotEmpty) {
       _selectedCar = _myCars.firstWhere((element) => element.id == carId, orElse: () => _myCars.first);
    }
    _isLoadingMaintenance = true;
    notifyListeners();
    try {
      final rawData = await _carService.getMaintenanceDue(carId);
      _dueMaintenance = rawData.map((item) => MaintenanceItem.fromJson(item)).toList();
    } catch (e) {
      print("Error loading maintenance: $e");
    } finally {
      _isLoadingMaintenance = false;
      notifyListeners();
    }
  }

  // حساب الكيلومتر القادم (Milestone)
  int get currentMilestone {
    if (_selectedCar == null) return 10000;
    int km = _selectedCar!.currentKm;
    return ((km / 10000).floor() + 1) * 10000;
  }

  // الفحص الذكي للتاريخ (Intelligent History Check)
  bool wasPartReplacedAtMilestone(String partName, int milestoneKm) {
    const int margin = 2000; 
    String cleanPartName = partName.replaceAll('(Clean)', '').trim().toLowerCase();
    return _historyLogs.any((log) {
       bool isWithinRange = log.mileage >= (milestoneKm - margin) && log.mileage <= (milestoneKm + margin);
       if (!isWithinRange) return false;
       return log.partsReplaced.any((p) => p.toLowerCase().contains(cleanPartName));
    });
  }

  // توليد عناصر الصيانة بناءً على التاريخ والمصفوفة
  List<ProductModel> getMaintenanceItemsFor(int milestone) {
    List<String> requiredParts = _maintenanceMatrix[milestone] ?? ['Engine Oil', 'Oil Filter'];
    return requiredParts.map((part) {
      bool missed = false;
      if (milestone < currentMilestone) {
        missed = !wasPartReplacedAtMilestone(part, milestone);
      }
      return ProductModel(
        id: '${milestone}_$part',
        name: part,
        price: _getPriceForPart(part),
        category: 'Maintenance',
        isMissed: missed,
      );
    }).toList();
  }

  double _getPriceForPart(String name) {
    name = name.toLowerCase();
    if (name.contains('oil') && !name.contains('filter')) return 1200; 
    if (name.contains('filter')) return 350;
    if (name.contains('spark')) return 800;
    if (name.contains('belt')) return 2500;
    return 500;
  }

  // ==========================================================
  // --- 3. HISTORY, CART, EMERGENCY & MARKET (Local State) ---
  // ==========================================================
  
  final List<ServiceLogModel> _historyLogs = []; 
  List<ServiceLogModel> get historyLogs => _historyLogs;

  void addServiceLog(dynamic logData) {
    if (logData is Map) {
      _historyLogs.insert(0, ServiceLogModel(
        id: DateTime.now().toString(),
        serviceName: logData['name'],
        date: logData['date'],
        mileage: logData['mileage'],
        partsReplaced: List<String>.from(logData['parts']),
      ));
    }
    notifyListeners();
  }

  final List<ProductModel> _cartItems = [];
  List<ProductModel> get cartItems => _cartItems;
  double get cartTotal => _cartItems.fold(0, (sum, item) => sum + item.price);

  void addToCart(List<dynamic> products) {
    for (var p in products) { if (p is ProductModel) _cartItems.add(p); }
    notifyListeners();
  }

  void removeFromCart(dynamic item) {
    _cartItems.remove(item);
    notifyListeners();
  }

  final List<EmergencyModel> _emergencyContacts = [
    EmergencyModel(name: 'Al-Inqaz Towing', phoneNumber: '0100000001', location: 'Nasr City', type: 'Winch', rating: '4.9'),
    EmergencyModel(name: 'Battery Doctors', phoneNumber: '0110000000', location: 'Giza', type: 'Battery', rating: '4.5'),
  ];

  List<EmergencyModel> getEmergencyByType(String type) {
    return _emergencyContacts.where((element) => element.type == type).toList();
  }

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': CupertinoIcons.square_grid_2x2_fill},
    {'name': 'Service Centers', 'icon': CupertinoIcons.wrench_fill},
    {'name': 'Oils', 'icon': CupertinoIcons.drop_fill},
  ];
  List<Map<String, dynamic>> get categories => _categories;

  final List<ProductModel> _marketProducts = [
    ProductModel(id: '201', name: 'Shell Helix Ultra', price: 950, category: 'Oils'),
    ProductModel(id: '202', name: 'Michelin Tire 16"', price: 4500, category: 'Tires'),
  ];
  List<ProductModel> get marketProducts => _marketProducts;

  final List<Map<String, dynamic>> _serviceCenters = [
    {'name': 'Auto Fix Center', 'location': 'Nasr City', 'labor_cost': 200.0},
    {'name': 'Pro Car Service', 'location': 'New Cairo', 'labor_cost': 300.0},
  ];
  List<Map<String, dynamic>> get serviceCenters => _serviceCenters;

  // ==========================================================
  // --- 4. HELPERS (Dropdowns & Navigation) ---
  // ==========================================================
  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;
  void setTabIndex(int index) { _currentTabIndex = index; notifyListeners(); }

  Future<List<dynamic>> fetchBrands() async => await _carService.getBrands();
  Future<List<dynamic>> fetchModels(String brandId) async => await _carService.getModels(brandId);
  
  Future<bool> addNewCarv2(Map<String, dynamic> carData) async {
    try {
      await _carService.addCar(carData);
      await fetchMyCars();
      return true;
    } catch (e) { return false; }
  }
}