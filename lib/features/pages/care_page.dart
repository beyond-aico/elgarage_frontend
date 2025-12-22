import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/secondary_hero_section.dart';

class CarePage extends StatelessWidget {
  const CarePage({super.key});

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
                    // 1. سلايدر الإعلانات
                    _buildPromoSlider(),
                    SizedBox(height: 25.h),

                    // 2. الأقسام (Categories)
                    Text("care_categories".tr(), style: TextStyle(color: AppColors.textPrimary, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 15.h),
                    SizedBox(
                      height: 110.h,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildCatCard("cat_wash", Icons.local_car_wash),
                          _buildCatCard("cat_polish", Icons.auto_awesome),
                          _buildCatCard("cat_interior", Icons.chair),
                          _buildCatCard("cat_accessories", Icons.shopping_bag),
                        ],
                      ),
                    ),

                    SizedBox(height: 30.h),
                    
                    // 3. المراكز (Top Rated)
                    Text("top_centers".tr(), style: TextStyle(color: AppColors.textPrimary, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 15.h),
                    
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 15.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: Colors.black.withOpacity(0.05)),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))],
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(12.w),
                            leading: Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(10.r)),
                              child: Icon(Icons.storefront, color: Colors.deepPurpleAccent, size: 24.sp),
                            ),
                            title: Text("care_center_name".tr(args: [(index + 1).toString()]), style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16.sp)),
                            subtitle: Text("full_detailing".tr(), style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp)),
                            trailing: Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary, size: 16.sp),
                          ),
                        );
                      },
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
          _buildBannerItem([Color(0xFF7C3AED), Color(0xFF4C1D95)], "premium_detailing".tr(), "nano_offer".tr(), Icons.diamond_outlined),
          _buildBannerItem([Color(0xFF2563EB), Color(0xFF1E3A8A)], "Interior Deep Clean", "Steam wash & \nLeather care", Icons.cleaning_services),
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
        boxShadow: [BoxShadow(color: colors[0].withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Stack(
        children: [
          Positioned(right: -20.w, bottom: -20.h, child: Icon(icon, size: 120.sp, color: Colors.white.withOpacity(0.1))),
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(title, style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 8.h),
              Text(sub, style: TextStyle(color: Colors.white70, fontSize: 14.sp)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildCatCard(String titleKey, IconData icon) {
    return Container(
      width: 100.w,
      margin: EdgeInsets.only(right: 15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.purpleAccent, size: 30.sp),
          SizedBox(height: 8.h),
          Text(titleKey.tr(), style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}