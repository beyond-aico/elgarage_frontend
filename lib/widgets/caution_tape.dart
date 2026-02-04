import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class CautionTapeDecoration extends StatelessWidget {
  final double height;
  const CautionTapeDecoration({super.key, this.height = 12});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary, AppColors.textMain, AppColors.textMain],
          stops: const [0.0, 0.5, 0.5, 1.0],
          tileMode: TileMode.repeated,
        ),
      ),
    );
  }
}