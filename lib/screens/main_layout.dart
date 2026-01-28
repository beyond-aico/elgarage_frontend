import 'package:elgarage/screens/cart_screen.dart';
import 'package:elgarage/screens/marketplace_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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

  // دالة لتغيير التاب من الخارج (مثلاً من الهوم سكرين)
  void _switchToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // تعريف الصفحات هنا عشان نقدر نمرر دالة _switchToTab
    final List<Widget> screens = [
      // 0: Home (مررنا لها الدالة عشان لما نختار عربية تحولنا لتاب 1)
      HomeScreen(onCarSelected: () => _switchToTab(1)),
      
      // 1: My Car Details
      const CarDetailsScreen(), 
      
      // 2: Marketplace
      const MarketplaceScreen(),
      
      // 3: Cart
      const CartScreen(),
    ];

    return Scaffold(
      // الجسم
      body: SafeArea(
        child: IndexedStack( // استخدام IndexedStack بيحفظ حالة الصفحات لما تتنقل بينهم
          index: _currentIndex,
          children: screens,
        ),
      ),

      // الفوتر
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
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
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.house_fill),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.car_detailed),
              label: 'My Car',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.bag_fill),
              label: 'Market',
            ),
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