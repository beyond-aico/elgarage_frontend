import 'package:elgarage/core/ui/app_footer.dart';
import 'package:elgarage/providers/app_provider.dart';
import 'package:elgarage/screens/marketplace_screen.dart';
import 'package:elgarage/screens/more/more_screen.dart';
import 'package:elgarage/screens/emergency_screen.dart'; 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../../screens/home_screen.dart';
import '../../screens/car_details_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // ✅ تم حذف _currentIndex و _switchToTab لأننا بنستخدم البروفايدر الآن

  @override
  Widget build(BuildContext context) {
    // ✅ تعريف appProvider عشان نقدر نستخدمه في كل مكان جوه الـ build
    final appProvider = Provider.of<AppProvider>(context);
    final int currentIndex = appProvider.currentTabIndex;

    final List<Widget> screens = [
      HomeScreen(onCarSelected: () => appProvider.setTabIndex(1)), // 0: الجراج
      const CarDetailsScreen(), // 1: التفاصيل
      const MarketplaceScreen(), // 2: الماركت
      const EmergencyScreen(), // 3: الطوارئ
      const MoreScreen(), // 4: المزيد
    ];

    return PopScope(
      // يسمح بالخروج فقط لو المستخدم في "الجراج" (Tab 0)
      canPop: currentIndex == 0, 
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // ✅ العودة للهوم عن طريق البروفايدر
        appProvider.setTabIndex(0);
      },
      child: Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: currentIndex, 
          children: screens,
        ),
        
        // زر الماركت بليس في المنتصف
        floatingActionButton: FloatingActionButton(
          onPressed: () => appProvider.setTabIndex(2), // الانتقال للماركت
          backgroundColor: AppColors.primary,
          elevation: 10,
          shape: const CircleBorder(), 
          child: const Icon(Icons.storefront, color: Colors.black, size: 28),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        // الفوتر المربوط بالبروفايدر
        bottomNavigationBar: AppFooter(
          currentIndex: currentIndex,
          onTap: (index) => appProvider.setTabIndex(index),
        ),
      ),
    );
  }
}