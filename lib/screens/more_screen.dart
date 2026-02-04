import 'package:flutter/material.dart';
import '../../widgets/textured_background.dart';
import '../../core/constants/app_colors.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TexturedBackground(
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(25.0),
              child: Text('SETTINGS TERMINAL', 
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2)),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildItem(Icons.person_outline, 'Profile Settings', 'Personal data & preferences'),
                  _buildItem(Icons.language, 'App Language', 'English / العربية'),
                  _buildItem(Icons.notifications_none, 'Notifications', 'Manage alerts'),
                  _buildItem(Icons.security, 'Privacy Policy', 'Data security details'),
                  _buildItem(Icons.info_outline, 'About ElGarage', 'Version 2.0.4'),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade50, foregroundColor: Colors.red, elevation: 0),
                    child: const Text('LOGOUT', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(IconData icon, String title, String sub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)]),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }
}