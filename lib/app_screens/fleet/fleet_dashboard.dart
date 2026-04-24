import 'package:elgarage/core/models/fleet_analytics_model.dart';
import 'package:elgarage/core/app_ui/app_footer.dart'; 
import 'package:elgarage/core/app_ui/app_header.dart'; 
import 'package:elgarage/core/app_ui/textured_background.dart';
import 'package:elgarage/app_screens/add_car_screen.dart';
import 'package:elgarage/app_widgets/car_card.dart'; 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/fleet_provider.dart';
import 'analytics_dashboard.dart';
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
      body: TexturedBackground(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
    );
  }

    final List<Widget> commanderScreens = [
      _buildAnalyticsTab(appProvider, authProvider, fleetProvider), 
      _buildFleetListTab(appProvider, authProvider),               
      const MarketplaceScreen(),                                   
      const EmergencyScreen(),                                     
      const MoreScreen(),                                          
    ];

 // lib/app_screens/fleet/fleet_dashboard.dart

return Scaffold(
  extendBody: true,
  resizeToAvoidBottomInset: false, // ✅ الحل: يمنع الفوتر والزرار من الارتفاع مع الكيبورد
  backgroundColor: Colors.transparent,
  
  // ✅ التعديل: ربط الـ body بالحالة العامة في AppProvider
  body: commanderScreens[appProvider.currentTabIndex], 
  
  bottomNavigationBar: AppFooter(
    currentIndex: appProvider.currentTabIndex,
    onTap: (index) => appProvider.setTabIndex(index),
  ),

  floatingActionButton: FloatingActionButton(
    // ✅ التعديل: تحديث تابة الماركت بليس (index 2) في البروفايدر
    onPressed: () => appProvider.setTabIndex(2), 
    backgroundColor: AppColors.primary,
    shape: const CircleBorder(),
    child: const Icon(Icons.storefront, color: Colors.black, size: 28),
  ),
  floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
);

}
void _selectDateRange(BuildContext context, FleetProvider fleet, AppProvider app) async {
  final DateTimeRange? picked = await showDateRangePicker(
    context: context,
    firstDate: DateTime(2025),
    lastDate: DateTime.now(),
    initialDateRange: fleet.startDate != null 
        ? DateTimeRange(start: fleet.startDate!, end: fleet.endDate!)
        : null,
  );

  if (picked != null) {
    // إعادة تحميل البيانات بناءً على التواريخ المختارة
    await fleet.loadFleetStats(app.myCars, start: picked.start, end: picked.end);
  }
}

 Widget _buildAnalyticsTab(AppProvider app, AuthProvider auth, FleetProvider fleet) {
  if (fleet.isLoadingStats) {
    // ✅ تغليف الـ Loader بالخلفية
    return const TexturedBackground(
      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }

  final stats = fleet.fleetStats;
  if (stats == null) {
    // ✅ تغليف رسالة المزامنة بالخلفية الموحدة
    return const TexturedBackground(
      child: Center(
        child: Text(
          "HOLD ON, SYNCING DATA...", 
          style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)
        )
      ),
    );
  }
  
  // 1. فلترة القائمة بناءً على البحث (Search Query)
  final filteredBreakdown = stats.vehicleBreakdown.where((v) {
    final query = searchQuery.toLowerCase();
    return v.plateNumber.toLowerCase().contains(query) ||
           v.brand.toLowerCase().contains(query) ||
           v.model.toLowerCase().contains(query);
  }).toList();
  
  // ✅ 2. إعادة حساب الإجماليات "للتكاليف فقط" لضمان تأثر الـ Overview بالبحث
  double totalMaint = 0;
  double totalFuelCost = 0;
  double totalLiters = 0;

  for (var v in filteredBreakdown) {
    // ⚠️ لاحظ: حذفنا سطر totalKms += v.distance لأنه يسبب Error 
    // وحذفنا totalKms += v.kms لأنه يسبب مشكلة الـ 2.2 مليون كم
    totalMaint += v.nextMaintenanceCost; 
    totalFuelCost += v.totalCost;
    totalLiters += v.fuelLiters;
  }

  // 3. بناء كائن الإحصائيات بالبيانات الصحيحة
  final filteredStats = FleetAnalytics(
    // ✅ نستخدم القيمة الأصلية من السيرفر لأنها هي التي تحتوي على "إجمالي مسافة الفترة" (مثلاً 50 كم)
    totalKmsDriven: stats.totalKmsDriven,       
    
    // ✅ هذه القيم ستتحدث ديناميكياً عند البحث عن سيارة معينة
    totalFleetCost: totalMaint + totalFuelCost, 
    totalFuelConsumedLiters: totalLiters,
    totalMaintenanceCost: totalMaint,
    totalFuelCost: totalFuelCost,
    
    costPerKm: stats.costPerKm,                 // نستخدم القيمة الأصلية مؤقتاً
    vehicleBreakdown: filteredBreakdown,
  );
  return TexturedBackground(
    child: SafeArea(
      child: Column(
        children: [
          AppHeader(
            title: 'Fleet Dashboard,',
            userName: auth.user?.name ?? 'Commander',
            statsText: '${app.myCars.length} VEHICLE IN FLEET', 
            actionLabel: 'home.add_car_title',
            onActionPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCarScreen())),
          ),
          Expanded(
            child: RefreshIndicator(
              // ✅ تعديل: تمرير التواريخ الحالية عند السحب للتحديث عشان الفلتر ميروحش
              onRefresh: () => fleet.loadFleetStats(
                app.myCars, 
                start: fleet.startDate, 
                end: fleet.endDate
              ),
              color: AppColors.primary,
              child: ListView(
                padding: const EdgeInsets.only(top: 15, bottom: 100),
                children: [
                  // 1. شريط البحث والتقويم
                 // داخل شاشة fleet_dashboard.dart - ميثود _buildAnalyticsTab

Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: Row(
    children: [
      Expanded(child: _buildSearchField("SEARCH FLEET BY PLATE OR MODEL...")),
      const SizedBox(width: 10),
      // ✅ استدعاء الويدجت الجاهزة بدلاً من الكود اليدوي
      _buildCalendarButton(context, fleet, app), 
    ],
  ),
),

// 2. البار الصغير جداً (الشرط والويدجت)
if (fleet.startDate != null) 
  _buildCompactDateBar(fleet, app),

// المسافة المتغيرة بناءً على وجود الفلتر
SizedBox(height: fleet.startDate != null ? 10 : 20),

// 3. جدول التوتال والرسوم البيانية
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
            title: 'Fleet Overview', 
            userName: auth.user?.name ?? 'Commander',
            statsText: '${app.myCars.length} VEHICLE IN FLEET', 
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

// أضف هذه الدوال في نهاية كلاس _FleetDashboardState

Widget _buildCalendarButton(BuildContext context, FleetProvider fleet, AppProvider app) {
  return GestureDetector(
    onTap: () => _selectDateRange(context, fleet, app),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: fleet.startDate != null ? const Color.fromARGB(255, 218, 218, 218) : Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(
        Icons.calendar_month_rounded,
        color: fleet.startDate != null ? Colors.black : AppColors.textMain,
        size: 20,
      ),
    ),
  );
}

Widget _buildCompactDateBar(FleetProvider fleet, AppProvider app) {
  return Container(
    margin: const EdgeInsets.only(top: 15, left: 20, right: 20),
    child: Row(
      children: [
        // 1. كارت البداية (FROM)
        Expanded(child: _buildSmallDateCard("", fleet.startDate!)),
        
        // 2. زرار الريلود (RESET) - في المنتصف كفاصل ذكي
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              IconButton(
                onPressed: () => fleet.loadFleetStats(app.myCars),
                icon: const Icon(Icons.refresh_rounded, color: AppColors.textMain, size: 18),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                tooltip: "Reset Period",
              ),
              const Text("RESET", style: TextStyle(color: AppColors.textMain, fontSize: 10, fontWeight: FontWeight.w900)),
            ],
          ),
        ),

        // 3. كارت النهاية (TO)
        Expanded(child: _buildSmallDateCard("", fleet.endDate!)),
      ],
    ),
  );
}

// ويدجت مساعدة لبناء الكارت الصغير بشكل متناسق
Widget _buildSmallDateCard(String label, DateTime date) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.white.withOpacity(0.1)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "$label: ", 
          style: const TextStyle(color: AppColors.textMain, fontSize: 8, fontWeight: FontWeight.bold)
        ),
        Text(
          "${date.day}/${date.month}/${date.year}",
          style: const TextStyle(
            color: AppColors.textMain, 
            fontSize: 15, 
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5
          ),
        ),
      ],
    ),
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
          prefixIcon: const Icon(Icons.search, color: AppColors.textMain), 
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