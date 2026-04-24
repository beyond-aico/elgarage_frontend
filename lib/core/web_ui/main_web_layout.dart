// lib/core/ui/web/main_web_layout.dart

import 'package:elgarage/core/app_ui/textured_background.dart';
import 'package:elgarage/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'web_navbar.dart';
import 'web_footer.dart';

class MainWebLayout extends StatelessWidget {
  final Widget child;
  const MainWebLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    bool isSmall = MediaQuery.of(context).size.width < 850;

    return Scaffold(
      backgroundColor: Colors.white,
      // إضافة قائمة جانبية تظهر فقط عند النقر على أيقونة المنيو في الموبايل
      drawer: isSmall ? _buildWebDrawer() : null,
      body: Column(
        children: [
          const WebNavbar(), 
          Expanded(
            child: Stack(
              children: [
                // طبقة الخلفية التيكستشر ثابتة
                const Positioned.fill(
                  child: TexturedBackground(
                    child: SizedBox.expand(),
                  ),
                ),
                
                // طبقة المحتوى قابلة للتمرير
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height - 80, 
                        ),
                        width: double.infinity,
                        child: child, 
                      ),
                      const WebFooter(), 
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebDrawer() {
    return Drawer(
      backgroundColor: AppColors.textMain,
      child: Column(
        children: [
          const SizedBox(height: 60),
          Image.asset('assets/images/logo.png', height: 60),
          const SizedBox(height: 40),
          _drawerItem("Marketplace"),
          _drawerItem("Services"),
          _drawerItem("About Beyond"),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              "BEYOND AI © 2026", 
              style: TextStyle(color: Colors.white10, fontSize: 10, letterSpacing: 2)
            ),
          )
        ],
      ),
    );
  }

  Widget _drawerItem(String title) {
    return ListTile(
      title: Text(
        title, 
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)
      ),
      onTap: () {},
    );
  }
}