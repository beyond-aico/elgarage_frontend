// lib/core/ui/web/web_footer.dart

import 'package:elgarage/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class WebFooter extends StatelessWidget {
  const WebFooter({super.key});

  @override
  Widget build(BuildContext context) {
    bool isSmall = MediaQuery.of(context).size.width < 850;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 60, 
        horizontal: isSmall ? 30 : 80
      ),
      color: AppColors.textMain, 
      child: Column(
        children: [
          Wrap(
            spacing: 50,
            runSpacing: 40,
            alignment: WrapAlignment.spaceBetween,
            children: [
              // عمود البراندنج
              SizedBox(
                width: isSmall ? double.infinity : 300,
                child: Column(
                  crossAxisAlignment: isSmall ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                  children: [
                    const Text("BEYOND AI", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 24)),
                    const SizedBox(height: 10),
                    Text(
                      "Powering the future of\nAutomotive Logistics.", 
                      textAlign: isSmall ? TextAlign.center : TextAlign.left,
                      style: const TextStyle(color: Colors.white24, fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),
              
              // الروابط
              _footerColumn("RESOURCES", ["Marketplace", "Documentation", "API Status"], isSmall),
              _footerColumn("COMPANY", ["About Us", "Contact", "Careers"], isSmall),
              
              // عمود التحميل
              SizedBox(
                width: isSmall ? double.infinity : 200,
                child: Column(
                  crossAxisAlignment: isSmall ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                  children: [
                    const Text("GET THE APP", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 20),
                    _appBadge(Icons.apple, "App Store"),
                    const SizedBox(height: 10),
                    _appBadge(Icons.android, "Play Store"),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
          const Divider(color: Colors.white10),
          const SizedBox(height: 20),
          const Text(
            "© 2026 ELGARAGE by BEYOND AI. All rights reserved.", 
            style: TextStyle(color: Colors.white10, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _footerColumn(String title, List<String> links, bool isSmall) {
    return SizedBox(
      width: isSmall ? double.infinity : 150,
      child: Column(
        crossAxisAlignment: isSmall ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 20),
          ...links.map((link) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(link, style: const TextStyle(color: Colors.white24, fontSize: 13)),
          )),
        ],
      ),
    );
  }

  Widget _appBadge(IconData icon, String store) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary.withAlpha(50)), 
        borderRadius: BorderRadius.circular(8)
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          Text(store, style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}