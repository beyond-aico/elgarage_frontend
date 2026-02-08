import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/ui/textured_background.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return TexturedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("USER PROFILE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.textMain,
                child: Icon(CupertinoIcons.person_alt_circle_fill, size: 80, color: AppColors.primary),
              ),
              const SizedBox(height: 30),
              _buildProfileField("FULL NAME", user?.name ?? "N/A", CupertinoIcons.person),
              _buildProfileField("EMAIL ADDRESS", user?.email ?? "N/A", CupertinoIcons.mail),
              _buildProfileField("PHONE NUMBER", user?.phone ?? "N/A", CupertinoIcons.phone),
              _buildProfileField("ACCOUNT TYPE", user?.role ?? "CUSTOMER", CupertinoIcons.shield_fill),
              const Spacer(),
              const Text("EL GARAGE SYSTEM v1.0", style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textMain, size: 20),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}