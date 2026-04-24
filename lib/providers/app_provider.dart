import 'package:elgarage/core/models/auth_response_model.dart';
import 'package:elgarage/core/services/car_service.dart';
import 'package:elgarage/providers/auth_provider.dart';
import 'package:elgarage/providers/fleet_provider.dart';
import 'package:elgarage/providers/maintenance_provider.dart';
import 'package:flutter/cupertino.dart';
import '../core/models/car_model.dart';
import '../core/models/product_model.dart';
import '../core/models/emergency_model.dart';
import '../core/data/dummy_data.dart'; 

class AppProvider with ChangeNotifier {
  final CarService _carService = CarService();

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

  final List<ProductModel> _cartItems = [];
  final List<Map<String, dynamic>> _myOrders = [];
  List<ProductModel> get cartItems => _cartItems;
  List<Map<String, dynamic>> get myOrders => _myOrders;
  double get cartTotal => _cartItems.fold(0, (sum, item) => sum + item.price);

  String? _organizationName;
  String get organizationName => _organizationName ?? "Personal Garage";
  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

List<Map<String, dynamic>> get serviceCenters => DummyData.serviceCenters;
List<ProductModel> get marketProducts => DummyData.marketProducts;
List<EmergencyModel> getEmergencyByType(String type) =>
DummyData.emergencyContacts.where((e) => e.type == type).toList();
List<Map<String, dynamic>> get categories => DummyData.categories;
String getImageForPart(String partName) {
  return DummyData.getPartImage(partName);
}

Future<void> syncUserContext(
    User? user, 
    AuthProvider auth, 
    FleetProvider fleet, 
    MaintenanceProvider maintenance
  ) async {
    if (user == null) return;
    _organizationName = user.organizationName;
    
    await fetchMyCars(authProvider: auth, forceRefresh: true);

    if (user.role.toUpperCase() == "DRIVER") {
      if (fleet.authenticatedCar != null) {
        _selectedCar = fleet.authenticatedCar;
        await maintenance.fetchDueMaintenance(_selectedCar!.id, _selectedCar!.mileageKm);
      }
      notifyListeners();
      debugPrint("DEBUG: [syncUserContext] Driver ${user.name} context synced.");
    }
  }

  void reorderMyCars(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _myCars.removeAt(oldIndex);
    _myCars.insert(newIndex, item);
    notifyListeners();
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
      List<Car> fetchedCars = await _carService.getMyCars();

      _myCars = List<Car>.from(fetchedCars);
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

// lib/providers/app_provider.dart

Future<bool> updateCarCurrentKm(int newKm, {FleetProvider? fleetProvider}) async {
  if (_selectedCar == null) return false;
  _isUpdatingMileage = true;
  notifyListeners();
  
  try {
    bool success = await _carService.updateCarMileage(
      _selectedCar!.id,
      newKm,
    );
    
    if (success) {
      // 1. تحديث السيارة المختارة في AppProvider
      _selectedCar = _selectedCar!.copyWith(mileageKm: newKm);
      
      // 2. تحديث القيمة في القائمة الرئيسية لضمان التزامن
      int index = _myCars.indexWhere((c) => c.id == _selectedCar!.id);
      if (index != -1) _myCars[index] = _selectedCar!;
      
      // 3. ✅ التحديث السحري: إبلاغ الـ FleetProvider بالتحديث لو كان ممرراً
      fleetProvider?.updateVehicleMileageLocally(_selectedCar!.id, newKm);

      return true;
    }
    return false;
  } finally {
    _isUpdatingMileage = false;
    notifyListeners();
  }
}

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

void placeOrder(Map<String, dynamic> deliveryDetails) {
  if (_cartItems.isEmpty || _selectedCar == null) return;
  
  // حساب السيرفس القادم (مثلاً أقرب 10 آلاف)
  int nextService = ((_selectedCar!.mileageKm / 10000).floor() + 1) * 10000;

  _myOrders.insert(0, {
    'id': 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
    'date': DateTime.now(),
    'items': List.from(_cartItems),
    'total': cartTotal,
    'status': 'Pending',
    'delivery': deliveryDetails,
    'estimatedDelivery': '2 Days',
    // ✅ إضافة بيانات العربية والباكدج للأوردر
    'carInfo': {
      'name': '${_selectedCar!.make} ${_selectedCar!.model}',
      'plate': _selectedCar!.licensePlate ?? "---",
      'brand': _selectedCar!.make,
    },
    'packageType': '$nextService KM PACKAGE', 
  });
  
  _cartItems.clear();
  notifyListeners();
}

String? get preSelectedCenterName {
  try {
    // البحث عن أول عنصر في السلة ينتمي لفئة 'Service'
    final serviceItem = _cartItems.firstWhere((item) => item.category == 'Service');
    // استخراج اسم المركز من النص "Installation: اسم المركز"
    return serviceItem.name.replaceFirst('Installation: ', '');
  } catch (e) {
    return null; // لا يوجد مركز في السلة
  }
}

void cancelOrder(String orderId) {
  _myOrders.removeWhere((order) => order['id'] == orderId);
  notifyListeners();
}

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

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