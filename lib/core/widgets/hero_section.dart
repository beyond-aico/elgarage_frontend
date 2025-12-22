import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants/app_colors.dart';
import 'global_search_delegate.dart';

class HeroSection extends StatefulWidget {
  final bool enableSearch;
  final Function(String)? onSearch;
  final String userName;
  final String carModel;

  const HeroSection({
    super.key,
    this.enableSearch = true,
    this.onSearch,
    this.userName = "Auto-Mentor",
    this.carModel = "Kia Cerato 2023",
  });

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. تقليل ارتفاع الهيرو ليصبح مضغوطاً
    final double heroHeight = 220.h; 

    return SizedBox(
      height: heroHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // الخلفية المتحركة
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _BlobsPainter(progress: _controller.value),
              );
            },
          ),

          // المحتوى
          Padding(
            // 2. تقليل المسافة العلوية (كانت 60 أصبحت 10)
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 15.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center, // توسيط المحتوى عمودياً
              children: [
                // الصف العلوي
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/profile'),
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary.withAlpha(1), width: 1.5),
                        ),
                        child: CircleAvatar(
                          radius: 20.r, // تصغير الحجم قليلاً
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, color: AppColors.primary, size: 22.sp),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "welcome".tr(), 
                          // 3. تصحيح اللون ليظهر على الخلفية الفاتحة
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp),
                        ),
                        Text(
                          widget.userName, 
                          // 3. تصحيح اللون ليظهر داكناً
                          style: TextStyle(color: AppColors.textPrimary, fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Spacer(),
                    
              _buildGlassIconButton(Icons.language, () async { // 1. أضفنا async هنا
                      if (context.locale.languageCode == 'en') {
                        await context.setLocale(const Locale('ar')); // 2. أضفنا await هنا
                      } else {
                        await context.setLocale(const Locale('en')); // 2. أضفنا await هنا
                      }
                      // هذا السطر يجبر الواجهة على التحديث فوراً
                      setState(() {}); 
                    }),
                    SizedBox(width: 8.w),
                    _buildGlassIconButton(Icons.garage_outlined, () {
                      Navigator.pushNamed(context, '/garage');
                    }),
                  ],
                ),

                // تقليل المسافات البينية
                SizedBox(height: 20.h), // كانت 30

Text(
  "hero_slogan".tr(args: [widget.carModel]), // استخدام args للباراميتر
  style: TextStyle(
    color: AppColors.primary,
    fontSize: 22.sp,
    fontWeight: FontWeight.w800,
    height: 1.2,
  ),
),

                SizedBox(height: 20.h), // كانت 25

                // شريط البحث
                if (widget.enableSearch)
                  GestureDetector(
                    onTap: () {
                      showSearch(context: context, delegate: GlobalSearchDelegate());
                    },
                    child: Container(
                      height: 45.h, // ارتفاع مناسب
                      padding: EdgeInsets.symmetric(horizontal: 15.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: Colors.black.withAlpha(05)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(03), // ظل خفيف جداً
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: AppColors.primary, size: 22.sp),
                          SizedBox(width: 10.w),
                          Text(
                            "search_hint".tr(),
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp),
                          ),
                          const Spacer(),
                          Icon(Icons.tune, color: AppColors.textSecondary, size: 18.sp),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(8), // زيادة الشفافية للأبيض
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.black.withAlpha(05)),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20.sp),
      ),
    );
  }
}

// (BlobsPainter يظل كما هو، لا يحتاج تعديل لأنه يستخدم ألوان فاتحة بالفعل)
class _BlobsPainter extends CustomPainter {
  final double progress;
  _BlobsPainter({required this.progress});

  final Color c1 = const Color(0xFFE0E7FF); 
  final Color c2 = const Color(0xFFF3F4F6);

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFFAFAFA);
    canvas.drawRect(Offset.zero & size, bg);

    double t(double base, double amp, double speed, double phase) {
      return base + math.sin((progress * 2 * math.pi * speed) + phase) * amp;
    }

    _drawBlob(canvas, center: Offset(t(size.width * 0.8, 30, 1.0, 0), t(size.height * 0.2, 20, 1.2, 1.0)), baseRadius: size.shortestSide * 0.4, color: c1.withAlpha(4));
    _drawBlob(canvas, center: Offset(t(size.width * 0.1, 40, 0.8, 2.0), t(size.height * 0.6, 30, 0.9, 0.5)), baseRadius: size.shortestSide * 0.5, color: c2);
  }

  void _drawBlob(Canvas canvas, {required Offset center, required double baseRadius, required Color color}) {
    final paint = Paint()..color = color..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);
    canvas.drawCircle(center, baseRadius, paint);
  }

  @override
  bool shouldRepaint(covariant _BlobsPainter oldDelegate) => oldDelegate.progress != progress;
}