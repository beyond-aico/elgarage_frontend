import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/secondary_hero_section.dart';

class MaintenancePage extends StatelessWidget {
  const MaintenancePage({super.key});

  @override
  Widget build(BuildContext context) {
    // بيانات الورش
    final workshops = [
      {'name': 'shop_top_gear'.tr(), 'specialty': 'spec_german'.tr(), 'services': ['serv_engine'.tr(), 'serv_trans'.tr()], 'rating': '4.9', 'distance': '2.5 km', 'isOpen': true},
      {'name': 'shop_auto_elec'.tr(), 'specialty': 'spec_diag'.tr(), 'services': ['serv_sensors'.tr(), 'serv_ecu'.tr()], 'rating': '4.7', 'distance': '4.1 km', 'isOpen': true},
      {'name': 'shop_suspension'.tr(), 'specialty': 'spec_chassis'.tr(), 'services': ['serv_shocks'.tr(), 'tires_tab'.tr()], 'rating': '4.5', 'distance': '6.0 km', 'isOpen': false},
    ];

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
                    // 1. سلايدر
                    _buildPromoSlider(),
                    SizedBox(height: 25.h),

                    // 2. الأقسام (Filters)
                    Text("care_categories".tr(), style: TextStyle(color: AppColors.textPrimary, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 15.h),
                    SizedBox(
                      height: 100.h,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildCategoryItem("cat_engine", Icons.engineering),
                          _buildCategoryItem("cat_electrical", Icons.electric_bolt),
                          _buildCategoryItem("cat_body", Icons.car_crash),
                          _buildCategoryItem("cat_access", Icons.settings),
                        ],
                      ),
                    ),

                    SizedBox(height: 30.h),

                    // 3. قائمة الورش
                    Text("top_centers".tr(), style: TextStyle(color: AppColors.textPrimary, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 15.h),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: workshops.length,
                      itemBuilder: (context, index) => _buildWorkshopCard(workshops[index]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoSlider() {
    return SizedBox(
      height: 160.h,
      child: PageView(
        controller: PageController(viewportFraction: 0.9),
        padEnds: false,
        children: [
          _buildBannerItem([Color(0xFF3B82F6), Color(0xFF1D4ED8)], "Free Inspection", "Book your maintenance\nthis week", Icons.build_circle),
          _buildBannerItem([Color(0xFF10B981), Color(0xFF047857)], "Oil Change Pkg", "Includes Filter & \nCheckup", Icons.water_drop),
        ],
      ),
    );
  }
  
  // (Helper methods duplicated to keep file self-contained as requested)
  Widget _buildBannerItem(List<Color> colors, String title, String sub, IconData icon) {
    return Container(
      margin: EdgeInsets.only(right: 10.w),
      decoration: BoxDecoration(gradient: LinearGradient(colors: colors), borderRadius: BorderRadius.circular(20.r), boxShadow: [BoxShadow(color: colors[0].withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Stack(children: [Positioned(right: -20.w, bottom: -20.h, child: Icon(icon, size: 120.sp, color: Colors.white.withOpacity(0.1))), Padding(padding: EdgeInsets.all(24.w), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(title, style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)), SizedBox(height: 8.h), Text(sub, style: TextStyle(color: Colors.white70, fontSize: 14.sp))]))]),
    );
  }

  Widget _buildCategoryItem(String titleKey, IconData icon) {
    return Container(
      width: 100.w,
      margin: EdgeInsets.only(right: 12.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: Colors.black.withOpacity(0.05)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))]),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: Colors.blueAccent, size: 32.sp), SizedBox(height: 8.h), Text(titleKey.tr(), textAlign: TextAlign.center, style: TextStyle(color: AppColors.textPrimary, fontSize: 12.sp, fontWeight: FontWeight.w600))]),
    );
  }

  Widget _buildWorkshopCard(Map<String, Object> shop) {
    bool isOpen = shop['isOpen'] as bool;
    var services = shop['services'] as List<String>;
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r), border: Border.all(color: Colors.black.withOpacity(0.05)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: EdgeInsets.all(20.w), decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(shop['name'] as String, style: TextStyle(color: AppColors.textPrimary, fontSize: 18.sp, fontWeight: FontWeight.bold)), SizedBox(height: 4.h), Text(shop['specialty'] as String, style: TextStyle(color: AppColors.accent, fontSize: 12.sp, fontWeight: FontWeight.w600))]), Container(padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h), decoration: BoxDecoration(color: isOpen ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(20.r), border: Border.all(color: isOpen ? Colors.green : Colors.red, width: 1)), child: Text(isOpen ? "open_now".tr() : "closed".tr(), style: TextStyle(color: isOpen ? Colors.green : Colors.red, fontSize: 10.sp, fontWeight: FontWeight.bold)))])),
        Padding(padding: EdgeInsets.all(20.w), child: Column(children: [Wrap(spacing: 8.w, children: services.map((s) => Chip(label: Text(s, style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)), backgroundColor: AppColors.background, side: BorderSide.none, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)))).toList()), SizedBox(height: 15.h), Divider(color: Colors.grey.withOpacity(0.2)), SizedBox(height: 10.h), Row(children: [Icon(Icons.location_on, color: AppColors.textSecondary, size: 16.sp), Text(" ${shop['distance']}", style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp)), Spacer(), Icon(Icons.star, color: Colors.amber, size: 16.sp), Text(" ${shop['rating']}", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14.sp))])])),
      ]),
    );
  }
}