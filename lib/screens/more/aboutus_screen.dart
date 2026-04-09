import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/ui/textured_background.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light, // أيقونات الساعة والبطارية بيضاء
      child: Scaffold(
        backgroundColor: AppColors.textMain, 
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
                        "ABOUT US",
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
                      
                      // --- 2. قسم EL GARAGE (الآن في الكارت الغامق) ---
                      _buildMainCard(
                        screenWidth: screenWidth,
                        imagePath: 'assets/images/logo.png',
                        title: "EL GARAGE",
                        content: "The ultimate solution to maintain your vehicle. We make car care easier and stress-free. Everything you need is right here. All you have to do is buy your genuine parts and head to **our merchants** centers. No more maintenance headaches.",
                        isDark: true, 
                      ),

                      const SizedBox(height: 30),
                      
                      // فاصل تصميمي يربط بين المنتج والمطور
                      Icon(CupertinoIcons.link, color: AppColors.primary, size: screenWidth * 0.06),
                      
                      const SizedBox(height: 30),

                      // --- 3. قسم BEYOND AI (الآن في الكارت الفاتح) ---
                      _buildMainCard(
                        screenWidth: screenWidth,
                        imagePath: 'assets/images/beyond.png',
                        title: "BEYOND AI",
                        content: "El Garage is a specialized intelligent solution developed at Beyond AI Labs. We bridge the gap between AI technology and automotive safety to redefine car care experience.",                        isDark: false, 
                        footer: Column(
                          children: [
                            const Divider(color: Colors.black12, height: 30),
                            _buildContactLink(CupertinoIcons.globe, "beyondaico.org", false),
                            const SizedBox(height: 12),
                            _buildContactLink(CupertinoIcons.mail_solid, "beyond.aico@gmail.com", false),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                      
                      // الفوتر الخاص بالحدث
                      const Text(
                        "RiseUp Summit 2026 Edition", 
                        style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)
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

  // ويدجت بناء الكروت
  Widget _buildMainCard({
    required double screenWidth,
    required String imagePath,
    required String title,
    required String content,
    required bool isDark,
    Widget? footer,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: isDark ? AppColors.textMain.withAlpha(220) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: isDark ? AppColors.primary.withAlpha(80) : Colors.transparent),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(isDark ? 100 : 30), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          Image.asset(
            imagePath,
            width: screenWidth * (isDark ? 0.35 : 0.25), 
            errorBuilder: (c, e, s) => Icon(Icons.blur_on, size: 60, color: isDark ? AppColors.primary : AppColors.textMain),
          ),
          const SizedBox(height: 20),
          Text(
            title, 
            style: TextStyle(
              fontSize: 22, 
              fontWeight: FontWeight.w900, 
              color: isDark ? AppColors.primary : AppColors.textMain, 
              letterSpacing: 2
            )
          ),
          const SizedBox(height: 15),
          Text(
            content,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white70 : AppColors.textMain, 
              height: 1.6, 
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          ?footer,
        ],
      ),
    );
  }

  Widget _buildContactLink(IconData icon, String text, bool isCardDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.primary, size: 14),
        const SizedBox(width: 8),
        Text(
          text, 
          style: TextStyle(
            color: isCardDark ? Colors.white : AppColors.textMain, 
            fontSize: 13, 
            fontWeight: FontWeight.w900,
            decoration: TextDecoration.underline
          )
        ),
      ],
    );
  }
}