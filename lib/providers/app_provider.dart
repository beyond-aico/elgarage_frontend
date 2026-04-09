import 'package:elgarage/core/models/auth_response_model.dart';
import 'package:elgarage/core/services/car_service.dart';
import 'package:elgarage/providers/auth_provider.dart';
import 'package:elgarage/providers/fleet_provider.dart';
import 'package:elgarage/providers/maintenance_provider.dart';
import 'package:flutter/cupertino.dart';
import '../core/models/car_model.dart';
import '../core/models/product_model.dart';
import '../core/models/emergency_model.dart';

class AppProvider with ChangeNotifier {
  final CarService _carService = CarService();

  // --- إدارة السيارات (البيانات الأساسية) ---
  List<Car> _myCars = [];
  Car? _selectedCar;
  bool _isLoadingCars = false;
  String? _carError;
  bool _isUpdatingMileage = false;

  List<Car> get myCars => _myCars;
  Car? get selectedCar => _selectedCar;
  bool get isLoadingCars => _isLoadingCars;
  String? get carError => _carError;
  bool get isUpdatingMileage => _isUpdatingMileage;

  // --- إدارة المتجر والطلبات ---
  final List<ProductModel> _cartItems = [];
  final List<Map<String, dynamic>> _myOrders = [];
  List<ProductModel> get cartItems => _cartItems;
  List<Map<String, dynamic>> get myOrders => _myOrders;
  double get cartTotal => _cartItems.fold(0, (sum, item) => sum + item.price);

  // --- بيانات المؤسسة والواجهة ---
  String? _organizationName;
  String get organizationName => _organizationName ?? "Personal Garage";
  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

// lib/providers/app_provider.dart

Future<void> syncUserContext(
    User? user, 
    AuthProvider auth, 
    FleetProvider fleet, 
    MaintenanceProvider maintenance
  ) async {
    if (user == null) return;
    _organizationName = user.organizationName;
    
    // جلب السيارات باستخدام الرابط العام (Token-based) لضمان عدم حدوث 404
    await fetchMyCars(
      authProvider: auth, 
      forceRefresh: true
    );

    // ربط السائق بسيارته وجلب جدول صيانته فوراً
    if (user.role.toUpperCase() == "DRIVER" && _myCars.isNotEmpty) {
      final driverCar = _myCars.firstWhere(
        (car) => car.userId == user.id, 
        orElse: () => _myCars.first
      );
      
      _selectedCar = driverCar; 
      fleet.setAuthenticatedCar(driverCar);
      
      // طلب تحديث الصيانة من السيرفر فور تسجيل الدخول
      await maintenance.fetchDueMaintenance(driverCar.id, driverCar.mileageKm);
      
      notifyListeners();
      debugPrint("DEBUG: [syncUserContext] ${user.name} fully synced with Maintenance.");
    }
  }

  // ✅ تعديل دالة تحليل الأسطول لتعكس البيانات الحية 100%
  Map<String, dynamic> get fleetAnalytics {
    if (_myCars.isEmpty) {
      return {
        "total_units": 0, 
        "active_now": 0,
        "maintenance_due": 0, 
        "efficiency": "0%"
      };
    }

    int total = _myCars.length;
    return {
      "total_units": total,
      "active_now": total, // تعتمد على العدد الفعلي الموجود في القائمة
      "maintenance_due": 0,
      "monthly_cost": "--- EGP",
      "efficiency": "100%",
    };
  }

  // ✅ دالة ترتيب السيارات
  void reorderMyCars(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _myCars.removeAt(oldIndex);
    _myCars.insert(newIndex, item);
    notifyListeners();
  }

  // ✅ قائمة مراكز الخدمة
  final List<Map<String, dynamic>> _serviceCenters = [
    {'name': 'Auto Fix Center', 'location': 'Nasr City', 'labor_cost': 200.0},
    {'name': 'Pro Car Service', 'location': 'New Cairo', 'labor_cost': 300.0},
  ];
  List<Map<String, dynamic>> get serviceCenters => _serviceCenters;

  // ✅ دالة الصور
  String getImageForPart(String partName) {
    String name = partName.toLowerCase();
    if (name.contains('oil')) return 'assets/images/engine_oil.png';
    if (name.contains('spark')) return 'assets/images/spark_plug.png';
    if (name.contains('brake')) return 'assets/images/brake_pad.png';
    return 'assets/images/engine_oil.png';
  }

