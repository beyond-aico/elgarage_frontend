import 'package:elgarage/core/ui/textured_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/maintenance_provider.dart'; // ✅ تم التأكد من الاستيراد

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return TexturedBackground(
      child: Stack(
        children: [
          // 1. القائمة (تستخدم الآن MaintenanceProvider)
          Consumer<MaintenanceProvider>( // ✅ التغيير لـ MaintenanceProvider
            builder: (context, mProvider, child) {
              final logs = mProvider.serviceHistory; // ✅ استخدام القائمة الموحدة serviceHistory
              
              if (logs.isEmpty) {
                return _buildEmptyState(screenWidth);
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 120), 
                physics: const BouncingScrollPhysics(),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return _buildIndustrialLogCard(log, screenWidth);
                },
              );
            },
          ),

          // 2. زر الإضافة
          Positioned(
            bottom: 100, 
            right: 20,
            child: FloatingActionButton.extended(
              heroTag: 'add_service_record_unique_tag',
              backgroundColor: AppColors.textMain,
              elevation: 10,
              onPressed: () => _showAddLogSheet(context),
              label: const Text(
                "NEW RECORD", 
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5)
              ),
              icon: const Icon(CupertinoIcons.add, color: AppColors.primary, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // --- ويدجت الكارت (Industrial Style) ---
  Widget _buildIndustrialLogCard(log, double screenWidth) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 65,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
              ),
              child: const Center(
                child: Icon(CupertinoIcons.wrench_fill, color: AppColors.primary, size: 24),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: const BoxDecoration(
                  color: AppColors.textMain,
                  borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            log.serviceName.toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(CupertinoIcons.checkmark_circle_fill, color: Colors.green, size: 16),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          DateFormat('dd MMM yyyy').format(log.date),
                          style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        if (log.mileage > 0) ...[
                          const SizedBox(width: 10),
                          Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
                          const SizedBox(width: 10),
                          Text('${log.mileage.toInt()} KM', style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ],
                    ),
                    if (log.partsReplaced.isNotEmpty) ...[
                      const Divider(color: Colors.white10, height: 20),
                      Wrap(
                        spacing: 6, runSpacing: 4,
                        children: log.partsReplaced.map<Widget>((part) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: Colors.white.withAlpha(15), borderRadius: BorderRadius.circular(5)),
                          child: Text(part.toString(), style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold)),
                        )).toList(),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- شيت الإضافة (Add Sheet) ---
  void _showAddLogSheet(BuildContext context) {
    final nameController = TextEditingController();
    final mileageController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    List<String> selectedParts = [];
    final List<String> availableParts = ['Engine Oil', 'Oil Filter', 'Brake Pads', 'Battery', 'Tires', 'Coolant', 'Spark Plugs'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20, 
              left: 25, right: 25, top: 25
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(child: Text("NEW SERVICE LOG", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5))),
                const SizedBox(height: 25),
                
                _buildSheetField(nameController, "Service Name", CupertinoIcons.wrench),
                const SizedBox(height: 15),
                _buildSheetField(mileageController, "Mileage (km)", CupertinoIcons.speedometer, type: TextInputType.number),
                const SizedBox(height: 15),
                
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context, 
                      initialDate: selectedDate, 
                      firstDate: DateTime(2000), 
                      lastDate: DateTime.now()
                    );
                    if (picked != null) setState(() => selectedDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300), 
                      borderRadius: BorderRadius.circular(15)
                    ),
                    child: Row(
                      children: [
                        const Icon(CupertinoIcons.calendar, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Text(DateFormat('dd/MM/yyyy').format(selectedDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 25),
                const Text("Select Replaced Parts:", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                const SizedBox(height: 12),
                
                Wrap(
                  spacing: 8,
                  children: availableParts.map((part) {
                    final isSelected = selectedParts.contains(part);
                    return FilterChip(
                      label: Text(part, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : Colors.black87)),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      checkmarkColor: Colors.white,
                      onSelected: (val) => setState(() => val ? selectedParts.add(part) : selectedParts.remove(part)),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 30),
                
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary, 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 5,
                    ),
                    onPressed: () {
                      if (nameController.text.isNotEmpty) {
                        // ✅ التغيير لـ MaintenanceProvider واستخدام مفاتيح مطابقة للموديل
                        Provider.of<MaintenanceProvider>(context, listen: false).addServiceLog({
                          'serviceName': nameController.text, // مفتاح 'serviceName' للموديل
                          'serviceDate': selectedDate.toIso8601String(), // مفتاح 'serviceDate' للموديل
                          'mileageKm': double.tryParse(mileageController.text) ?? 0.0, // مفتاح 'mileageKm' للموديل
                          'parts': selectedParts,
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("SAVE RECORD", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildSheetField(TextEditingController controller, String label, IconData icon, {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      ),
    );
  }

  Widget _buildEmptyState(double screenWidth) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.doc_text_search, size: 80, color: Colors.grey.withAlpha(50)),
          const SizedBox(height: 15),
          const Text("No history found.", style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold)),
          const Text("Record your first maintenance now.", style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}