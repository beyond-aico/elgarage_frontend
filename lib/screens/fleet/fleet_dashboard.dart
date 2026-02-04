import 'package:elgarage/core/ui/app_footer.dart'; // الفوتر الأساسي بتاعك
import 'package:elgarage/core/ui/fleet_header.dart'; 
import 'package:elgarage/screens/add_car_screen.dart';
import 'package:elgarage/screens/marketplace_screen.dart'; // استدعاء الماركت الأساسي
import 'package:elgarage/screens/cart_screen.dart';        // استدعاء السلة الأساسية
import 'package:elgarage/screens/more_screen.dart';        // استدعاء المزيد الأساسية
import 'package:elgarage/screens/tabs/emergency_tab.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/textured_background.dart';
import '../car_details_screen.dart';

class FleetDashboard extends StatefulWidget {
  const FleetDashboard({super.key});
  @override
  State<FleetDashboard> createState() => _FleetDashboardState();
}

class _FleetDashboardState extends State<FleetDashboard> {
  String searchQuery = "";
  int _currentIndex = 0;

  // دالة تغيير التاب الموحدة
  void _switchToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    // 1. قائمة الصفحات (استدعاء نفس الشاشات الأساسية للتطبيق)
    final List<Widget> _fleetScreens = [
      _buildDashboardHome(provider, auth), // 0: لوحة التحكم (الرئيسية)
      const CarDetailsScreen(),             // 1: تفاصيل السيارة
      const MarketplaceScreen(),           // 2: الماركت (للزور المركزي)
      const EmergencyTab(),                  // 3: السلة (SOS في الفوتر بتاعك)
      const MoreScreen(),                  // 4: المزيد
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true, // مهم جداً عشان الفوتر بتاعك "CircularNotchedRectangle" يبان صح
      
      // 2. استخدام IndexedStack عشان الفوتر "يشتغل" فعلياً ويبدل بين الصفحات
      body: IndexedStack(
        index: _currentIndex,
        children: _fleetScreens,
      ),
      
      // 3. استدعاء الفوتر الأساسي (نفس الفايل اللي بعتهولي بالظبط)
      bottomNavigationBar: AppFooter(
        currentIndex: _currentIndex,
        onTap: _switchToTab,
      ),

      // 4. الزر المركزي (FAB) اللي الفوتر بتاعك سايب له مكان (SizedBox 40)
      floatingActionButton: FloatingActionButton(
        onPressed: () => _switchToTab(2), // يفتح الماركت
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.local_shipping, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // --- محتوى التاب رقم 0 (الداش بورد) ---
  Widget _buildDashboardHome(AppProvider provider, AuthProvider auth) {
    final allCars = provider.myCars;
    Map<String, List> groupedCars = {};
    for (var car in allCars) {
      if ((car.plateNumber ?? "").toLowerCase().contains(searchQuery.toLowerCase())) {
        String brand = (car.make).toUpperCase();
        groupedCars.putIfAbsent(brand, () => []).add(car);
      }
    }

    return TexturedBackground(
      child: Column(
        children: [
          // الهيدر المخصص للـ Fleet (اللي عملناه سوا)
          FleetHeader(
            userName: auth.user?.name ?? 'Commander',
            points: "1,250",
            onGrowFleet: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => const AddCarScreen())
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildSearchField(),
                ),
                const SizedBox(height: 25),
                _buildAnalyticsCharts(provider.fleetAnalytics),
                const SizedBox(height: 30),
                ...groupedCars.entries.map((entry) => 
                  _buildBrandSlideshow(entry.key, entry.value)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- باقي الدوال المساعدة (Analytics, Slideshow, Search) تظل بداخل الكلاس ---
  
  Widget _buildAnalyticsCharts(Map data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("OPERATIONAL PERFORMANCE", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13)),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(20),
            color: AppColors.textMain,
            child: Column(
              children: [
                _buildBar("FLEET HEALTH", 0.92, Colors.green),
                _buildBar("MAINTENANCE LOAD", 0.45, AppColors.warning),
                _buildBar("AVG EFFICIENCY", 0.76, AppColors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double val, Color col) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
              Text("${(val * 100).toInt()}%", style: TextStyle(color: col, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 5),
          LinearProgressIndicator(value: val, backgroundColor: Colors.white10, color: col, minHeight: 4),
        ],
      ),
    );
  }

  Widget _buildBrandSlideshow(String brand, List cars) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10), 
          child: Text("$brand UNITS", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 15),
            itemCount: cars.length,
            itemBuilder: (context, index) => _buildCarCard(cars[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildCarCard(dynamic car) {
    return GestureDetector(
      onTap: () {
        Provider.of<AppProvider>(context, listen: false).setSelectedCar(car);
        _switchToTab(1); // يفتح صفحة الـ My Car (التاب 1)
      },
      child: Container(
        width: 160, 
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: Colors.white, 
          border: Border.all(color: AppColors.textMain.withOpacity(0.1)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Expanded(child: car.imageUrl != null ? Image.network(car.imageUrl!) : const Icon(Icons.directions_car)),
            Container(
              width: double.infinity, padding: const EdgeInsets.all(10), color: AppColors.textMain,
              child: Text(car.plateNumber ?? "N/A", 
                textAlign: TextAlign.center, 
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      onChanged: (v) => setState(() => searchQuery = v),
      decoration: const InputDecoration(
        hintText: "SEARCH_BY_PLATE_LOG...", 
        prefixIcon: Icon(Icons.search), 
        filled: true, 
        fillColor: Colors.white, 
        border: OutlineInputBorder()
      ),
    );
  }
}