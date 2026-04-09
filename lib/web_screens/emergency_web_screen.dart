// lib/web_screens/emergency_web_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants/app_colors.dart';
import '../providers/app_provider.dart';

class EmergencyWebScreen extends StatelessWidget {
  const EmergencyWebScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final double screenWidth = MediaQuery.of(context).size.width;

    // بنرجع المحتوى فقط لأن السايد بار موجود فعلاً في ملف FleetDashboardWeb الأب
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. الهيدر البسيط (نفس ستايل الفليت والماركت بليس)
          _buildWebHeader(),
          
          const SizedBox(height: 30),
          // 2. بنر الطوارئ الأحمر العريض
          _buildEmergencyAlertBanner(screenWidth),
          
          const SizedBox(height: 40),
          
          // 3. قسم Towing Services
          _buildSectionHeader("TOWING & WINCH SERVICES", CupertinoIcons.car_detailed),
          const SizedBox(height: 15),
          _buildEmergencyGrid(provider, 'Winch', screenWidth),

          const SizedBox(height: 40),
          
          // 4. قسم Battery & Power
          _buildSectionHeader("BATTERY & POWER ASSISTANCE", CupertinoIcons.bolt_fill),
          const SizedBox(height: 15),
          _buildEmergencyGrid(provider, 'Battery', screenWidth),

          const SizedBox(height: 40),

          // 5. قسم Tires & Wheels
          _buildSectionHeader("TIRES & WHEEL SUPPORT", CupertinoIcons.sunrise_fill),
          const SizedBox(height: 15),
          _buildEmergencyGrid(provider, 'Tire', screenWidth),

          const SizedBox(height: 50),
        ],
      ),
    );
  }

  // هيدر الويب النظيف
  Widget _buildWebHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "SYSTEM EMERGENCY HUB",
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        const Text(
          "Roadside Assistance",
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white),
        ),
      ],
    );
  }

  // بنر التنبيه العريض
  Widget _buildEmergencyAlertBanner(double screenWidth) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.error.withOpacity(0.5), width: 2),
      ),
      child: Row(
        children: [
          const Icon(CupertinoIcons.exclamationmark_shield_fill, color: AppColors.error, size: 40),
          const SizedBox(width: 25),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("CRITICAL INCIDENT?", style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1)),
                Text("In case of severe accidents or medical needs, call 123 immediately.", 
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _makePhoneCall('123'),
            icon: const Icon(Icons.phone_in_talk, color: Colors.white),
            label: const Text("CALL 123", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.primary, letterSpacing: 1.5)),
      ],
    );
  }

  // شبكة الخدمات (Grid)
  Widget _buildEmergencyGrid(AppProvider provider, String type, double screenWidth) {
    final contacts = provider.getEmergencyByType(type);
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: screenWidth > 1400 ? 3 : 2,
        childAspectRatio: 3.0, // ضبط النسبة لمنع الـ Overflow الداخلي
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return Container(
          decoration: BoxDecoration(
            color: AppColors.textMain,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                ),
                child: Icon(
                  type == 'Winch' ? CupertinoIcons.bus : type == 'Battery' ? CupertinoIcons.bolt_circle_fill : CupertinoIcons.circle_grid_hex_fill,
                  color: AppColors.primary, size: 25,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(contact.name.toUpperCase(), 
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13), 
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(contact.location, 
                        style: const TextStyle(color: Colors.white38, fontSize: 10), 
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _makePhoneCall(contact.phoneNumber),
                icon: const Icon(Icons.phone, color: AppColors.primary),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }
}