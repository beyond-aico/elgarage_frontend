import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/app_ui/textured_background.dart';

class PolicyScreen extends StatelessWidget {
  const PolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light, // أيقونات بيضاء لتناسب الخلفية الداكنة
      child: Scaffold(
        backgroundColor: AppColors.textMain, // توحيد الخلفية مع ستايل About
        body: TexturedBackground(
          child: Column(
            children: [
              // --- 1. Header المطور (زر الرجوع + العنوان) في سطر واحد ---
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02, vertical: 5),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textMain),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        "PRIVACY POLICY",
                        style: TextStyle(
                          color: AppColors.textMain,
                          fontWeight: FontWeight.w900,
                          fontSize: screenWidth * 0.05,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      
                      // --- 2. أقسام السياسة باستخدام نظام الكروت المتبادلة ---
                      _buildPolicyCard(
                        title: "Data Collection",
                        content: "We collect vehicle data, location for emergency services, and contact info to provide AI-driven maintenance advice.",
                        isDark: true, // كارت غامق
                      ),
                      
                      const SizedBox(height: 20),

                      _buildPolicyCard(
                        title: "Beyond AI Services",
content: "Driven by a high-performance backend, El Garage automates your maintenance roadmap. Our system intelligently generates precise service schedules and component requirements, ensuring peak performance while keeping your data fully encrypted.",                        isDark: false, // كارت فاتح
                      ),

                      const SizedBox(height: 20),

                      _buildPolicyCard(
                        title: "Security & Encryption",
                        content: "ElGarage uses high-level encryption standards approved by the Dubai Chamber of Digital Economy and international summits.",
                        isDark: true,
                      ),

                      const SizedBox(height: 20),

                      _buildPolicyCard(
                        title: "User Rights",
                        content: "You can request data deletion or export your vehicle history at any time through the support terminal.",
                        isDark: false,
                      ),

                      const SizedBox(height: 40),

                      // تاريخ التحديث
                      const Center(
                        child: Text(
                          "Last Updated: February 2026",
                          style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 30),
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

  // ويدجت بناء الكروت بنفس ستايل About Us
  Widget _buildPolicyCard({
    required String title,
    required String content,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: isDark ? AppColors.textMain.withAlpha(200) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: isDark ? AppColors.primary.withAlpha(50) : Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 80 : 30),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isDark ? CupertinoIcons.shield_fill : CupertinoIcons.shield,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.primary : AppColors.textMain,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            content,
            style: TextStyle(
              color: isDark ? Colors.white70 : AppColors.textMain,
              height: 1.6,
              fontSize: 14,
              fontWeight: FontWeight.bold, // وضوح عالي للنصوص
            ),
          ),
        ],
      ),
    );
  }
}