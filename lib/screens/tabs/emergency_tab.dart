import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // عشان الاتصال
import '../../core/constants/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../data/models/emergency_model.dart';

class EmergencyTab extends StatelessWidget {
  const EmergencyTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // تحذير أو نصيحة سريعة في الأول
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(CupertinoIcons.exclamationmark_triangle_fill, color: AppColors.error),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    "In case of severe accidents, please call 123 immediately.",
                    style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 1. قسم الأوناش
          _buildSectionHeader("Towing Services (Winches)", CupertinoIcons.car_fill),
          _buildContactList(context, 'Winch'),

          // 2. قسم البطاريات
          _buildSectionHeader("Battery Jumpstart & Replace", CupertinoIcons.battery_100),
          _buildContactList(context, 'Battery'),

          // 3. قسم الكاوتش
          _buildSectionHeader("Tire Services", CupertinoIcons.circle_grid_hex),
          _buildContactList(context, 'Tire'),
        ],
      ),
    );
  }

  // ويدجت لعنوان القسم
  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  // ويدجت لبناء قائمة الكروت
  Widget _buildContactList(BuildContext context, String type) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final contacts = provider.getEmergencyByType(type);

    return ListView.builder(
      shrinkWrap: true, // مهم عشان الـ ListView جوه ScrollView
      physics: const NeverScrollableScrollPhysics(), // عشان ما يعملش سكرول لوحده
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            // الأيقونة الجانبية
            leading: CircleAvatar(
              backgroundColor: Colors.grey[100],
              child: Icon(
                type == 'Winch' ? CupertinoIcons.arrow_up_bin_fill : 
                type == 'Battery' ? CupertinoIcons.bolt_fill : CupertinoIcons.settings,
                color: AppColors.textSecondary,
              ),
            ),
            // الاسم والمكان
            title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Row(
              children: [
                const Icon(CupertinoIcons.location_solid, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(contact.location, style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 10),
                const Icon(CupertinoIcons.star_fill, size: 12, color: Colors.amber),
                const SizedBox(width: 4),
                Text(contact.rating, style: const TextStyle(fontSize: 12)),
              ],
            ),
            // زرار الاتصال الأخضر
            trailing: IconButton(
              onPressed: () => _makePhoneCall(contact.phoneNumber),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.success,
                shape: const CircleBorder(),
              ),
              icon: const Icon(CupertinoIcons.phone_fill, color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  // فنكشن الاتصال الفعلي
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      // لو فشل (مثلا سيميلاتور)
      print("Could not launch $phoneNumber");
    }
  }
}