import 'package:elgarage/core/ui/textured_background.dart';
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, 
      ),
      child: TexturedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // --- 1. الهيدر الموحد (Back Button + Title) ---
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02, vertical: 5),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textMain),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'SETTINGS',
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

              // --- 2. قائمة الإعدادات ---
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildItem(context, Icons.person_outline, 'Profile Settings', 'Personal data & preferences', const ProfileScreen()),
                    _buildItem(context, Icons.language, 'App Language', 'English / العربية', null),
                    _buildItem(context, Icons.notifications_none, 'Notifications', 'Manage alerts', null),
                    _buildItem(context, Icons.security, 'Privacy Policy', 'Data security details', const PolicyScreen()),
                    _buildItem(context, Icons.info_outline, 'About ElGarage', 'Powered by Beyond AI', const AboutUsScreen()),
                    
                    const SizedBox(height: 30),
                    
                    ElevatedButton(
                      onPressed: () async {
                        await Provider.of<AuthProvider>(context, listen: false).logout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error.withAlpha(20), 
                        foregroundColor: AppColors.error, 
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text('LOGOUT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, IconData icon, String title, String sub, Widget? targetScreen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(15), 
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 8)]
      ),
      child: ListTile(
        onTap: targetScreen != null ? () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => targetScreen));
        } : null,
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
}