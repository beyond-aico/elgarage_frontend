import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/secondary_hero_section.dart';

class SosPage extends StatelessWidget {
  const SosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SecondaryHeroSection(),
            
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    SizedBox(height: 20.h),
                    // زر الطوارئ المتوهج
                    Center(
                      child: Container(
                        width: 180.w,
                        height: 180.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red.withAlpha(05),
                          border: Border.all(color: Colors.redAccent.withAlpha(3), width: 1),
                          boxShadow: [
                            BoxShadow(color: Colors.red.withAlpha(15), blurRadius: 40, spreadRadius: 5)
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 140.w,
                            height: 140.w,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.redAccent, Color(0xFFB71C1C)], // تدرج أحمر عميق
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.redAccent, blurRadius: 20, offset: Offset(0, 10), spreadRadius: -5)
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.touch_app, color: Colors.white, size: 40.sp),
                                Text("SOS", style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 40.h),
                    
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        "Nearby Winch Services",
                        style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0), fontSize: 18.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 15.h),
                    
// داخل الـ Column:
_buildDarkListItem("winch_fast".tr(), "away_km".tr(args: ["2"]), "4.8"),
_buildDarkListItem("winch_road".tr(), "away_km".tr(args: ["5"]), "4.5"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDarkListItem(String title, String subtitle, String rating) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(color: Colors.red.withAlpha(1), borderRadius: BorderRadius.circular(10.r)),
            child: Icon(Icons.car_crash, color: Colors.redAccent, size: 24.sp),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.bold, fontSize: 16.sp)),
                Text(subtitle, style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp)),
              ],
            ),
          ),
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 16.sp),
              SizedBox(width: 4.w),
              Text(rating, style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0), fontSize: 14.sp)),
            ],
          ),
          SizedBox(width: 15.w),
          CircleAvatar(
            backgroundColor: Colors.green,
            radius: 18.r,
            child: Icon(Icons.phone, color: Colors.white, size: 18.sp),
          )
        ],
      ),
    );
  }
}