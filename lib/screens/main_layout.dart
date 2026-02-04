import 'package:elgarage/core/ui/app_footer.dart';
import 'package:elgarage/screens/cart_screen.dart';
import 'package:elgarage/screens/marketplace_screen.dart';
import 'package:elgarage/screens/more_screen.dart'; 
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import 'home_screen.dart';
import 'car_details_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // رقم الصفحة الحالية
  int _currentIndex = 0;

  // دالة تغيير التاب
  void _switchToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // تعريف الصفحات وربطها بالـ Index
    final List<Widget> _screens = [
      // 0: الجراج (Home)
      HomeScreen(onCarSelected: () => _switchToTab),
      
      // 1: تفاصيل السيارة المختارة
      const CarDetailsScreen(), 
      
      // 2: الماركت (يتم استدعاؤه عبر الزر المركزي)
      const MarketplaceScreen(),
      
      // 3: السلة (Basket)
      const CartScreen(),
      
      // 4: الإعدادات (Terminal)
      const MoreScreen(),
    ];

    return Scaffold(
      // مهم جداً لجعل خلفية الصفحات تظهر خلف تقويسة الفوتر والزر
      extendBody: true, 
      
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      
      // زر الماركت بليس في المنتصف (FAB) - ستايل ثابت
      floatingActionButton: FloatingActionButton(
        onPressed: () => _switchToTab(2),
        backgroundColor: AppColors.primary,
        elevation: 10,
        shape: const CircleBorder(), 
        child: const Icon(Icons.storefront, color: Colors.black, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ✅ استدعاء الفوتر الموحد الذي يحتوي على الـ BottomAppBar والـ Notch
      bottomNavigationBar: AppFooter(
        currentIndex: _currentIndex,
        onTap: _switchToTab,
      ),
    );
  }
}