import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/secondary_hero_section.dart';

class TiresBatteriesPage extends StatelessWidget {
  const TiresBatteriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // 1. الهيرو الثانوي (ثابت)
              const SecondaryHeroSection(),
              
              // 2. باقي المحتوى (يحتوي على السلايدر والتابات والقائمة)
              Expanded(
                child: Column(
                  children: [
                    SizedBox(height: 20.h),
                    
                    // أ. سلايدر الإعلانات
                    _buildPromoSlider(),
                    
                    SizedBox(height: 15.h),

                    // ب. التبويبات (Tabs)
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.w),
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.black.withOpacity(0.05)),
                      ),
                      child: TabBar(
                        indicator: BoxDecoration(
                          color: Colors.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.orange.withOpacity(0.5)),
                        ),
                        labelColor: Colors.orange, // لون النشط
                        unselectedLabelColor: AppColors.textSecondary, // لون غير النشط
                        dividerColor: Colors.transparent,
                        labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                        tabs: [
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.circle_outlined),
                                SizedBox(width: 8.w),
                                Text("tires_tab".tr()) // "Tires"
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.battery_charging_full),
                                SizedBox(width: 8.w),
                                Text("battery_tab".tr()) // "Battery"
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 15.h),

                    // ج. منطقة العرض (TabBarView)
                    Expanded(
                      child: TabBarView(
                        children: [
                          // القائمة الأولى (إطارات)
                          _buildList([
                            {'title': 'shop_fit_fix'.tr(), 'sub': 'serv_tire_repair'.tr(), 'status': 'open_now'.tr()},
                            {'title': 'shop_bridgestone'.tr(), 'sub': 'serv_new_tires'.tr(), 'status': 'status_closing_soon'.tr()},
                          ], Icons.circle_outlined, Colors.orange),

                          // القائمة الثانية (بطاريات)
                          _buildList([
                            {'title': 'shop_battery_pro'.tr(), 'sub': 'serv_jump_start'.tr(), 'status': 'status_available'.tr()},
                            // تأكدنا من وجود المفتاح الصحيح هنا
                            {'title': 'shop_battery_pro'.tr(), 'sub': 'serv_new_tires'.tr(), 'status': 'open_now'.tr()}, 
                          ], Icons.battery_std, Colors.green),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widgets المساعدة ---

  Widget _buildPromoSlider() {
    return SizedBox(
      height: 160.h,
      child: PageView(
        controller: PageController(viewportFraction: 0.9),
        padEnds: false,
        children: [
          _buildBannerItem(
            [const Color(0xFFF97316), const Color(0xFFC2410C)], 
            "Buy 3 Get 1 Free", 
            "On selected Tire\nbrands", 
            Icons.motion_photos_on
          ),
          _buildBannerItem(
            [const Color(0xFF84CC16), const Color(0xFF4D7C0F)], 
            "Battery Check", 
            "Free health check\n& Installation", 
            Icons.battery_charging_full
          ),
        ],
      ),
    );
  }

  Widget _buildBannerItem(List<Color> colors, String title, String sub, IconData icon) {
    return Container(
      margin: EdgeInsets.only(right: 10.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors), 
        borderRadius: BorderRadius.circular(20.r), 
        boxShadow: [BoxShadow(color: colors[0].withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20.w, bottom: -20.h, 
            child: Icon(icon, size: 120.sp, color: Colors.white.withOpacity(0.1))
          ),
          Padding(
            padding: EdgeInsets.all(24.w), 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              mainAxisAlignment: MainAxisAlignment.center, 
              children: [
                Text(title, style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)), 
                SizedBox(height: 8.h), 
                Text(sub, style: TextStyle(color: Colors.white70, fontSize: 14.sp))
              ]
            )
          )
        ]
      ),
    );
  }

  Widget _buildList(List<Map<String, String>> items, IconData icon, Color color) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.w), // Padding للقائمة
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          margin: EdgeInsets.only(bottom: 15.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: color, size: 28.sp),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['title']!, style: TextStyle(color: AppColors.textPrimary, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4.h),
                    Text(item['sub']!, style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp)),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(item['status']!, style: TextStyle(color: AppColors.textSecondary, fontSize: 10.sp, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        );
      },
    );
  }
}