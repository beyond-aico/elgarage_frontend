import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/app_provider.dart';
import '../core/ui/textured_background.dart';
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
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);

    // ✅ التعديلات الأساسية: جلب بيانات الصيانة بمجرد فتح الصفحة
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
  PopupMenuButton<String>(
    icon: const Icon(Icons.settings_outlined, color: AppColors.textMain),
    onSelected: (value) {
      if (value == 'delete') _showDeleteConfirmation(context, provider, selectedCar.id);
    },
    itemBuilder: (BuildContext context) => [
      const PopupMenuItem<String>(
        value: 'delete',
        child: Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red, size: 20),
            SizedBox(width: 10),
            Text('Delete Car', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    ],
  ),
],
          ),
          body: TexturedBackground(
            child: Column(
              children: [
                const SizedBox(height: 80), 

                // ✅ تعديل رقم 1: اللوجو مباشرة على الخلفية بدون دوائر أو حدود
                Hero(
                  tag: 'brand_logo_${selectedCar.id}',
                  child: SizedBox(
                    height: 120, // حجم مناسب للظهور بوضوح
                    child: Image.asset(
                      'assets/images/car_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => const Icon(Icons.directions_car, size: 80, color: AppColors.textMain),
                    ),
                  ),
                ),

                const SizedBox(height: 15),
                Text(
                  '${selectedCar.make} ${selectedCar.model}'.toUpperCase(),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                ),
                Text(
                  selectedCar.licensePlate ?? 'No Plate',
                  style: const TextStyle(fontSize: 14, color: AppColors.textSub, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),

                const SizedBox(height: 25),

                // شريط الحالة (Stats Strip) - حماية ضد الـ Overflow
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColors.textMain, 
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 5))
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Current KM', '${selectedCar.currentKm.toInt()} k', CupertinoIcons.speedometer),
                      _divider(),
                      _buildStatItem('Next Service', 'Soon', CupertinoIcons.wrench_fill),
                      _divider(),
                      _buildStatItem('Status', 'Healthy', CupertinoIcons.checkmark_shield_fill),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.textMain,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 4,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                  tabs: const [Tab(text: 'HISTORY'), Tab(text: 'MAINTENANCE')],
                ),

                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [HistoryTab(), MaintenanceTab()],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _divider() => Container(width: 1, height: 30, color: Colors.white24);

// ✅ الإصلاح النهائي لدالة الحذف داخل car_details_screen.dart

void _showDeleteConfirmation(BuildContext context, AppProvider provider, String carId) {
  showCupertinoDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: const Text("Delete Vehicle?"),
      content: const Text("This action cannot be undone. All history logs for this car will be removed."),
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
              Navigator.pop(context); // 1. قفل الديالوج (هذا pop صحيح لأنه حوار)
              
              if (success) {
                // ✅ 2. التعديل الجوهري: العودة للتبويب الأول بدلاً من إغلاق التطبيق
                provider.setTabIndex(0); 
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Vehicle removed from your garage"),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              } else {
                Navigator.pop(context); // قفل الديالوج في حالة الفشل أيضاً
              }
            }
          },
        ),
      ],
    ),
  );
}

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Flexible( // ✅ حماية ضد الـ Overflow لو الرقم كبير
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}