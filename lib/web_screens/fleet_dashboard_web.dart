import 'package:elgarage/web_screens/add_car_web_screen.dart';
import 'package:elgarage/web_screens/car_details_web_screen.dart';
import 'package:elgarage/web_screens/emergency_web_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart';
import '../core/ui/textured_background.dart';
import '../widgets/car_card.dart';
import 'marketplace_web_screen.dart'; // ✅ تأكد من استدعاء ملف الويبimport '../screens/emergency_screen.dart';
import '../screens/more/more_screen.dart';

class FleetDashboardWeb extends StatefulWidget {
  const FleetDashboardWeb({super.key});

  @override
  State<FleetDashboardWeb> createState() => _FleetDashboardWebState();
}

class _FleetDashboardWebState extends State<FleetDashboardWeb> {
  String searchQuery = "";
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        final app = Provider.of<AppProvider>(context, listen: false);
        await app.fetchMyCars(role: auth.user?.role);
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

    // قائمة الشاشات زي الموبايل بالظبط
    final List<Widget> webScreens = [
      _buildDashboardHomeWeb(provider, auth),
      const CarDetailsWebScreen(),
      const MarketplaceWebScreen(),
      const EmergencyWebScreen(),
      const MoreScreen(),
    ];

    return TexturedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Row(
          children: [
            // 1. القائمة الجانبية (Side Sidebar) بمقاسات مظبوطة
            _buildSidebar(auth),

            // 2. منطقة المحتوى الأساسي (Content Area)
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: webScreens,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // بناء السايد بار بنفس أيقونات الموبايل
  Widget _buildSidebar(AuthProvider auth) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppColors.textMain.withOpacity(0.95),
        border: const Border(right: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        children: [
          _buildSidebarHeader(),
          const SizedBox(height: 20),
          _buildSidebarItem(0, Icons.dashboard_rounded, "DASHBOARD"),
          _buildSidebarItem(1, Icons.directions_car_filled_rounded, "CAR DETAILS"),
          _buildSidebarItem(2, Icons.local_shipping, "MARKETPLACE"),
          _buildSidebarItem(3, Icons.emergency_share_rounded, "EMERGENCY"),
          _buildSidebarItem(4, Icons.more_horiz_rounded, "MORE"),
          const Spacer(),
          _buildSidebarItem(-1, Icons.logout_rounded, "LOGOUT", onTap: () => auth.logout()),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Image.asset('assets/images/logo.png', height: 70),
          const SizedBox(height: 15),
          const Text("EL GARAGE", style: TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const Text("WEB TERMINAL", style: TextStyle(color: Colors.white24, fontSize: 9, letterSpacing: 1.5)),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String title, {VoidCallback? onTap}) {
    bool isSelected = _currentIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      child: ListTile(
        onTap: onTap ?? () => _switchToTab(index),
        selected: isSelected,
        leading: Icon(icon, color: isSelected ? AppColors.primary : Colors.white30),
        title: Text(title, style: TextStyle(color: isSelected ? AppColors.primary : Colors.white30, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
      ),
    );
  }

  // بناء الصفحة الرئيسية للويب (دمج الجرافات والكروت)
  Widget _buildDashboardHomeWeb(AppProvider provider, AuthProvider auth) {
    final filteredCars = provider.myCars.where((car) {
      final query = searchQuery.toLowerCase();
      return car.make.toLowerCase().contains(query) || car.model.toLowerCase().contains(query) || (car.licensePlate ?? "").toLowerCase().contains(query);
    }).toList();

    Map<String, List> groupedCars = {};
    for (var car in filteredCars) {
      groupedCars.putIfAbsent("${car.make} ${car.model}".toUpperCase(), () => []).add(car);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWebHeader(auth, provider),
          const SizedBox(height: 30),
          _buildSearchField(),
          const SizedBox(height: 40),
          
          _buildSectionTitle("ANALYTIC INSIGHTS"),
          const SizedBox(height: 15),
          // الجرافات في Row واحد للويب لاستغلال المساحة
          Row(
            children: [
              Expanded(child: _buildVerticalBarChart("FUEL USAGE (GAL)", ["S", "M", "T", "W", "T", "F", "S"], [0.3, 0.7, 0.5, 0.9, 0.4, 0.2, 0.6], Colors.blue)),
              const SizedBox(width: 20),
              Expanded(child: _buildVerticalBarChart("ACTIVE HOURS", ["W1", "W2", "W3", "W4"], [0.8, 0.6, 0.9, 0.7], AppColors.primary)),
            ],
          ),

          const SizedBox(height: 40),
          _buildSectionTitle("FLEET INVENTORY"),
          if (provider.isLoadingCars)
            const Center(child: Padding(padding: EdgeInsets.all(50), child: CircularProgressIndicator(color: Colors.amber)))
          else
            ...groupedCars.entries.map((entry) => _buildModelSlideshow(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildWebHeader(AuthProvider auth, AppProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("WELCOME BACK,", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, letterSpacing: 2)),
            Text(auth.user?.name ?? 'Fleet Commander', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCarWebScreen())),
          icon: const Icon(Icons.add, color: Colors.black),
          label: const Text("GROW MY FLEET", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20)),
        )
      ],
    );
  }

  Widget _buildVerticalBarChart(String title, List<String> labels, List<double> values, Color color) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.textMain, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(labels.length, (i) => Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    width: 25, // أعرض شوية للويب
                    height: 120 * values[i],
                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6), boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8)]),
                  ),
                  const SizedBox(height: 8),
                  Text(labels[i], style: const TextStyle(color: Colors.white30, fontSize: 10)),
                ],
              )),
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
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(modelTitle, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white, letterSpacing: 1)),
        ),
        SizedBox(
          height: 340,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: cars.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 20),
                child: SizedBox(
                  width: 340,
                  child: CarCard(
                    car: cars[index],
                    onTap: () {
                      Provider.of<AppProvider>(context, listen: false).setSelectedCar(cars[index]);
                      _switchToTab(1);
                    },
                    isSelected: false,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.primary, letterSpacing: 2));
  }

  Widget _buildSearchField() {
    return SizedBox(
      width: 500, // تحديد عرض حقل البحث في الويب عشان ميبقاش عريض أوي
      child: TextField(
        onChanged: (v) => setState(() => searchQuery = v),
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: "SEARCH FLEET BY PLATE OR MODEL...",
          prefixIcon: const Icon(Icons.search, color: AppColors.textMain),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
        ),
      ),
    );
  }
}