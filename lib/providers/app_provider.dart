// --- FILE: lib/providers/app_provider.dart ---

import 'package:elgarage/core/services/car_service.dart';
import 'package:flutter/cupertino.dart';
// استيراد الموديلات بناءً على شجرة الملفات
import '../core/models/car_model.dart';
import '../core/models/maintenance_item_model.dart';
import '../core/models/product_model.dart';
import '../core/models/service_log_model.dart';
import '../core/models/emergency_model.dart';

class AppProvider with ChangeNotifier {
  final CarService _carService = CarService();
  
  // ==========================================================
  // --- 1. CAR SECTION (Backend Integrated with Role Logic) ---
  // ==========================================================
  List<Car> _myCars = [];
  bool _isLoadingCars = false;
  String? _carError;
  Car? _selectedCar; 

  List<Car> get myCars => _myCars;
  bool get isLoadingCars => _isLoadingCars;
  String? get carError => _carError;
  Car? get selectedCar => _selectedCar;

 // 1. إضافة متغيرات جديدة للبيانات الشخصية والمنظمة
  Map<String, dynamic>? _dashboardStats; 
  String? _organizationName;
  bool _isLoadingDashboard = false;
String? _customOrgName;
  String get organizationName => _organizationName ?? "Personal Garage";
  bool get isLoadingDashboard => _isLoadingDashboard;
Future<void> syncUserContext(dynamic user) async {
    if (user == null) return;
    
    // 1. سحب اسم الشركة من موديل اليوزر
    _organizationName = user.organizationName; 
    
    // 2. جلب العربيات فوراً بناءً على دور اليوزر (مدير أو سواق)
    await fetchMyCars(role: user.role);
    
    notifyListeners(); // تحديث الهيدر والداشبورد بالبيانات الجديدة
  }
  // 2. تحديث الـ Analytics لتكون ديناميكية 100%
 Map<String, dynamic> get fleetAnalytics {
    if (_myCars.isEmpty) {
      return {
        "total_units": 0, "active_now": 0, "maintenance_due": 0,
        "monthly_cost": "0 EGP", "efficiency": "0%"
      };
    }

    int total = _myCars.length;
    // بنحسب كام عربية محتاجة صيانة (اللي قربت من الـ 10000 كم)
    int due = _myCars.where((c) => (c.currentKm % 10000) > 9000).length;
    
    return {
      "total_units": total,
      "active_now": total, 
      "maintenance_due": due,
      "monthly_cost": "${total * 2500} EGP", 
      "efficiency": "${due == 0 ? 100 : (100 - (due / total * 100)).floor()}%"
    };
  }

// --- داخل AppProvider في ملف app_provider.dart ---

  void setSelectedCar(Car car) {
    _selectedCar = car;
    _dueMaintenance = []; // تصفير القائمة القديمة
    notifyListeners();
    
    // ✅ بمجرد اختيار سيارة، اطلب بيانات الصيانة الخاصة بها فوراً من SQL
    fetchDueMaintenance(carId: car.id);
  }

  Future<void> fetchDueMaintenance({required String carId}) async {
    _isLoadingMaintenance = true;
    notifyListeners();
    
    try {
      final List<dynamic> rawData = await _carService.getMaintenanceDue(carId);
      debugPrint("📡 SQL Maintenance Data Received: ${rawData.length} items");

      _dueMaintenance = rawData.map((json) {
        return MaintenanceItem(
          // استخدام serviceName لأن هذا ما يرسله الباك إند في اللوج الخاص بك
          id: json['serviceName'] ?? DateTime.now().toString(),
          name: json['serviceName'] ?? 'Unknown Part',
          category: json['category'] ?? 'General',
          // حساب السعر تقديرياً لو الباك إند مبعتوش (لأن اللوج مظهرش فيه سعر)
          price: (json['estimatedPrice'] ?? json['price'] ?? _getPriceForPart(json['serviceName'] ?? '')).toDouble(),
          status: json['status'] ?? 'OK', 
          isMissed: json['status'] == 'OVERDUE',
        );
      }).toList();

    } catch (e) {
      debugPrint("❌ Provider Mapping Error: $e");
    } finally {
      _isLoadingMaintenance = false;
      notifyListeners(); // تحديث الـ UI بعد جلب البيانات
    }
  }

  bool _isUpdatingMileage = false;
  bool get isUpdatingMileage => _isUpdatingMileage;


