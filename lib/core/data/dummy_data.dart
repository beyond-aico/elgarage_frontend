import 'package:flutter/cupertino.dart';
import '../models/product_model.dart';
import '../models/emergency_model.dart';

class DummyData {

  static final List<Map<String, dynamic>> serviceCenters = [
    {
      'name': 'Bosch Car Service El Mikaneeky',
      'location': 'First Settlement',
      'labor_cost': 250.0,
      'mapUrl': 'https://maps.app.goo.gl/ioehkEboW2AR8aVo6?g_st=awb',
    },
    {
      'name': 'Bosch Car Service El Mikaneeky',
      'location': 'Mobil Gas Station - Hassan Maamoun',
      'labor_cost': 200.0,
      'mapUrl': 'https://maps.app.goo.gl/MrH1utNjNSUomeLMA?g_st=awb',
    },
    {
      'name': 'Bosch Car Service El Mikaneeky',
      'location': 'Mobil Gas Station - Nasr Road',
      'labor_cost': 200.0,
      'mapUrl': 'https://maps.app.goo.gl/Yh6CQPrw1H9Tw1vm8?g_st=awb',
    },
    {
      'name': 'Bosch Car Service El Mikaneeky',
      'location': 'Mobil Gas Station - Sheraton',
      'labor_cost': 300.0,
      'mapUrl': 'https://maps.app.goo.gl/nLJ7JB6bs5yL1XPR9?g_st=awb',
    },
  ];

  static final List<ProductModel> marketProducts = [
  // --- منتجات توتال (Total) ---
  ProductModel(
    id: 'oil-total-q-5w40',
    name: 'Total Quartz 5W40 4L',
    price: 2375,
    category: 'Oils',
    imagePath: 'assets/images/m.6.jpeg',
  ),
  ProductModel(
    id: 'oil-total-q-20w50',
    name: 'Total Quartz 20W50 4L',
    price: 935,
    category: 'Oils',
    imagePath: 'assets/images/m.7.jpeg',
  ),
  ProductModel(
    id: 'oil-total-r-20w50',
    name: 'Total Rubia 20W50 5L',
    price: 1045,
    category: 'Oils',
    imagePath: 'assets/images/m.8.jpeg',
  ),

  // --- منتجات موبيل (Mobil) ---
  ProductModel(
    id: 'oil-mobil-5w40',
    name: 'Mobil 5W40 4L',
    price: 2300,
    category: 'Oils',
    imagePath: 'assets/images/m.1.jpeg',
  ),
  ProductModel(
    id: 'oil-mobil-xhp-15w50',
    name: 'Mobil 15W50 XHP 4L',
    price: 1120,
    category: 'Oils',
    imagePath: 'assets/images/m.9.jpeg',
  ),
  ProductModel(
    id: 'oil-mobil-delvac-20w50',
    name: 'Mobil Delvac 20W50 MX 20L',
    price: 4290,
    category: 'Oils',
    imagePath: 'assets/images/m.2.jpeg',
  ),

  // --- منتجات شل (Shell) ---
  ProductModel(
    id: 'oil-shell-helix-15w50',
    name: 'Shell Helix 15W50 4L',
    price: 1150,
    category: 'Oils',
    imagePath: 'assets/images/m.5.jpeg',
  ),
  ProductModel(
    id: 'oil-shell-ultra-5w30',
    name: 'Shell Helix Ultra 5W30 4L',
    price: 2795,
    category: 'Oils',
    imagePath: 'assets/images/m.3.jpeg',
  ),
];
  // 3. جهات اتصال الطوارئ
  static final List<EmergencyModel> emergencyContacts = [
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

  static final List<Map<String, dynamic>> categories = [
    {'name': 'All', 'icon': CupertinoIcons.square_grid_2x2_fill},
    {'name': 'Service Centers', 'icon': CupertinoIcons.wrench_fill},
    {'name': 'Oils', 'icon': CupertinoIcons.drop_fill},
  ];

static String getPartImage(String partName) {
  String name = partName.toLowerCase();
  if (name.contains('total')) return 'assets/images/m.1.jpg';
  if (name.contains('mobil')) return 'assets/images/m.2.jpg';
  if (name.contains('shell')) return 'assets/images/m.3.jpg';
  
  if (name.contains('oil')) return 'assets/images/m.4.jpeg';
  if (name.contains('spark')) return 'assets/images/3.jfif';
  if (name.contains('brake')) return 'assets/images/2.png';
  
  // الصورة الافتراضية
  return 'assets/images/engine_oil.jpg';
}
}