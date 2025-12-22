import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/secondary_hero_section.dart';

class SparePartsPage extends StatelessWidget {
  const SparePartsPage({super.key});

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
                    Text("spare_categories".tr(), style: TextStyle(color: AppColors.textPrimary, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 15.h),
                    SizedBox(
                      height: 100.h,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildCategoryItem("cat_engine", Icons.settings_applications),
                          _buildCategoryItem("cat_body", Icons.directions_car),
                          _buildCategoryItem("cat_electrical", Icons.electrical_services),
                          _buildCategoryItem("cat_access", Icons.shopping_bag),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 30.h),
                    
                    // 3. قائمة التجار (Merchants)
                    Text("verified_merchants".tr(), style: TextStyle(color: AppColors.textPrimary, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 15.h),
                    
                    _buildMerchantCard(
                      name: "merch_tawfik".tr(),
                      specialty: "spec_kia".tr(),
                      rating: "4.8",
                      location: "away_km".tr(args: ["2"]),
                      isOpen: true,
                      items: ["item_oil_filter".tr(), "item_brake_pads".tr()]
                    ),
                    _buildMerchantCard(
                      name: "merch_speed".tr(),
                      specialty: "spec_tuning".tr(),
                      rating: "4.5",
                      location: "away_km".tr(args: ["5"]),
                      isOpen: true,
                      items: ["item_spoiler".tr(), "LED Lights"]
                    ),
                    _buildMerchantCard(
                      name: "Al-Ahram Battery", 
                      specialty: "Batteries & Electrical",
                      rating: "4.9",
                      location: "away_km".tr(args: ["3"]), 
                      isOpen: false,
                      items: ["Varta 70Ah", "AC Delco"]
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
          _buildBannerItem(
            [Color(0xFF1E293B), Color(0xFF0F172A)], 
            "Genuine Parts", 
            "15% Off on all\nEngine Components", 
            Icons.settings
          ),
          _buildBannerItem(
            [Color(0xFFEA580C), Color(0xFFC2410C)], 
            "Body Kits", 
            "Upgrade your look\nNew Arrivals", 
            Icons.directions_car_filled
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
        boxShadow: [BoxShadow(color: colors[0].withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Stack(
        children: [
          Positioned(right: -20.w, bottom: -20.h, child: Icon(icon, size: 120.sp, color: Colors.white.withOpacity(0.1))),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 8.h),
                Text(sub, style: TextStyle(color: Colors.white70, fontSize: 14.sp)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String titleKey, IconData icon) {
    return Container(
      width: 100.w,
      margin: EdgeInsets.only(right: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.accent, size: 32.sp),
          SizedBox(height: 8.h),
          Text(titleKey.tr(), textAlign: TextAlign.center, style: TextStyle(color: AppColors.textPrimary, fontSize: 12.sp, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildMerchantCard({required String name, required String specialty, required String rating, required String location, required bool isOpen, required List<String> items}) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name, style: TextStyle(color: AppColors.textPrimary, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  Text(specialty, style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp)),
                ])),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(color: isOpen ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12.r), border: Border.all(color: isOpen ? Colors.green : Colors.red)),
                  child: Text(isOpen ? "open_now".tr() : "closed".tr(), style: TextStyle(color: isOpen ? Colors.green : Colors.red, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(spacing: 8.w, runSpacing: 8.h, children: items.map((item) => Container(padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h), decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.05), borderRadius: BorderRadius.circular(8.r)), child: Text(item, style: TextStyle(color: AppColors.accent, fontSize: 12.sp)))).toList()),
              SizedBox(height: 15.h), Divider(height: 1, color: Colors.grey.withOpacity(0.2)), SizedBox(height: 10.h),
              Row(children: [Icon(Icons.location_on, size: 16.sp, color: AppColors.textSecondary), SizedBox(width: 4.w), Text(location, style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp)), Spacer(), Icon(Icons.star, size: 16.sp, color: Colors.amber), Text(rating, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14.sp))]),
              SizedBox(height: 15.h),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)), padding: EdgeInsets.symmetric(vertical: 12.h)), child: Text("view_products".tr()))),
            ]),
          ),
        ],
      ),
    );
  }
}