  Future<bool> updateDriverMileage(String carId, int newMileage) async {
    _isUpdatingMileage = true; 
    notifyListeners();
    try {
      await _carService.updateMileage(carId, newMileage);
      // تحديث البيانات محلياً بعد نجاح العملية في الباك إند
      await fetchMyCars(); 
      return true;
    } catch (e) {
debugPrint("Error updating mileage: $e"); // ✅ تم التعديل لـ debugPrint
      return false;
    } finally {
      _isUpdatingMileage = false;
      notifyListeners();
    }
  }
String getImageForPart(String partName) {
    String name = partName.toLowerCase();
    if (name.contains('oil')) return 'assets/images/engine_oil.png';
    if (name.contains('spark')) return 'assets/images/spark_plug.png';
    if (name.contains('brake')) return 'assets/images/brake_pad.png';
    return 'assets/images/engine_oil.png'; // صورة افتراضية
  }
 // داخل كلاس AppProvider في ملف app_provider.dart
// --- جلب السيارات من السيرفر ---
 // 4. تحديث دالة fetchMyCars لضمان اختيار أول سيارة كـ Selected تلقائياً
  Future<void> fetchMyCars({String? role}) async {
    _isLoadingCars = true;
    _carError = null;
    notifyListeners();

    try {
      List<Car> fetchedCars;
      if (role == 'ACCOUNT_MANAGER' || role == 'ADMIN') {
        fetchedCars = await _carService.getFleetCars();
      } else {
        fetchedCars = await _carService.getMyCars();
      }
      
      _myCars = fetchedCars;
      
      // تأكيد اختيار سيارة افتراضية للعرض في الهيدر والتفاصيل
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

  // --- في ملف lib/providers/app_provider.dart ---

// --- في ملف lib/providers/app_provider.dart ---

  // حساب الكيلومتر القادم (Milestone)
  int get currentMilestone {
    if (_selectedCar == null) return 10000;
    int km = _selectedCar!.currentKm.toInt(); // تحويل لـ int لضمان الحساب الصحيح
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
        imagePath: getImageForPart(part), // إضافة المسار هنا
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
  // داخل كلاس AppProvider في ملف app_provider.dart
// داخل كلاس AppProvider في ملف app_provider.dart

Future<bool> removeCar(String carId) async {
  try {
    await _carService.deleteCar(carId); // 1. الحذف من السيرفر
    
    // 2. التحديث المحلي فوراً
    _myCars.removeWhere((c) => c.id == carId); 
    if (_selectedCar?.id == carId) _selectedCar = null;
    
    notifyListeners(); // 3. إشعار الهوم بالترتيب الجديد
    return true;
  } catch (e) {
    debugPrint("❌ Delete Error: $e");
    return false;
  }
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

// في ملف app_provider.dart داخل كلاس AppProvider
final List<ProductModel> _marketProducts = [
  // --- قطع غيار (Spare Parts) ---
  ProductModel(
    id: 'p1', 
    name: 'Total Quartz 9000 5W-40 (4L)', 
    price: 1450, 
    category: 'Oils',
    imagePath: 'assets/images/1.jpg',
  ),
  ProductModel(
    id: 'p2', 
    name: 'Brembo Brake Pads Set (Front)', 
    price: 2800, 
    category: 'Brakes',
    imagePath: 'assets/images/2.png',
  ),
  ProductModel(
    id: 'p3', 
    name: 'NGK Iridium Spark Plugs (4pcs)', 
    price: 1100, 
    category: 'Engine',
    imagePath: 'assets/images/3.jfif',
  ),
  ProductModel(
    id: 'p4', 
    name: 'Bosch Premium Oil Filter', 
    price: 450, 
    category: 'Filters',
    imagePath: 'assets/images/1.jpg',
  ),
  
  // --- كماليات (Accessories) ---
  ProductModel(
    id: 'a1', 
    name: '70ai Dash Cam Pro Plus+', 
    price: 3200, 
    category: 'Electronics',
    imagePath: 'assets/images/2.png',
  ),
  ProductModel(
    id: 'a2', 
    name: 'Baseus Portable Air Pump', 
    price: 1950, 
    category: 'Accessories',
    imagePath: 'assets/images/2.png',
  ),
  ProductModel(
    id: 'a3', 
    name: 'Philips LED Headlight H7 Kit', 
    price: 1800, 
    category: 'Lighting',
    imagePath: 'assets/images/2.png',
  ),
  ProductModel(
    id: 'a4', 
    name: 'Premium Leather Seat Covers', 
    price: 5500, 
    category: 'Interior',
    imagePath: 'assets/images/2.png',
  ),
];

// ابحث عن تعريف _marketProducts في السطر 256 تقريباً وأضف تحته:
List<ProductModel> get marketProducts => _marketProducts; // هذا السطر سيحل خطأ marketplace_screen

  final List<Map<String, dynamic>> _serviceCenters = [
    {'name': 'Auto Fix Center', 'location': 'Nasr City', 'labor_cost': 200.0},
    {'name': 'Pro Car Service', 'location': 'New Cairo', 'labor_cost': 300.0},
  ];
  List<Map<String, dynamic>> get serviceCenters => _serviceCenters;

  // ==========================================================
  // --- 4. HELPERS (Dropdowns & Navigation) ---
  // ==========================================================
  // ==========================================================
  // --- 4. HELPERS (Dropdowns & Navigation) ---
  // ==========================================================
  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;
  
  void setTabIndex(int index) { 
    _currentTabIndex = index; 
    notifyListeners(); 
  }

  // جلب الماركات مع معالجة الخطأ
  Future<List<dynamic>> fetchBrands() async {
    try {
      return await _carService.getBrands();
    } catch (e) {
      debugPrint("❌ Provider Brands Error: $e");
      return [];
    }
  }

  // جلب الموديلات بناءً على الماركة المختارة
  Future<List<dynamic>> fetchModels(String brandId) async {
    try {
      return await _carService.getModels(brandId);
    } catch (e) {
      debugPrint("❌ Provider Models Error: $e");
      return [];
    }
  }

  // دالة إعادة ترتيب السيارات (للتنظيم المحلي)
  void reorderMyCars(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final Car item = _myCars.removeAt(oldIndex);
    _myCars.insert(newIndex, item);
    notifyListeners();
  }

  // دالة إضافة سيارة جديدة (النسخة النهائية المطابقة للباك إند)
  Future<bool> addNewCarv2(Map<String, dynamic> carData) async {
    try {
      // التأكد من إرسال currentKm كما يتوقعها السيرفر في Prisma
      final Map<String, dynamic> formattedData = {
        ...carData,
        'currentKm': carData['mileageKm'], 
      };

      await _carService.addCar(formattedData);
      
      // تحديث قائمة السيارات فوراً من السيرفر لظهورها في الهوم
      await fetchMyCars(); 
      return true;
    } catch (e) {
      debugPrint("❌ Add Car Flow Error: $e");
      return false;
    }
  }
}