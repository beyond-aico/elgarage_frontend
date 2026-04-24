import 'package:easy_localization/easy_localization.dart';
import 'package:elgarage/providers/app_provider.dart';
import 'package:elgarage/app_screens/car_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/fleet_analytics_model.dart';

class AnalyticsDashboard extends StatefulWidget {
  final FleetAnalytics? stats;
  const AnalyticsDashboard({super.key, required this.stats});

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
bool _sortByEfficiency = false; // الترتيب الافتراضي هو الـ Remaining KM

@override
void initState() {
  super.initState();
  // ✅ تعيين الـ initialIndex ليكون 2 (التابة الثالثة - EFFICIENCY)
  _tabController = TabController(
    length: 5, 
    vsync: this, 
    initialIndex: 2, 
  );
}

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  final List<VehicleAnalytic> data = widget.stats?.vehicleBreakdown ?? [];

  // ✅ منطق الترتيب المزدوج
  if (_sortByEfficiency) {
    // الترتيب حسب الكفاءة (من الأفضل للأقل)
    data.sort((a, b) {
      double effA = a.fuelLiters > 0 ? (a.kms / a.fuelLiters) : 0.0;
      double effB = b.fuelLiters > 0 ? (b.kms / b.fuelLiters) : 0.0;
      return effB.compareTo(effA); // Descending: الأفضل فوق
    });
  } else {
    // الترتيب الحالي (الأقرب صيانة للأبعد)
    data.sort((a, b) => a.remainingKms.compareTo(b.remainingKms));
  }
  
    return Column(
      children: [
        // 1. هيدر الإحصائيات الإجمالية (ثابت)
        _buildGlobalStatsOverview(),
        
        const SizedBox(height: 20),
        
        // 2. شريط التبديل (التابات)
TabBar(
  controller: _tabController,
  isScrollable: false,
  indicatorColor: AppColors.primary,
  labelColor: AppColors.primary,
  unselectedLabelColor: Colors.grey,
  labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
  tabs: [
    Tab(text: "fleet.maintenance".tr(), icon: const Icon(Icons.build_circle_outlined, size: 18)), // 1
      Tab(text: "fleet.distance".tr(), icon: const Icon(Icons.speed_outlined, size: 18)),         // 5
    Tab(text: "fleet.efficiency".tr(), icon: const Icon(Icons.analytics_outlined, size: 18)),   // 3 (الجديدة)
     Tab(text: "fleet.chart_fuel_usage_tab".tr(), icon: Icon(Icons.gas_meter_outlined, size: 18)),   // 4
     Tab(text: "fleet.chart_fuel_cost_tab".tr(), icon: Icon(Icons.payments_outlined, size: 18)),     // 2

  ],
),
        
        const SizedBox(height: 15),

SizedBox(
  height: 180,
  child: TabBarView(
    controller: _tabController,
    children: [
      _buildXYChart(
        "fleet.chart_maint_cost".tr(), 
        List.from(data)..sort((a, b) => b.nextMaintenanceCost.compareTo(a.nextMaintenanceCost)), 
        (v) => v.nextMaintenanceCost, 
        AppColors.primary
      ),
      
  // lib/app_screens/fleet/analytics_dashboard.dart

// 1. في تشارت الـ DISTANCE
_buildXYChart(
  "fleet.chart_distance".tr(), 
  List.from(data)..sort((a, b) => b.kms.compareTo(a.kms)), 
  (v) => v.kms.toDouble(), // 👈 هنا استبدل kms بالمسمى الصح للمسافة المقطوعة (Trip)
  const Color.fromARGB(255, 101, 222, 176)
),

// 2. في تشارت الـ EFFICIENCY وحسبة الجدول
_buildXYChart(
  "fleet.chart_efficiency".tr(), 
  List.from(data)..sort((a, b) {
    // 👈 لازم هنا كمان تستبدل v.kms بالمسافة المقطوعة في الفترة
    double effA = a.fuelLiters > 0 ? (a.kms / a.fuelLiters) : 0.0; 
    double effB = b.fuelLiters > 0 ? (b.kms / b.fuelLiters) : 0.0;
    return effB.compareTo(effA);
  }), 
  (v) => v.fuelLiters > 0 ? (v.kms / v.fuelLiters) : 0.0, 
  const Color.fromARGB(255, 101, 222, 176)
),
      _buildXYChart(
        "FUEL CONSUMED (L)".tr(),
        List.from(data)..sort((a, b) => b.fuelLiters.compareTo(a.fuelLiters)), 
        (v) => v.fuelLiters, 
        const Color.fromARGB(255, 101, 222, 176)
      ),
 _buildXYChart(
        "fleet.chart_fuel_cost".tr(), 
        List.from(data)..sort((a, b) => b.totalCost.compareTo(a.totalCost)), 
        (v) => v.totalCost, 
        AppColors.primary
      ),
    ],
  ),
),
        const SizedBox(height: 25),
        _buildMetricTable(data),
      ],
    );
  }

