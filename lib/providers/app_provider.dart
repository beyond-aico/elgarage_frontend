import 'package:elgarage/data/models/emergency_model.dart';
import 'package:elgarage/data/models/product_model.dart';
import 'package:elgarage/data/models/service_log_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../data/models/car_model.dart';

class AppProvider with ChangeNotifier {
  // --- 1. CAR MANAGEMENT ---
  List<CarModel> _myCars = [
    CarModel(
      id: '1',
      make: 'Hyundai',
      model: 'Tucson',
      year: '2022',
      imageUrl: 'assets/images/car1.png',
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

  CarModel? _selectedCar;

  List<CarModel> get myCars => _myCars;

  CarModel get selectedCar {
    if (_selectedCar != null) {
      return _selectedCar!;
    } else if (_myCars.isNotEmpty) {
      return _myCars.first;
    } else {
      return _myCars.first;
    }
  }

  void selectCar(CarModel car) {
    _selectedCar = car;
    notifyListeners();
  }

  void addCar(CarModel newCar) {
    _myCars.add(newCar);
    notifyListeners();
  }

  final Map<String, List<String>> _supportedBrands = {
    'Toyota': ['Corolla', 'Camry', 'Yaris'],
    'Hyundai': ['Tucson', 'Elantra', 'Verna'],
    'Kia': ['Sportage', 'Cerato', 'Rio'],
    'BMW': ['X5', '320i', '530i'],
    'Mercedes': ['C200', 'E300', 'S500'],
  };

  List<String> get brands => _supportedBrands.keys.toList();

  List<String> getModelsForBrand(String? brand) {
    if (brand == null) return [];
    return _supportedBrands[brand] ?? [];
  }


  // --- 2. MAINTENANCE LOGIC & MATRIX ---

  final Map<int, List<String>> _maintenanceMatrix = {
    10000: ['Engine Oil', 'Oil Filter'],
    20000: ['Engine Oil', 'Oil Filter', 'Air Filter', 'Pollen Filter', 'Spark Plugs'],
    30000: ['Engine Oil', 'Oil Filter', 'Coolant Water'],
    40000: [
      'Engine Oil', 'Oil Filter', 'Air Filter', 'Pollen Filter', 'Spark Plugs',
      'Fuel Filter', 'Gearbox Oil (if 4-gear)'
    ],
    50000: ['Engine Oil', 'Oil Filter', 'Gearbox Oil (if 6-gear)'],
    60000: ['Engine Oil', 'Oil Filter', 'Air Filter', 'Spark Plugs', 'Drive Belt (Kit)'],
    70000: ['Engine Oil', 'Oil Filter', 'Coolant Water'],
    80000: [
      'Engine Oil', 'Oil Filter', 'Air Filter', 'Pollen Filter', 'Spark Plugs',
      'Fuel Filter', 'Coolant Pump', 'Gearbox Oil (if 4-gear)'
    ],
    90000: ['Engine Oil', 'Oil Filter'],
    100000: ['Engine Oil', 'Oil Filter', 'Air Filter', 'Spark Plugs'],
    110000: ['Engine Oil', 'Oil Filter'],
    120000: [
      'Engine Oil', 'Oil Filter', 'Air Filter', 'Pollen Filter', 'Spark Plugs',
      'Fuel Filter', 'Drive Belt (Kit)', 'Coolant Water', 'Gearbox Oil'
    ],
  };

  // Helper to get NEXT Milestone based on Current KM
  int get currentMilestone {
    double km = selectedCar.currentKm;
    return ((km / 10000).floor() + 1) * 10000;
  }
  
  // *** NEW INTEGRATION LOGIC ***
  // Checks if a specific part was replaced near a specific mileage milestone
  bool wasPartReplacedAtMilestone(String partName, int milestoneKm) {
    // We allow a margin of error (e.g., if he did 30k service at 31k km, it's fine)
    const int margin = 2000; 
    
    // Normalize part name for comparison (remove ' (Clean)', case insensitive)
    String cleanPartName = partName.replaceAll('(Clean)', '').trim().toLowerCase();

    return _historyLogs.any((log) {
       // Check mileage range
       bool isWithinRange = log.mileage >= (milestoneKm - margin) && 
                            log.mileage <= (milestoneKm + margin);
       
       if (!isWithinRange) return false;

       // Check if parts list contains this item
       return log.partsReplaced.any((p) => p.toLowerCase().contains(cleanPartName));
    });
  }

  // Generate items for a specific milestone
  List<ProductModel> getMaintenanceItemsFor(int milestone) {
    List<String> requiredParts = _maintenanceMatrix[milestone] ?? ['Engine Oil', 'Oil Filter'];

    return requiredParts.map((part) {
      // Logic to determine if "Missed"
      // If the milestone requested is IN THE PAST (less than current milestone)
      // AND we don't have a record of it being changed in our new intelligent history check.
      bool missed = false;
      
      // Only check for "Missed" if the milestone is completely in the past
      // (e.g. current is 45k, milestone is 40k. If we are at 40k exactly, it's "Due", not "Missed")
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

  // Simulated Price Helper
  double _getPriceForPart(String name) {
    name = name.toLowerCase();
    if (name.contains('oil') && !name.contains('filter')) return 1200; 
    if (name.contains('filter')) return 350;
    if (name.contains('spark')) return 800;
    if (name.contains('belt')) return 2500;
    if (name.contains('coolant')) return 600;
    if (name.contains('pump')) return 1800;
    return 500;
  }


  // --- 3. SERVICE HISTORY LOGS (Updated) ---
  
  // Note: Ensure your ServiceLogModel has 'mileage' (double) and 'partsReplaced' (List<String>)
  List<ServiceLogModel> _historyLogs = [
    ServiceLogModel(
      id: '1',
      serviceName: '40k Maintenance',
      date: DateTime.now().subtract(const Duration(days: 30)),
      cost: 3500,
      mileage: 41000, // He did it a bit late, but within margin
      partsReplaced: ['Engine Oil', 'Oil Filter', 'Air Filter', 'Spark Plugs'],
    ),
    ServiceLogModel(
      id: '2',
      serviceName: 'Tires Replacement',
      date: DateTime.now().subtract(const Duration(days: 120)),
      cost: 8000,
      mileage: 35000,
      partsReplaced: ['Tires'],
    ),
  ];

  List<ServiceLogModel> get historyLogs => _historyLogs;

  // Updated Add Function
  void addServiceLog({
    required String name, 
    required DateTime date, 
    required double mileage, 
    required List<String> parts,
    double cost = 0.0,
  }) {
    final newLog = ServiceLogModel(
      id: DateTime.now().toString(),
      serviceName: name,
      date: date,
      mileage: mileage,
      partsReplaced: parts,
      cost: cost,
    );
    _historyLogs.insert(0, newLog);
    notifyListeners();
  }


  // --- 4. CART & MARKET ---
  List<ProductModel> _cartItems = [];
  List<ProductModel> get cartItems => _cartItems;

  void addToCart(List<ProductModel> products) {
    _cartItems.addAll(products);
    notifyListeners();
  }

  void removeFromCart(ProductModel item) {
    _cartItems.remove(item);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  double get cartTotal {
    return _cartItems.fold(0, (sum, item) => sum + item.price);
  }

  // --- 5. NAVIGATION STATE ---
  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }


  // --- 6. EMERGENCY CONTACTS ---
  List<EmergencyModel> _emergencyContacts = [
    EmergencyModel(name: 'Al-Inqaz Towing', phoneNumber: '0100000001', location: 'Nasr City', type: 'Winch', rating: '4.9'),
    EmergencyModel(name: 'Road Hero Winch', phoneNumber: '0100000002', location: 'Maadi', type: 'Winch', rating: '4.7'),
    EmergencyModel(name: 'Fit & Fix Batteries', phoneNumber: '19000', location: 'New Cairo', type: 'Battery', rating: '4.8'),
    EmergencyModel(name: 'Battery Doctors', phoneNumber: '0110000000', location: 'Giza', type: 'Battery', rating: '4.5'),
    EmergencyModel(name: 'Tire Man', phoneNumber: '0120000000', location: 'Heliopolis', type: 'Tire', rating: '4.6'),
  ];

  List<EmergencyModel> getEmergencyByType(String type) {
    return _emergencyContacts.where((element) => element.type == type).toList();
  }


  // --- 7. MARKET DATA ---
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

  List<ProductModel> _marketProducts = [
    ProductModel(id: '201', name: 'Shell Helix Ultra', price: 950, category: 'Oils', image: 'assets/images/oil.png'),
    ProductModel(id: '202', name: 'Michelin Tire 16"', price: 4500, category: 'Tires', image: 'assets/images/tire.png'),
    ProductModel(id: '203', name: 'Varta Battery 70Ah', price: 3200, category: 'Batteries'),
    ProductModel(id: '204', name: 'Air Filter (Orig.)', price: 350, category: 'Filters'),
    ProductModel(id: '205', name: 'Car Vacuum Cleaner', price: 600, category: 'Accessories'),
    ProductModel(id: '206', name: 'Brake Pads Front', price: 1200, category: 'Service Centers'),
  ];

  List<ProductModel> get marketProducts => _marketProducts;
  
  List<ProductModel> _maintenancePackage = [
    ProductModel(id: '101', name: 'Synthetic Engine Oil (5W-40)', price: 1200, category: 'Oils'),
    ProductModel(id: '102', name: 'Oil Filter', price: 250, category: 'Filters'),
    ProductModel(id: '103', name: 'Air Filter', price: 300, category: 'Filters'),
    ProductModel(id: '104', name: 'AC Filter', price: 450, category: 'Filters'),
  ];
  List<ProductModel> get maintenancePackage => _maintenancePackage;


  // --- 8. SERVICE CENTERS ---
  final List<Map<String, dynamic>> _serviceCenters = [
    {'name': 'Auto Fix Center', 'location': 'Nasr City', 'labor_cost': 200.0},
    {'name': 'The Mechanic', 'location': 'Maadi', 'labor_cost': 250.0},
    {'name': 'Pro Car Service', 'location': 'New Cairo', 'labor_cost': 300.0},
    {'name': 'Quick Fix', 'location': 'Giza', 'labor_cost': 150.0},
  ];

  List<Map<String, dynamic>> get serviceCenters => _serviceCenters;
}