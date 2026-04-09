import 'package:elgarage/providers/app_provider.dart';
import 'package:elgarage/screens/car_details_screen.dart';
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

  @override
  void initState() {
    super.initState();
    // تعريف 4 تابات لإدارة الرسوم البيانية
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // جلب البيانات وتطبيق الترتيب (الأقرب صيانة للأبعد)
    final List<VehicleAnalytic> data = widget.stats?.vehicleBreakdown ?? [];
    data.sort((a, b) => a.remainingKms.compareTo(b.remainingKms));

    return Column(
      children: [
        // 1. هيدر الإحصائيات الإجمالية (ثابت)
        _buildGlobalStatsOverview(),
        
        const SizedBox(height: 20),
        
        // 2. شريط التبديل (التابات)
        TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
          tabs: const [
            Tab(text: "EXPENSES", icon: Icon(Icons.payments_outlined, size: 18)),
            Tab(text: "FUEL USAGE", icon: Icon(Icons.gas_meter_outlined, size: 18)),
            Tab(text: "DISTANCE", icon: Icon(Icons.speed_outlined, size: 18)),
            Tab(text: "EFFICIENCY", icon: Icon(Icons.analytics_outlined, size: 18)),
          ],
        ),
        
        const SizedBox(height: 15),

        // 3. منطقة الرسوم البيانية (فقط هذا الجزء الذي يتحرك مع التابات)
        SizedBox(
          height: 180,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildXYChart("TOTAL COST (EGP)", data, (v) => v.totalCost, Colors.blueAccent),
              _buildXYChart("FUEL CONSUMED (L)", data, (v) => v.fuelLiters, AppColors.primary),
              _buildXYChart("DISTANCE DRIVEN (KM)", data, (v) => v.kms.toDouble(), Colors.greenAccent),
              _buildXYChart("COST PER KM (EGP)", data, (v) => v.kms > 0 ? (v.totalCost / v.kms) : 0.0, Colors.orangeAccent),
            ],
          ),
        ),

        const SizedBox(height: 25),

        // 4. جدول الصيانة (ثابت لا يتأثر بالسحب يميناً أو يساراً)
        _buildMetricTable(data),
      ],
    );
  }

  Widget _buildGlobalStatsOverview() {
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
              _statBox("MAINTENANCE COST", "${widget.stats?.totalMaintenanceCost.toInt() ?? 0}", "EGP", Colors.orangeAccent),
              _verticalDivider(),
              _statBox("FUEL COST", "${widget.stats?.totalFuelCost.toInt() ?? 0}", "EGP", Colors.blueAccent),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            child: Divider(color: Colors.white10, height: 1),
          ),
          Row(
            children: [
              _statBox("TOTAL KMS", "${widget.stats?.totalKmsDriven ?? 0}", "KM", Colors.greenAccent),
              _verticalDivider(),
              _statBox("TOTAL FUEL", "${widget.stats?.totalFuelConsumedLiters.toInt() ?? 0}", "LITERS", AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() => Container(width: 1, height: 30, color: Colors.white10);

  Widget _statBox(String label, String val, String unit, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(val, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900)),
          Text(unit, style: const TextStyle(color: Colors.white24, fontSize: 7, fontWeight: FontWeight.bold)),
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
                Text(data[i].plateNumber.split('-').last, style: const TextStyle(color: Colors.white24, fontSize: 7)),
              ],
            ),
          );
        },
      ),
    );
  }

  // ✅ الجدول المطور مع ميزة الضغط للانتقال للتفاصيل
  Widget _buildMetricTable(List<VehicleAnalytic> data) {
    if (data.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: const Color.fromARGB(53, 255, 255, 255), // الحفاظ على خلفية شفافة شيك
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal, // للسماح بعرض الـ 5 أعمدة
          child: DataTable(
            showCheckboxColumn: false, // ✅ لإخفاء خانة الاختيار وجعل السطر بالكامل قابل للضغط
            headingRowColor: WidgetStateProperty.all(AppColors.textMain),
            columnSpacing: 15,
            headingRowHeight: 45,
            columns: const [
              DataColumn(label: Text('VEHICLE MODEL', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w900))),
              DataColumn(label: Text('PLATE', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w900))),
              DataColumn(label: Text('CURRENT KM', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w900))),
              DataColumn(label: Text('REMAINING', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w900))),
              DataColumn(label: Text('NEXT COST', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w900))),
            ],
            rows: data.map((v) {
              bool isUrgent = v.remainingKms < 1000;
              return DataRow(
                // ✅ إضافة خاصية الانتقال عند الضغط على أي مكان في السطر
                onSelectChanged: (selected) {
                  if (selected == true) {
                    final app = Provider.of<AppProvider>(context, listen: false);
                    try {
                      // 1. إيجاد السيارة الكاملة من القائمة الرئيسية بناءً على الـ carId
                      final fullCar = app.myCars.firstWhere((c) => c.id == v.carId);
                      // 2. تحديدها كسيارة مختارة في الـ Provider
                      app.setSelectedCar(fullCar);
                      // 3. الانتقال لصفحة التفاصيل
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CarDetailsScreen()));
                    } catch (e) {
                      debugPrint("❌ Analytics Error: Car ${v.plateNumber} not found in the master list.");
                    }
                  }
                },
                cells: [
                  DataCell(Text("${v.brand} ${v.model}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppColors.textMain))),
                  DataCell(Text(v.plateNumber, style: const TextStyle(fontSize: 10, color: AppColors.textMain))),
                  DataCell(Text("${v.kms}", style: const TextStyle(fontSize: 10, color: AppColors.textMain))),
                  DataCell(Text("${v.remainingKms} KM", 
                      style: TextStyle(color: isUrgent ? Colors.red : Colors.green, fontWeight: FontWeight.bold, fontSize: 10))),
                  DataCell(Text("${v.nextMaintenanceCost.toInt()} EGP", 
                      style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 10))),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}