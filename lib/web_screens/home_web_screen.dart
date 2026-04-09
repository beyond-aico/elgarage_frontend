// lib/web_screens/home_web_screen.dart

import 'package:elgarage/web_screens/add_car_web_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart';
import '../core/ui/textured_background.dart';
import '../widgets/car_card.dart';

// استيراد الشاشات للتبديل (نفس نظام الفليت)
import 'marketplace_web_screen.dart';
import 'car_details_web_screen.dart';
import 'emergency_web_screen.dart';
import '../screens/more/more_screen.dart';

class HomeWebScreen extends StatefulWidget {
  const HomeWebScreen({super.key});

  @override
  State<HomeWebScreen> createState() => _HomeWebScreenState();
}

class _HomeWebScreenState extends State<HomeWebScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final role = Provider.of<AuthProvider>(context, listen: false).user?.role;
      Provider.of<AppProvider>(context, listen: false).fetchMyCars(role: role);
    });
  }

  void _switchToTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    // قائمة الشاشات المتاحة لليوزر العادي
    final List<Widget> userWebScreens = [
      _buildUserDashboardHome(provider, auth),
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
            // 1. السايد بار الموحد (نفس التصميم لضمان الثبات البصري)
            _buildSidebar(auth),

            // 2. منطقة المحتوى (Main Stage)
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: userWebScreens,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- بناء محتوى الداشبورد الشخصي ---
  Widget _buildUserDashboardHome(AppProvider provider, AuthProvider auth) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWebHeader(auth, provider),
          
          const SizedBox(height: 50),
          
          _buildSectionTitle("MY PERSONAL GARAGE"),
          const SizedBox(height: 25),

          if (provider.isLoadingCars)
            const Center(child: Padding(padding: EdgeInsets.all(100), child: CircularProgressIndicator(color: Colors.amber)))
          else if (provider.myCars.isEmpty)
            _buildEmptyStateWeb()
          else
            // عرض السيارات في شبكة (Grid) بدلاً من قائمة طولية
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 سيارات في الصف الواحد للويب
                childAspectRatio: 1.1,
                crossAxisSpacing: 25,
                mainAxisSpacing: 25,
              ),
              itemCount: provider.myCars.length,
              itemBuilder: (context, index) {
                final car = provider.myCars[index];
                return CarCard(
                  car: car,
                  isSelected: provider.selectedCar?.id == car.id,
                  onTap: () {
                    provider.setSelectedCar(car);
                    _switchToTab(1); // الانتقال لتابة التفاصيل
                  },
                );
              },
            ),
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
            Text("WELCOME BACK,", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(auth.user?.name ?? 'User', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 5),
            Text("${provider.myCars.length} VEHICLES SECURED IN GARAGE", style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCarWebScreen())),
          icon: const Icon(Icons.add_circle_outline, color: Colors.black),
          label: const Text("ADD NEW VEHICLE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 22),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        )
      ],
    );
  }

  // --- السايد بار الموحد (Beyond AI Standard) ---
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
          _buildSidebarItem(0, Icons.home_filled, "MY GARAGE"),
          _buildSidebarItem(1, Icons.directions_car_filled_rounded, "VEHICLE STATUS"),
          _buildSidebarItem(2, Icons.local_shipping, "MARKETPLACE"),
          _buildSidebarItem(3, Icons.emergency_share_rounded, "EMERGENCY"),
          _buildSidebarItem(4, Icons.more_horiz_rounded, "ACCOUNT"),
          const Spacer(),
          _buildSidebarItem(-1, Icons.logout_rounded, "LOGOUT SESSION", onTap: () => auth.logout()),
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
          const Text("USER TERMINAL", style: TextStyle(color: Colors.white24, fontSize: 9, letterSpacing: 1.5)),
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

  Widget _buildSectionTitle(String text) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.primary, letterSpacing: 2));
  }

  Widget _buildEmptyStateWeb() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 50),
          Icon(Icons.directions_car_outlined, size: 100, color: Colors.white10),
          const SizedBox(height: 20),
          const Text("YOUR GARAGE IS EMPTY", style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCarWebScreen())),
            child: const Text("REGISTER YOUR FIRST CAR NOW", style: TextStyle(color: AppColors.primary)),
          )
        ],
      ),
    );
  }
}