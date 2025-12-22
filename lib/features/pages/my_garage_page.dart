import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/secondary_hero_section.dart';

class MyGaragePage extends StatelessWidget {
  const MyGaragePage({super.key});

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // كارت السيارة الرئيسي
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF0F172A)]), // داكن ليعطي فخامة
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [BoxShadow(color: Colors.black.withAlpha(2), blurRadius: 15, offset: const Offset(0, 5))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Kia Cerato", style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold)),
                                  Text("2023 • Sedan • Black", style: TextStyle(color: Colors.white70, fontSize: 14.sp)),
                                ],
                              ),
                              Icon(Icons.check_circle, color: Colors.greenAccent, size: 28.sp),
                            ],
                          ),
                          SizedBox(height: 20.h),
                          // صورة تقريبية للسيارة
                          Center(child: Icon(Icons.directions_car_filled, size: 100.sp, color: Colors.white24)),
                          SizedBox(height: 20.h),
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12.r)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                            _buildStat("stat_mileage".tr(), "45,000 km"),
_buildStat("stat_fuel".tr(), "65%"),
_buildStat("stat_oil_life".tr(), "80%"),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 30.h),
                    Text("Maintenance Schedule", style: TextStyle(color: AppColors.textPrimary, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 15.h),
                    
                  _buildServiceItem("serv_oil_change".tr(), "status_done".tr(args: ["10 Sep"]), true),
_buildServiceItem("serv_tire_rotation".tr(), "status_due_km".tr(args: ["2000"]), false),
_buildServiceItem("serv_brake_insp".tr(), "status_due_month".tr(), false),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.white54, fontSize: 12.sp)),
        SizedBox(height: 4.h),
        Text(value, style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildServiceItem(String title, String subtitle, bool isDone) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.black.withAlpha(05)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: isDone ? Colors.green.withAlpha(1) : Colors.orange.withAlpha(1),
              shape: BoxShape.circle,
            ),
            child: Icon(isDone ? Icons.check : Icons.schedule, color: isDone ? Colors.green : Colors.orange, size: 20.sp),
          ),
          SizedBox(width: 15.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16.sp)),
              Text(subtitle, style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp)),
            ],
          )
        ],
      ),
    );
  }
}