 Future<void> fetchMyCars({
    String? role,
    String? orgId,
    AuthProvider? authProvider,
    bool forceRefresh = false,
  }) async {
    if (_isLoadingCars && !forceRefresh && _myCars.isNotEmpty) return;

    _isLoadingCars = true;
    _carError = null;
    notifyListeners();

    try {
      // ✅ الحل الجذري: نعتمد دائماً على getMyCars() لأن الباك إند يفلتر بالتوكن
      // تم إلغاء شرط ACCOUNT_MANAGER الذي كان يطلب getFleetCars بـ ID
      List<Car> fetchedCars = await _carService.getMyCars();

      _myCars = List<Car>.from(fetchedCars);
      
      // تحديد أول سيارة كسيارة مختارة افتراضياً إذا لم تكن هناك سيارة محددة
      if (_myCars.isNotEmpty && _selectedCar == null) {
        _selectedCar = _myCars.first;
      }
    } catch (e) {
      _carError = e.toString();
      debugPrint("DEBUG: [fetchMyCars] Error: $e");
    } finally {
      _isLoadingCars = false;
      notifyListeners();
    }
  }

  void setSelectedCar(Car car) {
    _selectedCar = car;
    notifyListeners();
  }

  Future<bool> addNewCarv2(Map<String, dynamic> carData) async {
    try {
      await _carService.addCar(carData);
      await fetchMyCars();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeCar(String carId) async {
    try {
      await _carService.deleteCar(carId);
      _myCars.removeWhere((c) => c.id == carId);
      if (_selectedCar?.id == carId) _selectedCar = null;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

 Future<bool> updateCarCurrentKm(int newKm) async {
    if (_selectedCar == null) return false;
    _isUpdatingMileage = true;
    notifyListeners();
    try {
      bool success = await _carService.updateCarMileage(
        _selectedCar!.id,
        newKm,
      );
      if (success) {
        _selectedCar = _selectedCar!.copyWith(mileageKm: newKm);
        // تحديث القيمة في القائمة الرئيسية أيضاً لضمان التزامن في كل الشاشات
        int index = _myCars.indexWhere((c) => c.id == _selectedCar!.id);
        if (index != -1) _myCars[index] = _selectedCar!;
        return true;
      }
      return false;
    } finally {
      _isUpdatingMileage = false;
      notifyListeners();
    }
  }

  // --- إدارة المتجر (Actions) ---
  void addToCart(List<dynamic> items) {
    for (var item in items) {
      if (item is ProductModel) {
        if (!_cartItems.any((e) => e.name == item.name)) {
          _cartItems.add(item);
        }
      }
    }
    notifyListeners();
  }

  void removeFromCart(dynamic item) {
    _cartItems.remove(item);
    notifyListeners();
  }

  void placeOrder() {
    if (_cartItems.isEmpty) return;
    _myOrders.insert(0, {
      'id': 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      'date': DateTime.now(),
      'items': List.from(_cartItems),
      'total': cartTotal,
      'status': 'Pending',
    });
    _cartItems.clear();
    notifyListeners();
  }

  // --- بيانات ثابتة (Market & Emergency) ---
  final List<ProductModel> _marketProducts = [
    ProductModel(
      id: 'p1',
      name: 'Total Quartz 9000 5W-40',
      price: 1450,
      category: 'Oils',
      imagePath: 'assets/images/1.jpg',
    ),
    ProductModel(
      id: 'p2',
      name: 'Brembo Brake Pads Set',
      price: 2800,
      category: 'Brakes',
      imagePath: 'assets/images/2.png',
    ),
    ProductModel(
      id: 'p3',
      name: 'NGK Iridium Spark Plugs',
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
  ];
  List<ProductModel> get marketProducts => _marketProducts;

  final List<EmergencyModel> _emergencyContacts = [
    EmergencyModel(
      name: 'Helpoo Roadside Assistance',
      phoneNumber: '17000',
      location: 'All Egypt',
      type: 'Winch',
      rating: '5.0',
    ),
    EmergencyModel(
      name: 'Battery Express',
      phoneNumber: '19110',
      location: 'Greater Cairo',
      type: 'Battery',
      rating: '4.9',
    ),
  ];
  List<EmergencyModel> getEmergencyByType(String type) =>
      _emergencyContacts.where((e) => e.type == type).toList();

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': CupertinoIcons.square_grid_2x2_fill},
    {'name': 'Service Centers', 'icon': CupertinoIcons.wrench_fill},
    {'name': 'Oils', 'icon': CupertinoIcons.drop_fill},
  ];
  List<Map<String, dynamic>> get categories => _categories;

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  // --- جلب البيانات المرجعية ---
  Future<List<dynamic>> fetchBrands() async => await _carService.getBrands();
  Future<List<dynamic>> fetchModels(String brandId) async =>
      await _carService.getModels(brandId);

  void clearData() {
    _myCars = [];
    _selectedCar = null;
    _organizationName = null;
    _carError = null;
    notifyListeners();
  }

  // ✅ تحسين دالة مسح البيانات لضمان تصفير السلة والطلبات عند الخروج
  void resetOnLogout() {
    _currentTabIndex = 0;
    _selectedCar = null;
    _myCars = [];
    _organizationName = null;
    _cartItems.clear(); 
    _myOrders.clear(); 
    _carError = null;
    notifyListeners();
  }

  void fetchDueMaintenance({required String carId}) {}
}