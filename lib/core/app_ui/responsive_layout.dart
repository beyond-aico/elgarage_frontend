import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileScreen;
  final Widget webScreen;

  const ResponsiveLayout({
    super.key,
    required this.mobileScreen,
    required this.webScreen,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // إذا كان عرض الشاشة أكبر من 900 بكسل، نعتبره ويب/تابلت
        if (constraints.maxWidth > 900) {
          return webScreen;
        }
        // غير ذلك يظل الموبايل كما هو
        return mobileScreen;
      },
    );
  }
}