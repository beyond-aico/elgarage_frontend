import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_provider.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Service Logs List
        Consumer<AppProvider>(
          builder: (context, provider, child) {
            final logs = provider.historyLogs;
            
            if (logs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.doc_text_search, size: 60, color: Colors.grey[300]),
                    const SizedBox(height: 10),
                    const Text(
                      "No history yet.",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 100), // Extra padding for FAB
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(03),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Date Icon
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(CupertinoIcons.calendar, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 15),
                          
                          // Main Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  log.serviceName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      DateFormat('dd MMM yyyy').format(log.date),
                                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                                    ),
                                    if (log.mileage > 0) ...[
                                      const SizedBox(width: 10),
                                      Container(
                                        width: 4, height: 4, 
                                        decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        '${log.mileage.toInt()} km',
                                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Success Check
                          const Icon(CupertinoIcons.check_mark_circled, color: AppColors.success),
                        ],
                      ),
                      
                      // Display Replaced Parts Tags (if any)
                      if (log.partsReplaced.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: log.partsReplaced.map((part) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Text(part, style: TextStyle(fontSize: 11, color: Colors.grey[700])),
                          )).toList(),
                        )
                      ]
                    ],
                  ),
                );
              },
            );
          },
        ),

        // 2. Floating Action Button (+)
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            backgroundColor: AppColors.primary,
            shape: const CircleBorder(),
            onPressed: () => _showAddLogSheet(context),
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
        ),
      ],
    );
  }

  // --- ADD SERVICE SHEET ---
  void _showAddLogSheet(BuildContext context) {
    final nameController = TextEditingController();
    final mileageController = TextEditingController();
    
    // Default values
    DateTime selectedDate = DateTime.now();
    List<String> selectedParts = [];
    
    // Hardcoded list of common parts for the user to pick from
    final List<String> availableParts = [
      'Engine Oil', 'Oil Filter', 'Air Filter', 'Cabin Filter', 
      'Spark Plugs', 'Brake Pads', 'Tires', 'Battery', 
      'Coolant', 'Wipers', 'Timing Belt', 'Gearbox Oil'
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Needed for the keyboard to push the sheet up
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // We use StatefulBuilder INSIDE the sheet to manage the local state 
        // (like changing date or selecting chips) without rebuilding the whole page.
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "Add Service Record", 
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                    ),
                  ),
                  const SizedBox(height: 25),
                  
                  // 1. Service Name
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Service Name",
                      hintText: "e.g. 40,000 km Maintenance",
                      prefixIcon: const Icon(CupertinoIcons.wrench),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // 2. Mileage Field (NEW)
                  TextField(
                    controller: mileageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Mileage (km)",
                      hintText: "e.g. 40500",
                      prefixIcon: const Icon(CupertinoIcons.speedometer),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // 3. Date Picker
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.calendar, color: Colors.grey),
                          const SizedBox(width: 10),
                          Text(
                            DateFormat('dd/MM/yyyy').format(selectedDate),
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  // 4. Parts Selector (NEW)
                  const Text(
                    "Parts Replaced:", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                  ),
                  const SizedBox(height: 10),
                  
                  Container(
                    constraints: const BoxConstraints(maxHeight: 150), // Limit height if too many tags
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 0,
                        children: availableParts.map((part) {
                          final isSelected = selectedParts.contains(part);
                          return FilterChip(
                            label: Text(part),
                            selected: isSelected,
                            selectedColor: AppColors.primary.withAlpha(2),
                            checkmarkColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.primary : Colors.black87,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              fontSize: 13
                            ),
                            backgroundColor: Colors.grey[100],
                            onSelected: (bool value) {
                              setState(() {
                                if (value) {
                                  selectedParts.add(part);
                                } else {
                                  selectedParts.remove(part);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 5. Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
// ... داخل الملف عند الزرار Save Record

onPressed: () {
  if (nameController.text.isNotEmpty) {
    double mileage = double.tryParse(mileageController.text) ?? 0.0;
    
    // التعديل هنا: نبعت البيانات كـ Map أو Object واحد
    // لأن الدالة في البروفايدر: void addServiceLog(dynamic log)
    Provider.of<AppProvider>(context, listen: false).addServiceLog({
      'name': nameController.text,
      'date': selectedDate,
      'mileage': mileage,
      'parts': selectedParts,
    });
    
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Service Log Saved (Local Only)!"))
    );
  }
},
// ...
                      child: const Text(
                        "Save Record", 
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}