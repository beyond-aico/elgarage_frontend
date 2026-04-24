// lib/web_screens/main_web_screen.dart

import 'package:elgarage/core/web_ui/main_web_layout.dart';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class MainWebScreen extends StatelessWidget {
  const MainWebScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // نستخدم الـ Layout الرئيسي كإطار للصفحة
    return MainWebLayout(
      child: Column(
        children: [
          _buildHeroSection(context),
          _buildServicesSection(context),
          _buildValueProposition(context),
          _buildCallToAction(context),
        ],
      ),
    );
  }

  // 1. قسم الترحيب (Hero Section) - Responsive
  Widget _buildHeroSection(BuildContext context) {
    bool isSmall = MediaQuery.of(context).size.width < 900;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isSmall ? 50 : 100, 
        horizontal: isSmall ? 25 : 80
      ),
      child: Flex(
        direction: isSmall ? Axis.vertical : Axis.horizontal,
        children: [
          Expanded(
            flex: isSmall ? 0 : 1,
            child: Column(
              crossAxisAlignment: isSmall ? CrossAxisAlignment.center : CrossAxisAlignment.start,
              children: [
                Text(
                  "NEXT-GEN AUTOMOTIVE\nLOGISTICS OS.",
                  textAlign: isSmall ? TextAlign.center : TextAlign.left,
                  style: TextStyle(
                    color: AppColors.textMain,
                    fontSize: isSmall ? 32 : 52,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  "إلجراج هو النظام السحابي المتكامل لإدارة صيانة السيارات والأساطيل بتكنولوجيا Beyond AI. دقة في التتبع، توفير في التكاليف، وأمان لسيارتك.",
                  textAlign: isSmall ? TextAlign.center : TextAlign.left,
                  style: TextStyle(
                    color: AppColors.textMain.withAlpha(180),
                    fontSize: isSmall ? 16 : 18,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 50),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    _buildPrimaryButton("ابدأ إدارة أسطولك", () {}),
                    _buildSecondaryButton("تصفح الماركت بليس", () {}),
                  ],
                ),
              ],
            ),
          ),
          if (!isSmall) const SizedBox(width: 40),
          Expanded(
            flex: isSmall ? 0 : 1,
            child: Padding(
              padding: EdgeInsets.only(top: isSmall ? 60 : 0),
              child: Center(
                child: Icon(Icons.dashboard_customize_outlined, 
                  size: isSmall ? 200 : 300, color: AppColors.textMain.withAlpha(20)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. قسم الخدمات (Services) - Responsive
  Widget _buildServicesSection(BuildContext context) {
    bool isSmall = MediaQuery.of(context).size.width < 900;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 80, 
        horizontal: isSmall ? 20 : 80
      ),
      color: AppColors.textMain.withAlpha(5),
      child: Column(
        children: [
          _buildSectionHeader("خدماتنا التقنية", "حلول متكاملة للصيانة والإدارة", isSmall),
          const SizedBox(height: 60),
          Wrap(
            spacing: 30,
            runSpacing: 30,
            alignment: WrapAlignment.center,
            children: [
              _buildServiceCard(Icons.settings_suggest, "إدارة الأساطيل", "تتبع شامل لكل مركبة في أسطولك مع تنبيهات ذكية لمواعيد الصيانة.", isSmall),
              _buildServiceCard(Icons.shopping_cart_checkout, "الماركت بليس", "وصول مباشر لأفضل قطع الغيار والزيوت بأسعار تنافسية وضمان Beyond AI.", isSmall),
              _buildServiceCard(Icons.analytics, "تقارير الأداء", "تحليلات دقيقة لمعدلات الاستهلاك وتكاليف الصيانة الدورية لكل وحدة.", isSmall),
            ],
          ),
        ],
      ),
    );
  }

  // 3. قسم القيمة المضافة (Value Proposition) - Responsive
  Widget _buildValueProposition(BuildContext context) {
    bool isSmall = MediaQuery.of(context).size.width < 900;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 100, 
        horizontal: isSmall ? 25 : 80
      ),
      child: Flex(
        direction: isSmall ? Axis.vertical : Axis.horizontal,
        children: [
          Expanded(
            flex: isSmall ? 0 : 1,
            child: Column(
              crossAxisAlignment: isSmall ? CrossAxisAlignment.center : CrossAxisAlignment.start,
              children: [
                const Text("لماذا تختار إلجراج؟", 
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, letterSpacing: 2)),
                const SizedBox(height: 20),
                Text(
                  "البنية التحتية الذكية\nلسوق السيارات المصري",
                  textAlign: isSmall ? TextAlign.center : TextAlign.left,
                  style: TextStyle(color: AppColors.textMain, fontSize: isSmall ? 28 : 36, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 30),
                _buildCheckItem("تكنولوجيا الذكاء الاصطناعي من Beyond AI."),
                _buildCheckItem("ربط مباشر مع مراكز الخدمة المعتمدة."),
                _buildCheckItem("توفير يصل لـ 30% من تكاليف التشغيل سنوياً."),
              ],
            ),
          ),
          if (!isSmall) const Expanded(child: SizedBox()), 
        ],
      ),
    );
  }

  // 4. Call to Action (CTA) - Responsive
  Widget _buildCallToAction(BuildContext context) {
    bool isSmall = MediaQuery.of(context).size.width < 900;

    return Container(
      margin: EdgeInsets.all(isSmall ? 20 : 80),
      padding: EdgeInsets.all(isSmall ? 30 : 60),
      decoration: BoxDecoration(
        color: AppColors.textMain,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            "جاهز لتطوير تجربة صيانة سياراتك؟",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.primary, fontSize: isSmall ? 24 : 32, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 20),
          const Text(
            "انضم الآن لآلاف المستخدمين وأصحاب الأساطيل الذين يثقون في إلجراج.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
          const SizedBox(height: 40),
          _buildPrimaryButton("سجل حسابك الآن مجاناً", () {}),
        ],
      ),
    );
  }

  // --- Widgets مساعدة (Helpers) مع دعم الـ Responsive ---

  Widget _buildSectionHeader(String title, String subtitle, bool isSmall) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, letterSpacing: 2)),
        const SizedBox(height: 10),
        Text(subtitle, 
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMain, fontSize: isSmall ? 24 : 32, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildServiceCard(IconData icon, String title, String desc, bool isSmall) {
    return Container(
      width: isSmall ? double.infinity : 350,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: isSmall ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 40),
          const SizedBox(height: 25),
          Text(title, style: const TextStyle(color: AppColors.textMain, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Text(desc, 
            textAlign: isSmall ? TextAlign.center : TextAlign.left,
            style: TextStyle(color: AppColors.textMain.withAlpha(150), fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
          const SizedBox(width: 15),
          Flexible(child: Text(text, style: const TextStyle(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textMain,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
    );
  }

  Widget _buildSecondaryButton(String text, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textMain,
        side: const BorderSide(color: AppColors.textMain, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
    );
  }
}