import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/app_provider.dart';
import '../widgets/car_header.dart';
import 'tabs/emergency_tab.dart';
import 'tabs/history_tab.dart';
import 'tabs/maintenance_tab.dart';

class CarDetailsScreen extends StatefulWidget {
  const CarDetailsScreen({super.key});

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  // شيلنا initState من هنا لأننا بنعمل fetch من الهوم

  @override
  Widget build(BuildContext context) {
    // استخدام Consumer عشان أي تحديث في selectedCar يسمع هنا فوراً
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final selectedCar = provider.selectedCar;

        // لو المستخدم دخل التاب دي من غير ما يختار عربية
        if (selectedCar == null) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_car_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text("Please select a car from Home first", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        }

        return DefaultTabController(
          length: 3,
          initialIndex: 1, // يفتح على Maintenance
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Column(
                children: [
                  // الهيدر بيتحدث أوتوماتيك مع selectedCar
                  CarHeader(car: selectedCar),
                  
                  const SizedBox(height: 10),
                  
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                      labelColor: Colors.white,
                      unselectedLabelColor: AppColors.textSecondary,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                      tabs: const [
                        Tab(text: 'History'),
                        Tab(text: 'Maintenance'),
                        Tab(text: 'Emergency'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  const Expanded(
                    child: TabBarView(
                      children: [
                        HistoryTab(),
                        MaintenanceTab(), // دي هتقرأ dueMaintenance من البروفايدر اللي اتحدث
                        EmergencyTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}