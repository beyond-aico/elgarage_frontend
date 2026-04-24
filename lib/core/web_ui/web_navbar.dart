// lib/core/ui/web/web_navbar.dart

import 'package:elgarage/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class WebNavbar extends StatelessWidget {
  const WebNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    // تحديد ما إذا كانت الشاشة موبايل كروم (أقل من 850 بكسل)
    bool isSmall = MediaQuery.of(context).size.width < 850;

    return Container(
      height: 80,
      padding: EdgeInsets.symmetric(horizontal: isSmall ? 20 : 60),
      color: AppColors.textMain, 
      child: Row(
        children: [
          if (isSmall)
            IconButton(
              icon: const Icon(Icons.menu, color: AppColors.primary),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          
          Image.asset(
            'assets/images/logo.png',
            height: isSmall ? 30 : 45,
            errorBuilder: (c, e, s) => const Icon(
              Icons.garage_rounded,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 15),
          Text(
            "ELGARAGE",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
              fontSize: isSmall ? 16 : 20,
              letterSpacing: 2,
            ),
          ),

          const Spacer(),

          // إخفاء الروابط في الشاشات الصغيرة وتوفير مساحة
          if (!isSmall) ...[
            _navLink("Marketplace"),
            _navLink("Services"),
            _navLink("About Beyond"),
            const SizedBox(width: 40),
          ],

          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textMain,
              padding: EdgeInsets.symmetric(
                horizontal: isSmall ? 15 : 25, 
                vertical: isSmall ? 12 : 18
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text(
              isSmall ? "LOGIN" : "TERMINAL LOGIN",
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navLink(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: TextButton(
        onPressed: () {},
        child: Text(
          title,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}