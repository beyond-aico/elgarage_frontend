import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants/app_colors.dart';
import 'global_search_delegate.dart';

class SecondaryHeroSection extends StatefulWidget {
  const SecondaryHeroSection({super.key});

  @override
  State<SecondaryHeroSection> createState() => _SecondaryHeroSectionState();
}

class _SecondaryHeroSectionState extends State<SecondaryHeroSection> with SingleTickerProviderStateMixin {
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
    // ارتفاع صغير جداً ومناسب
    final double heroHeight = 130.h; 

    return SizedBox(
      height: heroHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _BlobsPainter(progress: _controller.value),
              );
            },
          ),

          Padding(
            // تقليل الـ Top Padding
            padding: EdgeInsets.fromLTRB(20.w, 15.h, 20.w, 10.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Kia Cerato 2023", 
                          // لون نص داكن
                          style: TextStyle(color: AppColors.textPrimary, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                        Text("my_garage".tr(), 
                          // لون نص رمادي
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp)),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(6),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Colors.black.withAlpha(05)),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.garage_outlined, color: AppColors.primary),
                        onPressed: () => Navigator.pushNamed(context, '/garage'),
                        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 15.h),

                GestureDetector(
                  onTap: () {
                    showSearch(context: context, delegate: GlobalSearchDelegate());
                  },
                  child: Container(
                    height: 40.h,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.black.withAlpha(05)),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 2))
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: AppColors.textSecondary, size: 20.sp),
                        SizedBox(width: 10.w),
                        Text(
                          "search_hint".tr(),
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp),
                        ),
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
}

// نفس الـ Painter (تكراره هنا اختياري لضمان العمل لو الملف منفصل)
class _BlobsPainter extends CustomPainter {
  final double progress;
  _BlobsPainter({required this.progress});
  final Color c1 = const Color(0xFFE0E7FF);
  final Color c2 = const Color(0xFFF3F4F6);
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFFAFAFA);
    canvas.drawRect(Offset.zero & size, bg);
    double t(double base, double amp, double speed, double phase) => base + math.sin((progress * 2 * math.pi * speed) + phase) * amp;
    _drawBlob(canvas, center: Offset(t(size.width * 0.8, 20, 1.0, 0), t(size.height * 0.2, 10, 1.2, 1.0)), baseRadius: size.shortestSide * 0.4, color: c1.withAlpha(4));
    _drawBlob(canvas, center: Offset(t(size.width * 0.1, 20, 0.8, 2.0), t(size.height * 0.6, 15, 0.9, 0.5)), baseRadius: size.shortestSide * 0.5, color: c2);
  }
  void _drawBlob(Canvas canvas, {required Offset center, required double baseRadius, required Color color}) {
    final paint = Paint()..color = color..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);
    canvas.drawCircle(center, baseRadius, paint);
  }
  @override
  bool shouldRepaint(covariant _BlobsPainter oldDelegate) => oldDelegate.progress != progress;
}