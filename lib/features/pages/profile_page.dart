import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart'; 
import '../../core/constants/app_colors.dart';
import '../../core/payment/fawry_service.dart'; // 1. إضافة استيراد خدمة الدفع

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("profile_title".tr(), style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        leading: const BackButton(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // صورة المستخدم
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50.r,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 50.sp, color: AppColors.primary),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(color: AppColors.accent, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                      child: Icon(Icons.edit, color: Colors.white, size: 16.sp),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 15.h),
            Text("Auto-Mentor", style: TextStyle(color: AppColors.textPrimary, fontSize: 22.sp, fontWeight: FontWeight.bold)),
            Text("Auto-Mentor@example.com", style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp)),
            
            SizedBox(height: 30.h),
            
            _buildSectionHeader("account".tr()), // "Account"
            _buildProfileItem(Icons.person_outline, "personal_info".tr()),
            _buildProfileItem(Icons.directions_car_outlined, "vehicle_details".tr()),
            _buildProfileItem(Icons.history, "service_history".tr()),
            
            SizedBox(height: 20.h),
            _buildSectionHeader("settings".tr()), // "Settings"
            _buildProfileItem(Icons.notifications_none, "notifications".tr()),
            _buildProfileItem(Icons.language, "language".tr(), trailing: Text("lang_name".tr(), style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp))),
            
            SizedBox(height: 20.h),

            // ---------------------------------------------------------
            // 2. زر تجربة الدفع (فوري) - تمت إضافته هنا
            // ---------------------------------------------------------
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 20.h),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107), // لون أصفر فوري
                  foregroundColor: Colors.black, // لون النص والأيقونة
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 2,
                ),
                icon: Icon(Icons.payment, size: 24.sp),
                label: Text(
                  "تجربة دفع 50 ج.م (فوري)", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)
                ),
                onPressed: () {
                  FawryService.initiatePayment(
                    context: context,
                    amount: 50.0,            // المبلغ للتجربة
                    userId: "User_Test_1",   // رقم مستخدم وهمي
                    userMobile: "01012345678", 
                    userEmail: "test@automentor.com",
                  );
                },
              ),
            ),
            // ---------------------------------------------------------

            _buildProfileItem(Icons.logout, "logout".tr(), isDestructive: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h, left: 5.w),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(title, style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, {bool isDestructive = false, Widget? trailing}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: isDestructive ? Colors.red.withOpacity(0.1) : AppColors.background,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: isDestructive ? Colors.red : AppColors.primary, size: 22.sp),
        ),
        title: Text(title, style: TextStyle(color: isDestructive ? Colors.red : AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15.sp)),
        trailing: trailing ?? Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary, size: 16.sp),
        onTap: () {},
      ),
    );
  }
}