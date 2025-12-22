import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/secondary_hero_section.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

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
                    _buildPromoSlider(),
                    SizedBox(height: 25.h),

                    // الأقسام (Routine Checks)
                    Text("routine_checks".tr(), style: TextStyle(color: AppColors.textPrimary, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 15.h),
                    
                    SizedBox(
                      height: 100.h,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildCategoryItem("check_engine_oil", Icons.water_drop, Colors.amber),
                          _buildCategoryItem("check_filters", Icons.filter_alt, Colors.grey),
                          _buildCategoryItem("check_coolant", Icons.ac_unit, Colors.blue),
                          _buildCategoryItem("check_brakes", Icons.warning, Colors.red),
                        ],
                      ),
                    ),

                    SizedBox(height: 30.h),

                    // المحطات
                    Text("nearby_stations".tr(), style: TextStyle(color: AppColors.textPrimary, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 15.h),
                    _buildStationTile("station_mobil".tr(), "serv_oil_filters".tr(), "0.5 km"),
                    _buildStationTile("station_total".tr(), "serv_fluids".tr(), "1.2 km"),
                    _buildStationTile("station_shell".tr(), "serv_full_checkup".tr(), "2.0 km"),
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
          _buildBannerItem([Color(0xFFF59E0B), Color(0xFFD97706)], "Quick Oil Change", "Done in 15 mins\nNo appointment", Icons.timelapse),
          _buildBannerItem([Color(0xFF14B8A6), Color(0xFF0F766E)], "AC Checkup", "Coolant top-up &\nFilter change", Icons.ac_unit),
        ],
      ),
    );
  }

  Widget _buildBannerItem(List<Color> colors, String title, String sub, IconData icon) {
    return Container(
      margin: EdgeInsets.only(right: 10.w),
      decoration: BoxDecoration(gradient: LinearGradient(colors: colors), borderRadius: BorderRadius.circular(20.r), boxShadow: [BoxShadow(color: colors[0].withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Stack(children: [Positioned(right: -20.w, bottom: -20.h, child: Icon(icon, size: 120.sp, color: Colors.white.withOpacity(0.1))), Padding(padding: EdgeInsets.all(24.w), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(title, style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)), SizedBox(height: 8.h), Text(sub, style: TextStyle(color: Colors.white70, fontSize: 14.sp))]))]),
    );
  }

  Widget _buildCategoryItem(String titleKey, IconData icon, Color color) {
    return Container(
      width: 100.w,
      margin: EdgeInsets.only(right: 12.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: Colors.black.withOpacity(0.05)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))]),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: color, size: 32.sp), SizedBox(height: 8.h), Text(titleKey.tr(), textAlign: TextAlign.center, style: TextStyle(color: AppColors.textPrimary, fontSize: 12.sp, fontWeight: FontWeight.w600))]),
    );
  }

  Widget _buildStationTile(String name, String type, String dist) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: Colors.black.withOpacity(0.05))),
      child: ListTile(leading: Container(padding: EdgeInsets.all(8.w), decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(8.r)), child: Icon(Icons.local_gas_station, color: Colors.teal, size: 24.sp)), title: Text(name, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16.sp)), subtitle: Text(type, style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp)), trailing: Text(dist, style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp))),
    );
  }
}