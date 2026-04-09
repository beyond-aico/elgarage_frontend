import 'package:easy_localization/easy_localization.dart'; // ✅ استيراد
import 'package:elgarage/core/ui/textured_background.dart';
import 'package:elgarage/providers/app_provider.dart';
import 'package:elgarage/screens/more/profile_screen.dart'; 
import 'package:elgarage/screens/more/aboutus_screen.dart';
import 'package:elgarage/screens/more/policy_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final isArabic = context.locale.languageCode == 'ar';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, 
      ),
      child: TexturedBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                // --- الهيدر الموحد ---
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02, vertical: 5),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textMain),
onPressed: () => Provider.of<AppProvider>(context, listen: false).setTabIndex(0),
                      ),
                      Text(
                        'profile.settings'.tr(), // ✅ ترجمة العنوان
                        style: TextStyle(
                          fontSize: screenWidth * 0.06, 
                          fontWeight: FontWeight.w900, 
                          letterSpacing: 1,
                          color: AppColors.textMain
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildItem(context, Icons.person_outline, 'profile.title'.tr(), 'profile.personal_info'.tr(), const ProfileScreen()),
                      
                      // ✅ زر تغيير اللغة التفاعلي
                      _buildItem(
                        context, 
                        Icons.language, 
                        'profile.language'.tr(), 
                        isArabic ? "English" : "العربية", 
                        null,
                        onTap: () {
                          if (isArabic) {
                            context.setLocale(const Locale('en'));
                          } else {
                            context.setLocale(const Locale('ar'));
                          }
                        }
                      ),
                      
                      _buildItem(context, Icons.notifications_none, 'profile.notifications'.tr(), 'Manage alerts', null),
                      _buildItem(context, Icons.security, 'Privacy Policy', 'Data security details', const PolicyScreen()),
                      _buildItem(context, Icons.info_outline, 'About ElGarage', 'Powered by Beyond AI', const AboutUsScreen()),
                      
                      const SizedBox(height: 30),
                      
                      // زر تسجيل الخروج
                      ElevatedButton(
                        onPressed: () async {
                          _showLogoutConfirmation(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error.withAlpha(20), 
                          foregroundColor: AppColors.error, 
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: Text('profile.logout'.tr(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, IconData icon, String title, String sub, Widget? targetScreen, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(15), 
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 8)]
      ),
      child: ListTile(
        onTap: onTap ?? (targetScreen != null ? () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => targetScreen));
        } : null),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.primary.withAlpha(30), shape: BoxShape.circle),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        subtitle: Text(sub, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("profile.logout".tr()),
        content: Text("profile.logout_confirm".tr()), // ✅ يفضل استخدام الترجمة هنا أيضاً
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text("common.cancel".tr()) // ✅ ترجمة زر الإلغاء
          ),
          TextButton(
            onPressed: () async {
              // 1. تصفير بيانات الـ AppProvider أولاً (العربيات، السلة، إلخ)
              // ✅ دي أهم خطوة عشان التطبيق ميهنجش لما يوزر جديد يدخل
              Provider.of<AppProvider>(context, listen: false).resetOnLogout();

              // 2. مسح التوكن وبيانات الهوية
              await Provider.of<AuthProvider>(context, listen: false).logout();

              // 3. التوجيه لصفحة اللوجن ومسح كل الصفحات القديمة من الـ Stack
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            }, 
            child: Text(
              "profile.logout".tr(), 
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
            )
          ),
        ],
      ),
    );
  }
}