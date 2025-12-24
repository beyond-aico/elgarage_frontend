import 'package:elgarage/screens/cart_screen.dart';
import 'package:elgarage/screens/marketplace_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // عشان أيقونات iOS الشيك
import '../core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'home_screen.dart';
import 'car_details_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // رقم الصفحة الحالية (بتبدأ بـ 0 يعني الهوم)
  int _currentIndex = 0;

  // قائمة الصفحات (هنستبدلهم بالصفحات الحقيقية لما نبنيهم)
  final List<Widget> _screens = [
    const HomeScreen(),       // 0
    const CarDetailsScreen(), // 1
    const MarketplaceScreen(), // 2
    const CartScreen(),       // 3
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // الجسم: بيعرض الصفحة حسب الاختيار
      body: SafeArea(
        child: _screens[_currentIndex],
      ),

      // الفوتر (Bottom Navigation Bar)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed, // عشان الأيقونات ما تتحركش وتكبر
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary, // لون الأيقونة المختارة
          unselectedItemColor: Colors.grey,     // لون الأيقونة غير المختارة
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          
          items: const [
            // 1. Home
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.house_fill),
              label: 'Home',
            ),
            // 2. Car Page (Details)
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.car_detailed),
              label: 'My Car',
            ),
            // 3. Marketplace
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.bag_fill),
              label: 'Market',
            ),
            // 4. Cart
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.cart_fill),
              label: 'Cart',
            ),
          ],
        ),
      ),
    );
  }
}