import 'package:elgarage/screens/fleet/driver_screen.dart';
import 'package:elgarage/screens/fleet/fleet_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../screens/home_screen.dart';
import '../../screens/car_details_screen.dart';
import '../../screens/marketplace_screen.dart';
import '../../screens/emergency_screen.dart';
import '../../screens/more/more_screen.dart';
import '../constants/app_colors.dart';
import 'app_footer.dart';
import 'fade_indexed_stack.dart'; // ✅ استيراد الويدجت الجديد
import 'package:elgarage/providers/auth_provider.dart'; // ✅ أضف هذا الاستيراد

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  // lib/core/ui/main_layout.dart

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final int currentIndex = appProvider.currentTabIndex;

    final String? role = authProvider.user?.role.toUpperCase();

    // 1. القائد يرى الداشبورد
    if (role == "ACCOUNT_MANAGER" || role == "ADMIN") {
      return const FleetDashboard();
    }

    // 2. السائق يرى شاشة السائق (كطبقة حماية ثانية)
    if (role == "DRIVER") {
      return const DriverScreen();
    }

    // 3. المستخدم العادي يرى التابات
    final List<Widget> screens = [
      HomeScreen(onCarSelected: () => appProvider.setTabIndex(1)),
      const CarDetailsScreen(),
      const MarketplaceScreen(),
      const EmergencyScreen(),
      const MoreScreen(),
    ];

    return PopScope(
      canPop: currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        appProvider.setTabIndex(0);
      },
      child: Scaffold(
        extendBody: true,
        body: FadeIndexedStack(index: currentIndex, children: screens),
        bottomNavigationBar: AppFooter(
          currentIndex: currentIndex,
          onTap: (index) => appProvider.setTabIndex(index),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => appProvider.setTabIndex(2),
          backgroundColor: AppColors.primary,
          shape: const CircleBorder(),
          child: const Icon(Icons.storefront, color: Colors.black, size: 28),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
