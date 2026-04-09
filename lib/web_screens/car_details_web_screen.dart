// lib/web_screens/car_details_web_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/app_provider.dart';
import '../screens/tabs/history_tab.dart'; // استخدام التابات الموجودة فعلاً
import '../screens/tabs/maintenance_tab.dart';

class CarDetailsWebScreen extends StatefulWidget {
  const CarDetailsWebScreen({super.key});

  @override
  State<CarDetailsWebScreen> createState() => _CarDetailsWebScreenState();
}

class _CarDetailsWebScreenState extends State<CarDetailsWebScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);

    // جلب بيانات الصيانة بمجرد فتح الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      if (provider.selectedCar != null) {
        provider.fetchDueMaintenance(carId: provider.selectedCar!.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final selectedCar = provider.selectedCar;

        // حالة عدم اختيار سيارة (نفس روح الموبايل مع تنسيق ويب)
        if (selectedCar == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.car_detailed,
                  size: 100,
                  color: Colors.white10,
                ),
                SizedBox(height: 20),
                Text(
                  "SELECT A VEHICLE TO VIEW DETAILS",
                  style: TextStyle(
                    color: Colors.white24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. الهيدر النظيف (نفس ستايل الماركت بليس والفليت)
              _buildWebHeader(context, provider, selectedCar),

              const SizedBox(height: 40),

              // 2. شريط الحالة (Stats Strip) - أصبح أعرض ومناسب للويب
              _buildStatsStrip(selectedCar),

              const SizedBox(height: 30),

              // 3. التابات (Navigation)
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.white30,
                indicatorColor: AppColors.primary,
                indicatorWeight: 4,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: const Color.fromARGB(255, 0, 0, 0),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 1.5,
                ),
                tabs: const [
                  Tab(text: 'MAINTENANCE HISTORY'),
                  Tab(text: 'DUE MAINTENANCE'),
                ],
              ),

              const SizedBox(height: 20),

              // 4. المحتوى (Expanded TabView)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: TabBarView(
                    controller: _tabController,
                    children: const [HistoryTab(), MaintenanceTab()],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // هيدر الويب الاحترافي
  Widget _buildWebHeader(
    BuildContext context,
    AppProvider provider,
    var selectedCar,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // لوجو الماركة (بدون Hero لأننا في تابة ويب)
            Image.asset(
              'assets/images/car_logo.png',
              height: 60,
              errorBuilder: (c, e, s) => const Icon(
                Icons.directions_car,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 25),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "VEHICLE PROFILE",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${selectedCar.make} ${selectedCar.model}'.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "LICENSE PLATE: ${selectedCar.licensePlate ?? 'N/A'}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
        // أزرار التحكم (Delete) في الويب بجانب الهيدر
        ElevatedButton.icon(
          onPressed: () =>
              _showDeleteConfirmation(context, provider, selectedCar.id),
          icon: const Icon(Icons.delete_outline, color: Colors.black),
          label: const Text(
            "REMOVE VEHICLE",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  // شريط الإحصائيات المطور للويب
  // ignore: strict_top_level_inference
  Widget _buildStatsStrip(var selectedCar) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: AppColors.textMain,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'CURRENT MILEAGE',
            '${selectedCar.mileageKm.toInt()} KM',
            CupertinoIcons.speedometer,
          ),
          _verticalDivider(),
          _buildStatItem(
            'SERVICE WINDOW',
            'OPTIMAL',
            CupertinoIcons.wrench_fill,
          ),
          _verticalDivider(),
          _buildStatItem(
            'HEALTH SCORE',
            '98%',
            CupertinoIcons.checkmark_shield_fill,
          ),
          _verticalDivider(),
          _buildStatItem('LAST SCAN', '24H AGO', CupertinoIcons.device_desktop),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 10),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() =>
      Container(width: 1, height: 40, color: Colors.white10);

  // ديالوج الحذف (نفس المنطق القوي اللي إنت عامله)
  void _showDeleteConfirmation(
    BuildContext context,
    AppProvider provider,
    String carId,
  ) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Delete Vehicle?"),
        content: const Text(
          "All history logs for this car will be permanently removed from Beyond AI servers.",
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text("Delete"),
            onPressed: () async {
              final success = await provider.removeCar(carId);
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  provider.setTabIndex(0); // العودة للداشبورد
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Vehicle Deleted"),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
