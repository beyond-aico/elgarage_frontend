// --- FILE: lib/screens/fleet/fleet_dashboard.dart ---

import 'package:elgarage/core/ui/app_footer.dart'; 
import 'package:elgarage/core/ui/app_header.dart'; 
import 'package:elgarage/core/ui/textured_background.dart';
import 'package:elgarage/screens/add_car_screen.dart';
import 'package:elgarage/screens/marketplace_screen.dart';
import 'package:elgarage/screens/emergency_screen.dart';
import 'package:elgarage/screens/more/more_screen.dart';
import 'package:elgarage/widgets/car_card.dart'; 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../car_details_screen.dart';

class FleetDashboard extends StatefulWidget {
  const FleetDashboard({super.key});
  @override
  State<FleetDashboard> createState() => _FleetDashboardState();
}

class _FleetDashboardState extends State<FleetDashboard> {
  String searchQuery = "";
  int _currentIndex = 0;

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    if (mounted) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final app = Provider.of<AppProvider>(context, listen: false);

      // لو الـ User لسه مش جاهز، استنى ثانية واحدة
      String? userRole = auth.user?.role;
      
      debugPrint("🚀 Dashboard Init with Role: $userRole");
      await app.fetchMyCars(role: userRole);
    }
  });
}

  void _switchToTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    final List<Widget> fleetScreens = [
      _buildDashboardHome(provider, auth), 
      const CarDetailsScreen(),             
      const MarketplaceScreen(),           
      const EmergencyScreen(),             
      const MoreScreen(),                  
    ];

    return PopScope(
      canPop: _currentIndex == 0,
onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _switchToTab(0);
      },
      child: Scaffold(
        extendBody: true, 
        body: IndexedStack(
          index: _currentIndex,
          children: fleetScreens,
        ),
        bottomNavigationBar: AppFooter(
          currentIndex: _currentIndex,
          onTap: _switchToTab,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _switchToTab(2),
          backgroundColor: AppColors.primary,
          shape: const CircleBorder(),
          child: const Icon(Icons.local_shipping, color: Colors.black),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget _buildDashboardHome(AppProvider provider, AuthProvider auth) {
final filteredCars = provider.myCars.where((car) {
  final query = searchQuery.toLowerCase();
  // إضافة حماية ضد الـ Null في الـ Make والـ Model
  final make = car.make.toLowerCase();
  final model = car.model.toLowerCase();
  final plate = (car.licensePlate ?? "").toLowerCase();
  
  return make.contains(query) || model.contains(query) || plate.contains(query);
}).toList();

    Map<String, List> groupedCars = {};
    for (var car in filteredCars) {
      String groupKey = "${car.make} ${car.model}".toUpperCase();
      groupedCars.putIfAbsent(groupKey, () => []).add(car);
    }

    return TexturedBackground(
      child: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Welcome back,',
             userName: auth.user?.name ?? 'Fleet Commander',
      statsText: '${provider.myCars.length} VEHICLES IN FLEET',
              actionLabel: 'GROW MY FLEET',
              onActionPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const AddCarScreen())
              ),
            ),
            
            Expanded(
              child: provider.isLoadingCars 
                ? const Center(child: CircularProgressIndicator(color: Colors.amber))
                : ListView(
                    padding: const EdgeInsets.only(top: 0, bottom: 120), 
                    children: [
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildSearchField(),
                      ),
                      const SizedBox(height: 25),
                      
                      _buildSectionTitle("ANALYTIC INSIGHTS"),
                      _buildVerticalBarChart("FUEL USAGE (GAL)", ["S", "M", "T", "W", "T", "F", "S"], [0.3, 0.7, 0.5, 0.9, 0.4, 0.2, 0.6], Colors.blue),
                      _buildVerticalBarChart("ACTIVE HOURS", ["W1", "W2", "W3", "W4"], [0.8, 0.6, 0.9, 0.7], AppColors.primary),

                      const SizedBox(height: 25),
                      
                      ...groupedCars.entries.map((entry) => 
                        _buildModelSlideshow(entry.key, entry.value)
                      ),
                    ],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalBarChart(String title, List<String> labels, List<double> values, Color color) {
    return Container(
      height: 180, 
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.textMain, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 10),
          Expanded(
            child: LayoutBuilder( 
              builder: (context, constraints) {
                double maxHeight = constraints.maxHeight - 20; 
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(labels.length, (i) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible( 
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            width: 15,
                            height: maxHeight * values[i], 
                            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(labels[i], style: const TextStyle(color: Colors.white60, fontSize: 8)),
                      ],
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelSlideshow(String modelTitle, List cars) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 5), 
          child: Text(modelTitle, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        ),
        SizedBox(
          // ✅ تم رفع الارتفاع لـ 340 لإعطاء مساحة للكارت (300) ومنع الـ Overflow
          height: 340, 
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 8),
            itemCount: cars.length,
            itemBuilder: (context, index) {
              return SizedBox(
                width: 340, 
                child: CarCard(
                  car: cars[index], 
                  onTap: () {
                    Provider.of<AppProvider>(context, listen: false).setSelectedCar(cars[index]);
                    _switchToTab(1);
                  },
                  isSelected: false,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.2)),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      onChanged: (v) => setState(() => searchQuery = v),
      decoration: InputDecoration(
        hintText: "SEARCH FLEET BY PLATE OR MODEL...", 
        prefixIcon: const Icon(Icons.search, color: AppColors.primary), 
        filled: true, 
        fillColor: Colors.white, 
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}