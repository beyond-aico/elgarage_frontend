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
        // 1. القائمة (Service Logs List)
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
                      "No records found.",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 15, 16, 100), // مسافة إضافية للـ FAB
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white, // بوكس أبيض صلب
                    borderRadius: BorderRadius.circular(15), // حواف الكود الثاني
                    border: Border.all(color: Colors.grey.shade100), // برواز الكود الثاني
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04), 
                        blurRadius: 10, 
                        offset: const Offset(0, 4)
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // أيقونة المفك (Wrench) من الكود الثاني
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1), 
                              shape: BoxShape.circle
                            ),
                            child: const Icon(CupertinoIcons.wrench, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 15),
                          
                          // تفاصيل السجل
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  log.serviceName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900, // الوزن العريض من الكود الثاني
                                    fontSize: 16
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      DateFormat('dd MMM yyyy').format(log.date),
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                    if (log.mileage > 0) ...[
                                      const SizedBox(width: 8),
                                      const Icon(Icons.circle, size: 4, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${log.mileage.toInt()} km',
                                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // أيقونة النجاح (Check Circle)
                          const Icon(Icons.check_circle, color: Colors.green, size: 20),
                        ],
                      ),
                      
                      // عرض التاجات (Parts Replaced) - منطق الكود الأول
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
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Text(
                              part, 
                              style: TextStyle(fontSize: 10, color: Colors.grey[700], fontWeight: FontWeight.bold)
                            ),
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

        // 2. زر الإضافة (FAB) - ستايل الكود الثاني (الألوان والمكان)
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            backgroundColor: AppColors.textMain, // اللون الداكن من الكود الثاني
            onPressed: () => _showAddLogSheet(context),
            child: const Icon(Icons.add, color: AppColors.primary, size: 30), // أيقونة بلون المانجا
          ),
        ),
      ],
    );
  }

  // --- شيت إضافة السجل (Add Service Sheet) - منطق الكود الأول مع تحسين الستايل ---
  void _showAddLogSheet(BuildContext context) {
    final nameController = TextEditingController();
    final mileageController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    List<String> selectedParts = [];
    
    final List<String> availableParts = [
      'Engine Oil', 'Oil Filter', 'Air Filter', 'Cabin Filter', 
      'Spark Plugs', 'Brake Pads', 'Tires', 'Battery', 
      'Coolant', 'Wipers', 'Timing Belt', 'Gearbox Oil'
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20, right: 20, top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "Add Service Record", 
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)
                    ),
                  ),
                  const SizedBox(height: 25),
                  
                  // 1. اسم الخدمة
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Service Name",
                      prefixIcon: const Icon(CupertinoIcons.wrench),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // 2. العداد
                  TextField(
                    controller: mileageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Mileage (km)",
                      prefixIcon: const Icon(CupertinoIcons.speedometer),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // 3. اختيار التاريخ
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() => selectedDate = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.calendar, color: Colors.grey),
                          const SizedBox(width: 10),
                          Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                          const Spacer(),
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  // 4. اختيار قطع الغيار (Chips Selector)
                  const Text("Parts Replaced:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  
                  Wrap(
                    spacing: 8,
                    children: availableParts.map((part) {
                      final isSelected = selectedParts.contains(part);
                      return FilterChip(
                        label: Text(part, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black87)),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        checkmarkColor: Colors.white,
                        onSelected: (bool value) {
                          setState(() {
                            if (value) selectedParts.add(part);
                            else selectedParts.remove(part);
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 30),

                  // 5. زر الحفظ
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (nameController.text.isNotEmpty) {
                          double mileage = double.tryParse(mileageController.text) ?? 0.0;
                          
                          Provider.of<AppProvider>(context, listen: false).addServiceLog({
                            'name': nameController.text,
                            'date': selectedDate,
                            'mileage': mileage,
                            'parts': selectedParts,
                          });
                          
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Service Log Saved!"), backgroundColor: AppColors.success)
                          );
                        }
                      },
                      child: const Text(
                        "SAVE RECORD", 
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)
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