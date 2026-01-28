import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_provider.dart';
// import '../../data/models/product_model.dart'; // مش محتاجينه دلوقتي

class MaintenanceTab extends StatelessWidget { // حولناها لـ Stateless
  const MaintenanceTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingMaintenance) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = provider.dueMaintenance;

        if (items.isEmpty) {
          return const Center(child: Text("No maintenance required right now."));
        }

        return Column(
          children: [
            // Header بسيط
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Text(
                    "Due Services (${items.length})",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // القائمة
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: item.isMissed ? Colors.red.withOpacity(0.05) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: item.isMissed ? Colors.red.withOpacity(0.3) : Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Icon
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: item.isMissed ? Colors.red.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item.isMissed ? Icons.warning : Icons.build,
                            color: item.isMissed ? Colors.red : Colors.blue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 15),
                        
                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                item.category,
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                        ),

                        // Price & Action
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "${item.price.toInt()} EGP",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            // زرار وهمي للإضافة للسلة
                            const Icon(Icons.add_circle, color: AppColors.primary),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}