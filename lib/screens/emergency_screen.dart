import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants/app_colors.dart';
import '../providers/app_provider.dart';
import '../core/ui/textured_background.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double headerHeight = screenWidth * 0.50; // هيدر أقصر قليلاً للطوارئ

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: TexturedBackground(
          child: Column(
            children: [
              // --- 1. هيدر الطوارئ المقوس الثابت ---
              Stack(
                children: [
                  ClipPath(
                    clipper: EmergencyWaveClipper(),
                    child: Container(
                      height: headerHeight,
                      width: double.infinity,
                      color: AppColors.textMain,
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EMERGENCY',
                            style: TextStyle(
                              fontSize: screenWidth * 0.08,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                              letterSpacing: 2,
                            ),
                          ),
                          const Text(
                            'Roadside Assistance 24/7',
                            style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          // تحذير سريع مدمج في الهيدر بشكل أنيق
                          _buildEmergencyBanner(screenWidth),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // --- 2. قائمة خدمات الإغاثة (Scrollable) ---
              Expanded(
                child: Transform.translate(
                  offset: const Offset(0, -20), // سحب القائمة لتدخل في قوس الهيدر
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    children: [
                      _buildSectionHeader("Towing Services", CupertinoIcons.car_detailed),
                      _buildContactList(context, 'Winch', screenWidth),
                      
                      const SizedBox(height: 20),
                      _buildSectionHeader("Battery & Power", CupertinoIcons.bolt_fill),
                      _buildContactList(context, 'Battery', screenWidth),
                      
                      const SizedBox(height: 20),
                      _buildSectionHeader("Tires & Wheels", CupertinoIcons. sunrise_fill),
                      _buildContactList(context, 'Tire', screenWidth),
                      
                      const SizedBox(height: 100), // مساحة إضافية للسكرول
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // بنر التحذير داخل الهيدر
  Widget _buildEmergencyBanner(double screenWidth) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withAlpha(40),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withAlpha(80), width: 1),
      ),
      child: Row(
        children: [
          const Icon(CupertinoIcons.exclamationmark_shield_fill, color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              "Severe accident? Call 123 immediately.",
              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          GestureDetector(
            onTap: () => _makePhoneCall('123'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(8)),
              child: const Text("CALL", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textMain, size: 18),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textMain, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  // استبدل دالة _buildContactList بالنسخة المحدثة (بدون صور)

Widget _buildContactList(BuildContext context, String type, double screenWidth) {
  final provider = Provider.of<AppProvider>(context, listen: false);
  final contacts = provider.getEmergencyByType(type);

  return Column(
    children: contacts.map((contact) {
      return Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: AppColors.textMain, // ✅ جعل اللون الأساسي هو لون الكارت
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 10, offset: const Offset(0, 5))
          ],
        ),
        child: InkWell(
          onTap: () => _makePhoneCall(contact.phoneNumber),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16), // زيادة الهامش الداخلي
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      contact.name.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.star_fill, color: Colors.amber, size: 12),
                          const SizedBox(width: 4),
                          Text(contact.rating, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(CupertinoIcons.location_solid, color: AppColors.primary, size: 14),
                    const SizedBox(width: 6),
                    Text(contact.location, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const Divider(color: Colors.white10, height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "CALL ${contact.phoneNumber}",
                      style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Text(
                          "REQUEST NOW",
                          style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(width: 8),
                        const Icon(CupertinoIcons.phone_fill, color: AppColors.primary, size: 18),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }).toList(),
  );
}

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }
}

// الكليبر المخصص لصفحة الطوارئ
class EmergencyWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}