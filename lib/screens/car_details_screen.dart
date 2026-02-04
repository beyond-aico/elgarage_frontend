import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/app_provider.dart';
import '../widgets/textured_background.dart';
import 'tabs/emergency_tab.dart';
import 'tabs/history_tab.dart';
import 'tabs/maintenance_tab.dart';

class CarDetailsScreen extends StatefulWidget {
  const CarDetailsScreen({super.key});

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // تم استخدام 3 تابات كما في الكود الأصلي ولكن بتصميم الكود الجديد
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
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

        // حالة عدم اختيار سيارة
        if (selectedCar == null) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.car_detailed, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text("Please select a car from Home first", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: const BackButton(color: AppColors.textMain),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.settings_outlined, color: AppColors.textMain),
              )
            ],
          ),
          body: TexturedBackground(
            child: Column(
              children: [
                const SizedBox(height: 60), // مساحة للأب بار

                // 1. لوجو البراند (HERO) - ستايل الكود الجديد
                Hero(
                  tag: 'brand_logo_${selectedCar.id}',
                  child: Container(
                    height: 90,
                    width: 90,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ],
                      border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
                    ),
                    child: Image.asset(
                      'assets/images/brands/${selectedCar.make.toLowerCase()}_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => Center(
                        child: Text(
                          selectedCar.make[0],
                          style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: AppColors.textMain),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                Text(
                  '${selectedCar.make} ${selectedCar.model}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                ),
                Text(
                  selectedCar.licensePlate ?? 'No Plate',
                  style: const TextStyle(fontSize: 14, color: AppColors.textSub, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                // 2. شريط الحالة (Stats Strip) - الأسود الصناعي
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: AppColors.textMain, // الأسود الأسفلتي
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Current KM', '${selectedCar.currentKm.toInt()} k', CupertinoIcons.speedometer),
                      Container(width: 1, height: 30, color: Colors.white24),
                      _buildStatItem('Next Service', 'Oct 24', CupertinoIcons.calendar),
                      Container(width: 1, height: 30, color: Colors.white24),
                      _buildStatItem('Status', 'Healthy', CupertinoIcons.checkmark_shield_fill),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                // 3. التابات (TabBar) - الستايل المطور
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.textMain,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 4,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5),
                  tabs: const [
                    Tab(text: 'HISTORY'),
                    Tab(text: 'MAINTENANCE'),
                    Tab(text: 'EMERGENCY'),
                  ],
                ),

                // 4. محتوى التابات (TabBarView)
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      HistoryTab(),
                      MaintenanceTab(),
                      EmergencyTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ودجت بناء عناصر شريط الحالة
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}