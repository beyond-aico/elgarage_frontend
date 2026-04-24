// --- FILE: lib/core/ui/app_header.dart ---
import 'package:easy_localization/easy_localization.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; 
import '../constants/app_colors.dart';
import '../../app_screens/more/aboutus_screen.dart'; 
import '../../app_screens/more/profile_screen.dart'; 
import '../../app_screens/cart_screen.dart'; 
import '../../app_screens/orders_screen.dart'; // ✅ إضافة استيراد صفحة الطلبات

class AppHeader extends StatelessWidget {
  final String title;
  final String userName; 
  final String statsText; 
  final String actionLabel;
  final VoidCallback onActionPressed;
  final IconData actionIcon;

  const AppHeader({
    super.key,
    required this.title,
    required this.userName,
    required this.statsText,
    required this.actionLabel,
    required this.onActionPressed,
    this.actionIcon = Icons.add_circle_outline,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double headerHeight = screenWidth * 0.42; 
    
    final bool isArabic = context.locale.languageCode == 'ar';

    return Stack(
      children: [
        // 1. الخلفية السوداء المقوسة
        ClipPath(
          clipper: AdvancedWaveClipper(),
          child: Container(
            height: headerHeight, 
            width: double.infinity, 
            color: AppColors.textMain,
          ),
        ),
        
        // 2. اللوجو
        Positioned(
          top: -15,
          right: isArabic ? null : 0, 
          left: isArabic ? 0 : null,  
          child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUsScreen())),
            child: Image.asset(
              'assets/images/logo.png',
              width: screenWidth * 0.25, 
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.garage, color: Colors.white24, size: 40),
            ),
          ),
        ),

        // 3. ✅ تعديل: أيقونات الطلبات والسلة معاً
        Positioned(
          top: screenWidth * 0.22, 
          right: isArabic ? null : screenWidth * 0.07,
          left: isArabic ? screenWidth * 0.07 : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // أيقونة الطلبات الجديدة
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen())),
                child: Icon(
                  Icons.receipt_long, // شكل الورقة/الطلب
                  color: AppColors.primary, 
                  size: screenWidth * 0.07, // نفس مقاس السلة بالضبط
                ),
              ),
              const SizedBox(width: 15), // مسافة بين الأيقونتين
              // أيقونة السلة الحالية
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
                child: Icon(
                  CupertinoIcons.cart_fill, 
                  color: AppColors.primary, 
                  size: screenWidth * 0.07,
                ),
              ),
            ],
          ),
        ),

        // 4. محتوى بيانات المستخدم
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06, vertical: 10),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.tr(),
                        style: TextStyle(color: Colors.white70, fontSize: screenWidth * 0.03),
                      ),
                      SizedBox(
                        width: screenWidth * 0.55, 
                        child: Text(
                          userName.toUpperCase(), 
                          style: TextStyle(
                            color: AppColors.primary, 
                            fontSize: screenWidth * 0.052, 
                            fontWeight: FontWeight.w900, 
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    const Icon(Icons.stars, color: AppColors.primary, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      statsText,
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ],
                ),

                SizedBox(height: headerHeight * 0.12), 
                
                // 5. زر الإجراء
                Center(
                  child: GestureDetector(
                    onTap: onActionPressed,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary, 
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.textMain, width: 1.5),
                        boxShadow: [BoxShadow(color: Colors.black.withAlpha(50), blurRadius: 8)],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(actionIcon, color: AppColors.textMain, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            actionLabel.tr().toUpperCase(),
                            style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w900, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AdvancedWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 45); 
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 45);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}