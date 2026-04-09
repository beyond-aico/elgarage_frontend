import 'package:elgarage/core/models/fleet_analytics_model.dart';
import 'package:elgarage/core/ui/app_footer.dart'; 
import 'package:elgarage/core/ui/app_header.dart'; 
import 'package:elgarage/core/ui/textured_background.dart';
import 'package:elgarage/screens/add_car_screen.dart';
import 'package:elgarage/widgets/car_card.dart'; 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/fleet_provider.dart';
import '../../screens/fleet/analytics_dashboard.dart';
import '../car_details_screen.dart';
import '../marketplace_screen.dart';
import '../emergency_screen.dart';
import '../more/more_screen.dart';

class FleetDashboard extends StatefulWidget {
  const FleetDashboard({super.key});
  @override
  State<FleetDashboard> createState() => _FleetDashboardState();
}

class _FleetDashboardState extends State<FleetDashboard> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => searchQuery = _searchController.text);
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData(); 
    });
  }

  Future<void> _refreshData() async {
    if (!mounted) return;

    // الحصول على الـ Providers قبل أي عملية await لتجنب async gap errors
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final app = Provider.of<AppProvider>(context, listen: false);
    final fleet = Provider.of<FleetProvider>(context, listen: false);
    
    if (auth.user == null) {
      await Future.delayed(const Duration(milliseconds: 800));
    }

    if (!mounted) return;

    // 1. جلب السيارات أولاً
    await app.fetchMyCars(
      role: auth.user?.role,
      orgId: auth.user?.organizationId,
      authProvider: auth,
      forceRefresh: true,
    );

    // 2. تمرير السيارات لجلب الإحصائيات (حل مشكلة positional argument)
    await fleet.loadFleetStats(app.myCars);
  }
  
  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final fleetProvider = Provider.of<FleetProvider>(context);

if (appProvider.isLoadingCars && appProvider.myCars.isEmpty) {
    return const Scaffold(
      backgroundColor: AppColors.textMain, // خلفية سوداء نفس لون التطبيق
      body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }

    final List<Widget> commanderScreens = [
      _buildAnalyticsTab(appProvider, authProvider, fleetProvider), 
      _buildFleetListTab(appProvider, authProvider),               
      const MarketplaceScreen(),                                   
      const EmergencyScreen(),                                     
      const MoreScreen(),                                          
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: commanderScreens[_currentIndex], 
      bottomNavigationBar: AppFooter(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _currentIndex = 2),
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.storefront, color: Colors.black, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildAnalyticsTab(AppProvider app, AuthProvider auth, FleetProvider fleet) {
    if (fleet.isLoadingStats) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

   final stats = fleet.fleetStats;
  if (stats == null) {
    return const Center(child: Text("HOLD ON, SYNCING DATA...", style: TextStyle(color: Colors.white24)));
  }

    final filteredBreakdown = stats.vehicleBreakdown.where((v) {
      final query = searchQuery.toLowerCase();
      return v.plateNumber.toLowerCase().contains(query) ||
             v.brand.toLowerCase().contains(query) ||
             v.model.toLowerCase().contains(query);
    }).toList();
    
    final filteredStats = FleetAnalytics(
      totalFleetCost: stats.totalFleetCost,
      totalFuelConsumedLiters: stats.totalFuelConsumedLiters,
      totalKmsDriven: stats.totalKmsDriven,
      costPerKm: stats.costPerKm,
      totalMaintenanceCost: stats.totalMaintenanceCost,
      totalFuelCost: stats.totalFuelCost,
      vehicleBreakdown: filteredBreakdown,
    );

    return TexturedBackground(
      child: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Fleet Control,',
              userName: auth.user?.name ?? 'Commander',
              statsText: 'LIVE ANALYTICS OVERVIEW',
              actionLabel: 'home.add_car_title',
              onActionPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCarScreen())),
            ),
            Expanded(
              child: RefreshIndicator(
                // حل مشكلة RefreshCallback عن طريق دالة مجهولة تمرر المعامل المطلوب
                onRefresh: () => fleet.loadFleetStats(app.myCars), 
                color: AppColors.primary,
                child: ListView(
                  padding: const EdgeInsets.only(top: 15, bottom: 100),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildSearchField("FILTER ANALYTICS..."),
                    ),
                    const SizedBox(height: 25),
                    if (searchQuery.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                        child: Text(
                          "FOUND ${filteredBreakdown.length} MATCHES",
                          style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    AnalyticsDashboard(stats: filteredStats),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildFleetListTab(AppProvider app, AuthProvider auth) {
  debugPrint("UI_DEBUG: [_buildFleetListTab] Building View...");
  
  final filteredCars = app.myCars.where((car) {
    final query = searchQuery.toLowerCase();
    return car.make.toLowerCase().contains(query) || 
           car.model.toLowerCase().contains(query) || 
           (car.licensePlate ?? "").toLowerCase().contains(query);
  }).toList();

  return TexturedBackground(
    child: SafeArea(
      child: Column(
        children: [
          AppHeader(
            title: 'Fleet Schedule', 
            userName: auth.user?.name ?? 'Commander',
            statsText: '${app.myCars.length} VEHICLES SECURED', 
            actionLabel: 'home.add_car_title',
            onActionPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCarScreen())),
          ),

          Expanded(
            child: app.isLoadingCars && app.myCars.isEmpty
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : ListView(
                  padding: const EdgeInsets.only(top: 15, bottom: 100),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildSearchField("SEARCH BY PLATE OR MODEL..."),
                    ),
                    const SizedBox(height: 25),
                    
                    if (filteredCars.isEmpty)
                      const Center(child: Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: Text("NO VEHICLES FOUND", style: TextStyle(color: Colors.grey)),
                      ))
                    else
                      ..._groupCars(filteredCars).entries.map((e) {
                        debugPrint("UI_DEBUG: Drawing Group: ${e.key}");
                        return _buildModelSlideshow(e.key, e.value);
                      }),
                  ],
                ),
          ),
        ],
      ),
    ),
  );
}

  Map<String, List> _groupCars(List cars) {
    Map<String, List> groups = {};
    for (var car in cars) {
      String key = "${car.make} ${car.model}".toUpperCase();
      groups.putIfAbsent(key, () => []).add(car);
    }
    return groups;
  }

  Widget _buildModelSlideshow(String title, List cars) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 10), 
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.textMain))),
        SizedBox(
          height: 300, 
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 10),
            itemCount: cars.length,
            itemBuilder: (context, index) => SizedBox(
              width: MediaQuery.of(context).size.width * 0.85, 
              child: CarCard(
                car: cars[index], 
                onTap: () {
                  Provider.of<AppProvider>(context, listen: false).setSelectedCar(cars[index]);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CarDetailsScreen()));
                },
                isSelected: false,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(String hint) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: hint, 
          hintStyle: const TextStyle(fontSize: 11, color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: AppColors.primary), 
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}