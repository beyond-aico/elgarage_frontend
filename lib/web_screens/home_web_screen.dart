// lib/web_screens/home_web_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/app_provider.dart';

class HomeWebScreen extends StatelessWidget {
  const HomeWebScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildLargeStatCard("Fleet Size", "${app.myCars.length}", Icons.directions_car_filled, AppColors.primary),
              _buildLargeStatCard("Fuel Consumption", "1,240L", Icons.local_gas_station, Colors.blueAccent),
              _buildLargeStatCard("Due Maintenance", "03", Icons.warning_amber_rounded, Colors.orange),
              _buildLargeStatCard("Efficiency", "98%", Icons.bolt_rounded, Colors.green),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildSection("ANALYTICS ENGINE", 300, const Center(child: Icon(Icons.analytics_outlined, color: Colors.white10, size: 50)))),
              const SizedBox(width: 25),
              Expanded(flex: 1, child: _buildSection("QUICK ACTIONS", 300, Column(
                children: [
                  _quickActionButton("Add New Vehicle", Icons.add),
                  _quickActionButton("Generate Report", Icons.file_download),
                  _quickActionButton("Emergency SOS", Icons.sos, color: Colors.redAccent),
                ],
              ))),
            ],
          ),
          const SizedBox(height: 30),
          const Text("MANAGED UNITS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 15),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 350, mainAxisExtent: 180, crossAxisSpacing: 20, mainAxisSpacing: 20),
            itemCount: app.myCars.length,
            itemBuilder: (context, index) => _buildMinimalCarCard(app.myCars[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white.withAlpha(5), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white.withAlpha(5))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 15),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
            Text(label, style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, double height, Widget child) {
    return Container(
      height: height, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white.withAlpha(5), borderRadius: BorderRadius.circular(15)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
        const SizedBox(height: 20),
        Expanded(child: child),
      ]),
    );
  }

  Widget _quickActionButton(String label, IconData icon, {Color color = Colors.white24}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withAlpha(5), minimumSize: const Size(double.infinity, 50), alignment: Alignment.centerLeft),
        onPressed: () {}, icon: Icon(icon, size: 16, color: color), label: Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
      ),
    );
  }

  Widget _buildMinimalCarCard(dynamic car) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.textMain, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withAlpha(5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(car.plateNumber ?? "N/A", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900)),
            const Icon(Icons.more_vert, color: Colors.white24, size: 16),
          ]),
          const Spacer(),
          Text(car.model ?? "Unknown Model", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          Text("${car.currentKm} KM", style: const TextStyle(color: Colors.white24, fontSize: 12)),
        ],
      ),
    );
  }
}