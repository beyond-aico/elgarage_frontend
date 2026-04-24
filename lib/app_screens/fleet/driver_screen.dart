import 'package:easy_localization/easy_localization.dart';
// --- FILE: lib/screens/fleet/driver_screen.dart ---

import 'package:elgarage/providers/maintenance_provider.dart';
import 'package:elgarage/app_screens/tabs/maintenance_tab.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/app_ui/textured_background.dart';
import '../../providers/fleet_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_provider.dart';

class DriverScreen extends StatefulWidget {
  const DriverScreen({super.key});

  @override
  State<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _kmController = TextEditingController();
  final TextEditingController _litersController = TextEditingController();
  final TextEditingController _costController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _kmController.dispose();
    _litersController.dispose();
    _costController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final fleet = Provider.of<FleetProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final app = Provider.of<AppProvider>(context);
    final mainProvider = Provider.of<MaintenanceProvider>(context);

    final car = fleet.authenticatedCar;

    return TexturedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15, top: 10, bottom: 10),
            child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
          ),
          leadingWidth: 100, 
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              onPressed: () {
                app.resetOnLogout();
                fleet.resetOnLogout();
                auth.logout();
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (didPop) => false);
              },
            )
          ],
        ),
        body: car == null 
          ? _buildScanPrompt() 
          : Column(
              children: [
                const SizedBox(height: 10),
                
                // ✅ 2️⃣ التعديل: عرض لوجو البراند المظبوط (مثل Hyundai.png أو Kia.png)
                Image.asset(
                  car.localImagePath, // استخدام الـ Getter الذكي اللي صلحناه في الموديل
                  height: 90, // حجم مناسب لصفحة السائق
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) => Image.asset(
                    'assets/images/car_logo.png',
                    height: 90,
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) => const Icon(
                      Icons.directions_car, 
                      size: 60, 
                      color: AppColors.primary
                    ),
                  ),
                ),
                
                const SizedBox(height: 10),
                
                Text(
                  '${car.make} ${car.model}'.toUpperCase(),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textMain),
                ),
                Text(
                  car.licensePlate ?? 'No Plate',
                  style: const TextStyle(fontSize: 13, color: AppColors.textMain, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),
                
                // ... بقية الكود (Statistics Box, Tabs, etc.)
                _buildStatsBox(car, mainProvider),
                const SizedBox(height: 20),
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primary,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: Colors.white60,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  tabs:  [
                    Tab(text: "driver.fuel_tab".tr()),
                    Tab(text: "driver.maint_tab".tr()),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildFuelForm(fleet, app, mainProvider),
                      const MaintenanceTab(isReadOnly: true), 
                    ],
                  ),
                ),
              ],
            ),
      ),
    );
  }

// ... (بقية الدوال المساعدة كما هي بدون تغيير)

  // دالة بناء صندوق الإحصائيات اليدوي (نفس تصميم car_details)
  Widget _buildStatsBox(dynamic car, MaintenanceProvider mainProvider) {
    final String healthStatus = mainProvider.realHealthStatus;
    final int remaining = mainProvider.nextServiceRemainingKm;

    Color healthColor = Colors.greenAccent;
    if (healthStatus == 'OVERDUE') healthColor = Colors.redAccent;
    if (healthStatus == 'SOON') healthColor = AppColors.primary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.textMain, // الصندوق الغامق تماماً مثل car_details
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("driver.current_km_label".tr(), '${car.mileageKm} K', CupertinoIcons.speedometer, AppColors.primary),
          _divider(),
          _buildStatItem("driver.status_label".tr(), healthStatus, CupertinoIcons.checkmark_shield_fill, healthColor),
          _divider(),
          _buildStatItem("driver.remaining_label".tr(), '$remaining KM', CupertinoIcons.hourglass, AppColors.primary),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 25, color: Colors.white10);

  Widget _buildStatItem(String label, String value, IconData icon, Color valColor) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: valColor, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(color: valColor, fontWeight: FontWeight.bold, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 8)),
        ],
      ),
    );
  }

 Widget _buildFuelForm(FleetProvider fleet, AppProvider app, MaintenanceProvider mainProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          // 4️⃣ بوكسات الإدخال بنظام الـ Industrial (أبيض مع ظل) لسهولة الاستخدام
          _buildIndustrialInput(_kmController, "driver.odometer_label".tr(), CupertinoIcons.speedometer),
          const SizedBox(height: 15),
          _buildIndustrialInput(_litersController, "driver.fuel_liters_label".tr(), CupertinoIcons.drop_fill),
          const SizedBox(height: 15),
          _buildIndustrialInput(_costController, "driver.total_cost_label".tr(), CupertinoIcons.money_dollar),
          const SizedBox(height: 30),
          
          if (fleet.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Text(fleet.error!, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),

          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: fleet.isLoading ? null : () async {
                int newKm = int.tryParse(_kmController.text) ?? 0; // تخزين القيمة الجديدة للعداد
                
                final success = await fleet.submitFuelLog(
                  newOdometer: newKm,
                  liters: double.tryParse(_litersController.text) ?? 0,
                  cost: double.tryParse(_costController.text) ?? 0,
                  fuelType: "BENZINE_95", // القيمة التي يقبلها الباك إند
                  appProvider: app,
                );

                if (success && mounted) {
                  // ✅ التعديل الجوهري: تحديث حالة الصيانة بناءً على العداد الجديد فوراً
                  // هذا السطر يضمن أن تابة الصيانة ستتحدث عند السائق والمدير في نفس اللحظة
                  await mainProvider.fetchDueMaintenance(fleet.authenticatedCar!.id, newKm);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(content: Text("driver.success_msg".tr())));
                  
                  // تنظيف الحقول بعد النجاح
                  _kmController.clear(); 
                  _litersController.clear(); 
                  _costController.clear();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textMain,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 8,
              ),
              child: fleet.isLoading 
                ? const CircularProgressIndicator(color: AppColors.primary)
                :  Text("driver.submit_btn".tr(), 
                    style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanPrompt() {
    return  Center(
      child: Padding(
        padding: EdgeInsets.all(40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.qr_code_scanner, size: 80, color: Colors.white24),
            SizedBox(height: 20),
            Text("driver.no_car_error".tr(), 
              textAlign: TextAlign.center, style: TextStyle(color: Colors.white60, fontSize: 14)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildIndustrialInput(TextEditingController controller, String label, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        ),
      ),
    );
  }
}