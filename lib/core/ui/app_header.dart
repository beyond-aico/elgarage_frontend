// --- FILE: lib/core/ui/app_header.dart ---
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; 
import '../constants/app_colors.dart';
import '../../screens/more/aboutus_screen.dart'; 
import '../../screens/more/profile_screen.dart'; 
import '../../screens/cart_screen.dart'; 

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
    // ✅ الحفاظ على ارتفاع مرن للهيدر بناءً على عرض الشاشة
    final double headerHeight = screenWidth * 0.42; 

    return Stack(
      children: [
        // 1. الخلفية السوداء المقوسة (Industrial Dark)
        ClipPath(
          clipper: AdvancedWaveClipper(),
          child: Container(
            height: headerHeight, 
            width: double.infinity, 
            color: AppColors.textMain,
          ),
        ),
        
        // 2. لوجو الجراج (أعلى اليمين)
        Positioned(
          top: -15,
          right: 0,
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

        // 3. ✅ أيقونة السلة (تحت اللوجو بنسبة مرنة)
        // استخدمنا نسبة 0.22 من عرض الشاشة للنزول لأسفل لضمان عدم التصادم مع اللوجو
        Positioned(
          top: screenWidth * 0.22, 
          right: screenWidth * 0.07, 
          child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
            child: Column(
              children: [
                Icon(
                  CupertinoIcons.cart_fill, 
                  color: AppColors.primary, 
                  size: screenWidth * 0.07, // ✅ حجم أيقونة مرن
                ),
              ],
            ),
          ),
        ),

        // 4. محتوى الجانب الأيسر (بيانات المستخدم)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06, vertical: 10),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title, 
                        style: TextStyle(color: Colors.white70, fontSize: screenWidth * 0.03),
                      ),
                      // ✅ حماية الاسم من الـ Overflow باستخدام Flexible و MaxLines
                      SizedBox(
                        width: screenWidth * 0.5, // تحديد مساحة الاسم لمنعه من الوصول للسلة
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
                
                // الإحصائيات (النجوم)
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

                // مسافة مرنة قبل زر الإجراء
                SizedBox(height: headerHeight * 0.12), 
                
                // 5. زر الإجراء المركزي (Action Button)
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
                            actionLabel.toUpperCase(), 
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