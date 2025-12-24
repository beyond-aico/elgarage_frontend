import 'package:elgarage/data/models/emergency_model.dart';
import 'package:elgarage/data/models/product_model.dart';
import 'package:elgarage/data/models/service_log_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../data/models/car_model.dart';

class AppProvider with ChangeNotifier {
  // قائمة العربيات المملوكة للمستخدم (مؤقتاً داتا وهمية لحد ما نربط بالـ API)
  List<CarModel> _myCars = [
    CarModel(
      id: '1',
      make: 'Hyundai',
      model: 'Tucson',
      year: '2022',
      imageUrl: 'assets/images/car1.png', // تأكد إن الصورة دي موجودة
      currentKm: 45000,
      monthlyAvgKm: 1500,
    ),
    CarModel(
      id: '2',
      make: 'Kia',
      model: 'Sportage',
      year: '2021',
      imageUrl: 'assets/images/car2.png',
      currentKm: 60000,
      monthlyAvgKm: 2000,
    ),
  ];

  // العربية المختارة حالياً (Nullable عشان ممكن لسه ما اخترش)
  CarModel? _selectedCar;

  // Getter عشان نجيب العربيات
  List<CarModel> get myCars => _myCars;

  // Getter عشان نجيب العربية المختارة، لو مفيش بنرجع أول واحدة كـ Default
  CarModel get selectedCar {
    if (_selectedCar != null) {
      return _selectedCar!;
    } else if (_myCars.isNotEmpty) {
      return _myCars.first;
    } else {
      // حالة نادرة لو الليست فاضية (هنهندلها في الـ UI)
      return _myCars.first; 
    }
  }

  // دالة تغيير العربية المختارة
  void selectCar(CarModel car) {
    _selectedCar = car;
    notifyListeners(); // بنبلغ كل الصفحات إن العربية اتغيرت عشان يحدثوا البيانات
  }

List<ServiceLogModel> _historyLogs = [
    ServiceLogModel(
      id: '1', 
      serviceName: 'Oil Change', 
      date: DateTime.now().subtract(const Duration(days: 30)), 
      cost: 1500,
    ),
    ServiceLogModel(
      id: '2', 
      serviceName: 'Tires Replacement', 
      date: DateTime.now().subtract(const Duration(days: 120)), 
      cost: 8000,
    ),
  ];

  List<ServiceLogModel> get historyLogs => _historyLogs;

  // دالة إضافة سجل جديد
  void addServiceLog(String name, DateTime date) {
    final newLog = ServiceLogModel(
      id: DateTime.now().toString(), // ID مؤقت
      serviceName: name,
      date: date,
    );
    _historyLogs.insert(0, newLog); // بنضيفه في الأول عشان يظهر فوق
    notifyListeners();
  }

List<ProductModel> _maintenancePackage = [
    ProductModel(id: '101', name: 'Synthetic Engine Oil (5W-40)', price: 1200, category: 'Oils'),
    ProductModel(id: '102', name: 'Oil Filter', price: 250, category: 'Filters'),
    ProductModel(id: '103', name: 'Air Filter', price: 300, category: 'Filters'),
    ProductModel(id: '104', name: 'AC Filter', price: 450, category: 'Filters'),
  ];

  List<ProductModel> get maintenancePackage => _maintenancePackage;

  // 2. السلة (Cart)
  List<ProductModel> _cartItems = [];
  List<ProductModel> get cartItems => _cartItems;

  // دالة إضافة للسلة
  void addToCart(List<ProductModel> products) {
    _cartItems.addAll(products);
    notifyListeners();
  }
  
  // دالة لحساب إجمالي السلة
  double get cartTotal {
    return _cartItems.fold(0, (sum, item) => sum + item.price);
  }
  
  // --- إدارة التنقل (عشان لما ندوس Add نروح لصفحة الكارت أوتوماتيك) ---
  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

List<EmergencyModel> _emergencyContacts = [
    // 1. أوناش
    EmergencyModel(name: 'Al-Inqaz Towing', phoneNumber: '0100000001', location: 'Nasr City', type: 'Winch', rating: '4.9'),
    EmergencyModel(name: 'Road Hero Winch', phoneNumber: '0100000002', location: 'Maadi', type: 'Winch', rating: '4.7'),
    
    // 2. بطاريات
    EmergencyModel(name: 'Fit & Fix Batteries', phoneNumber: '19000', location: 'New Cairo', type: 'Battery', rating: '4.8'),
    EmergencyModel(name: 'Battery Doctors', phoneNumber: '0110000000', location: 'Giza', type: 'Battery', rating: '4.5'),

    // 3. كاوتش
    EmergencyModel(name: 'Tire Man', phoneNumber: '0120000000', location: 'Heliopolis', type: 'Tire', rating: '4.6'),
  ];

  // فلترة القائمة حسب النوع (عشان نعرض كل قسم لوحده)
  List<EmergencyModel> getEmergencyByType(String type) {
    return _emergencyContacts.where((element) => element.type == type).toList();
  }

final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': CupertinoIcons.square_grid_2x2_fill},
    {'name': 'Service Centers', 'icon': CupertinoIcons.wrench_fill},
    {'name': 'Oils', 'icon': CupertinoIcons.drop_fill},
    {'name': 'Filters', 'icon': CupertinoIcons.layers_alt_fill},
    {'name': 'Tires', 'icon': CupertinoIcons.circle_grid_hex},
    {'name': 'Batteries', 'icon': CupertinoIcons.bolt_fill},
    {'name': 'Accessories', 'icon': CupertinoIcons.game_controller_solid},
  ];

  List<Map<String, dynamic>> get categories => _categories;

  // 2. منتجات الماركت (داتا وهمية مكثفة)
  List<ProductModel> _marketProducts = [
    ProductModel(id: '201', name: 'Shell Helix Ultra', price: 950, category: 'Oils', image: 'assets/images/oil.png'),
    ProductModel(id: '202', name: 'Michelin Tire 16"', price: 4500, category: 'Tires', image: 'assets/images/tire.png'),
    ProductModel(id: '203', name: 'Varta Battery 70Ah', price: 3200, category: 'Batteries'),
    ProductModel(id: '204', name: 'Air Filter (Orig.)', price: 350, category: 'Filters'),
    ProductModel(id: '205', name: 'Car Vacuum Cleaner', price: 600, category: 'Accessories'),
    ProductModel(id: '206', name: 'Brake Pads Front', price: 1200, category: 'Service Centers'),
  ];

  List<ProductModel> get marketProducts => _marketProducts;

final List<Map<String, dynamic>> _serviceCenters = [
    {'name': 'Auto Fix Center', 'location': 'Nasr City', 'labor_cost': 200.0},
    {'name': 'The Mechanic', 'location': 'Maadi', 'labor_cost': 250.0},
    {'name': 'Pro Car Service', 'location': 'New Cairo', 'labor_cost': 300.0},
    {'name': 'Quick Fix', 'location': 'Giza', 'labor_cost': 150.0},
  ];

  List<Map<String, dynamic>> get serviceCenters => _serviceCenters;

  // دالة حذف من السلة
  void removeFromCart(ProductModel item) {
    _cartItems.remove(item);
    notifyListeners();
  }

  // دالة مسح السلة بالكامل (بعد الدفع)
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

}