Widget _buildGlobalStatsOverview() {
  final double maintenance = widget.stats?.totalMaintenanceCost ?? 0;
  final double fuel = widget.stats?.totalFuelCost ?? 0;
  final double total = maintenance + fuel;

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 15),
    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
    decoration: BoxDecoration(
      color: AppColors.textMain,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)],
    ),
    child: Column(
      children: [
        Row(
          children: [
            _statBox("fleet.maintenance".tr(), "${maintenance.toInt()}", "EGP", AppColors.primary, AppColors.primary),
            _verticalDivider(),
            _statBox("fleet.total_cost".tr(), "${total.toInt()}", "EGP", AppColors.primary, AppColors.primary),
            _verticalDivider(),
            _statBox("fleet.chart_fuel_cost_tab".tr(), "${fuel.toInt()}", "EGP", AppColors.primary, AppColors.primary),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          child: Divider(color: Color.fromARGB(105, 255, 255, 255), height: 1),
        ),
        Row(
          children: [
            _statBox("fleet.total_kms".tr(), "${widget.stats?.totalKmsDriven ?? 0}", "KM", const Color.fromARGB(255, 101, 222, 176), const Color.fromARGB(255, 101, 222, 176)),
            _verticalDivider(),
            _statBox("fleet.total_fuel".tr(), "${widget.stats?.totalFuelConsumedLiters.toInt() ?? 0}", "LITERS",  Color.fromARGB(255, 101, 222, 176), const Color.fromARGB(255, 101, 222, 176)),
          ],
        ),
      ],
    ),
  );
}
  Widget _verticalDivider() => Container(width: 1, height: 30, color: Colors.white10);

  Widget _statBox(String label, String val, String unit, Color labelColor, Color valueColor) {
  return Expanded(
    child: Column(
      children: [
        // Color.fromARGB(26, 29, 6, 6)عنوان (Function Name)
        Text(
          label, 
          style: TextStyle(color: labelColor, fontSize: 10, fontWeight: FontWeight.bold)
        ),
        const SizedBox(height: 5),
        // اللون الثاني للقيمة الرقمية
        Text(
          val, 
          style: TextStyle(color: valueColor, fontSize: 18, fontWeight: FontWeight.w900)
        ),
        // اللون الأول للوحدة (EGP, KM, etc)
        Text(
          unit, 
          style: TextStyle(color: labelColor, fontSize: 10, fontWeight: FontWeight.bold)
        ),
      ],
    ),
  );
}
  Widget _buildXYChart(String title, List<VehicleAnalytic> data, double Function(VehicleAnalytic) mapper, Color color) {
    double maxValue = data.isEmpty ? 1 : data.map(mapper).reduce((a, b) => a > b ? a : b);
    if (maxValue == 0) maxValue = 1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.textMain,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: data.length,
        itemBuilder: (context, i) {
          double val = mapper(data[i]);
          double ratio = val / maxValue;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(val.toStringAsFixed(0), style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  width: 14,
                  height: (90 * ratio).clamp(2, 90),
                  decoration: BoxDecoration(color: color.withOpacity(0.7), borderRadius: const BorderRadius.vertical(top: Radius.circular(3))),
                ),
                const SizedBox(height: 5),
Text(
  data[i].plateNumber.split('-').last, 
  style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)
),              ],
            ),
          );
        },
      ),
    );
  }

  // ✅ الجدول المطور مع ميزة الضغط للانتقال للتفاصيل
  Widget _buildMetricTable(List<VehicleAnalytic> data) {
  if (data.isEmpty) return const SizedBox();

  // ✅ منطق الترتيب الذكي
  if (_sortByEfficiency) {
    data.sort((a, b) {
      double effA = a.fuelLiters > 0 ? (a.kms / a.fuelLiters) : 0.0;
      double effB = b.fuelLiters > 0 ? (b.kms / b.fuelLiters) : 0.0;

      // 1. لو الاثنين أصفار، يفضلوا زي ما هم
      if (effA == 0 && effB == 0) return 0;
      // 2. لو A بصفر (لسه متحسبش) يروح لآخر الجدول
      if (effA == 0) return 1;
      // 3. لو B بصفر يروح لآخر الجدول
      if (effB == 0) return -1;

      // 4. لو الاثنين أرقام حقيقية، رتب من الأكبر للأصغر (الأحسن فوق)
      return effB.compareTo(effA);
    });
  } else {
    // ترتيب الصيانة المعتاد (الأقرب فالأبعد)
    data.sort((a, b) => a.remainingKms.compareTo(b.remainingKms));
  }

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
    decoration: BoxDecoration(
      color: const Color.fromARGB(53, 255, 255, 255),
      borderRadius: BorderRadius.circular(15),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.0), blurRadius: 5)],
    ),
   child: ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        // ✅ تغليف الجدول بـ Theme لتغيير لون السهم
        child: Theme(
          data: Theme.of(context).copyWith(
            // هنا بنحدد لون السهم (Sort Indicator)
            iconTheme: const IconThemeData(color: AppColors.primary), 
          ),
          child: DataTable(
            showCheckboxColumn: false,
            headingRowColor: WidgetStateProperty.all(Colors.black),
            sortColumnIndex: _sortByEfficiency ? 4 : 3,
            sortAscending: !_sortByEfficiency,
          columns: [
            const DataColumn(label: Text('VEHICLE MODEL', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w900))),
            DataColumn(label: Text("fleet.table_plate".tr(), style: const TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w900))),
            DataColumn(label: Text("fleet.table_current_km".tr(), style: const TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w900))),
            DataColumn(
              onSort: (columnIndex, ascending) => setState(() => _sortByEfficiency = false),
              label: const Text('REMAINING', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w900))
            ),

            const DataColumn(label: Text('NEXT COST', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w900))),
            DataColumn(
              onSort: (columnIndex, ascending) => setState(() => _sortByEfficiency = true),
              label: Text("fleet.efficiency".tr(), style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w900))
            ),
          ],
          rows: data.map((v) {
            bool isUrgent = v.remainingKms < 1000;
            double efficiency = v.fuelLiters > 0 ? (v.kms / v.fuelLiters) : 0.0;

            return DataRow(
              onSelectChanged: (selected) {
                if (selected == true) {
                  final app = Provider.of<AppProvider>(context, listen: false);
                  try {
                    final fullCar = app.myCars.firstWhere((c) => c.id == v.carId);
                    app.setSelectedCar(fullCar);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CarDetailsScreen()));
                  } catch (e) {
                    debugPrint("❌ Analytics Error: Car ${v.plateNumber} not found.");
                  }
                }
              },
              cells: [
                DataCell(Text("${v.brand} ${v.model}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppColors.textMain))),
                DataCell(Text(v.plateNumber, style: const TextStyle(fontSize: 10, color: AppColors.textMain))),
                DataCell(Text("${v.kms}", style: const TextStyle(fontSize: 10, color: AppColors.textMain))),
                DataCell(Text("${v.remainingKms} KM", 
                    style: TextStyle(color: isUrgent ? Colors.red : Colors.green, fontWeight: FontWeight.bold, fontSize: 10))),
                
                // ✅ عرض الكفاءة: لو صفر يكتب --- للتوضيح إنه لسه متحسبش
              
                
                DataCell(Text("${v.nextMaintenanceCost.toInt()} EGP", 
                    style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 10))),
                DataCell(Text(efficiency == 0 ? "---" : "${efficiency.toStringAsFixed(1)} KM/L", 
                    style: TextStyle(
                      color: efficiency == 0 ? Colors.grey : (efficiency >= 10 ? Colors.green.shade700 : Colors.orange.shade800), 
                      fontWeight: FontWeight.bold, 
                      fontSize: 10
                    ))),
              ],
            );
          }).toList(),
      ),
        ),
      ),
    ),
  );
}
}