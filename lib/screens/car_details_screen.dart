import 'package:elgarage/screens/tabs/emergency_tab.dart';
import 'package:elgarage/screens/tabs/history_tab.dart';
import 'package:elgarage/screens/tabs/maintenance_tab.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/app_provider.dart';
import '../widgets/car_header.dart';

class CarDetailsScreen extends StatelessWidget {
  const CarDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. نجيب العربية المختارة من البروفايدر
    final selectedCar = Provider.of<AppProvider>(context).selectedCar;

    return DefaultTabController(
      length: 3, // عدد التابات
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // --- الجزء الأول: الهيرو (بيانات العربية) ---
              CarHeader(car: selectedCar),

              const SizedBox(height: 10),

              // --- الجزء الثاني: شريط التابات (TabBar) ---
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                  tabs: const [
                    Tab(text: 'History'),
                    Tab(text: 'Maintenance'),
                    Tab(text: 'Emergency'),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // --- الجزء الثالث: محتوى التابات (TabBarView) ---
              const Expanded(
                child: TabBarView(
                  children: [
                    // 1. محتوى تاب الهيستوري (مؤقتاً)
                    HistoryTab(),
                    // 2. محتوى تاب الصيانة الدورية (مؤقتاً)
                    MaintenanceTab(),
                    // 3. محتوى تاب الطوارئ (مؤقتاً)
                    EmergencyTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}