import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // عشان تنسيق التاريخ
import '../../core/constants/app_colors.dart';
import '../../providers/app_provider.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. قائمة السجلات
        Consumer<AppProvider>(
          builder: (context, provider, child) {
            final logs = provider.historyLogs;
            
            if (logs.isEmpty) {
              return const Center(child: Text("No history yet."));
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 80), // 80 عشان الزرار مايغطيش آخر عنصر
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
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // أيقونة التاريخ
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(CupertinoIcons.calendar, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 15),
                      // التفاصيل
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log.serviceName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              DateFormat('dd MMM yyyy').format(log.date), // تنسيق زي: 24 Dec 2025
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      // علامة صح
                      const Icon(CupertinoIcons.check_mark_circled, color: AppColors.success),
                    ],
                  ),
                );
              },
            );
          },
        ),

        // 2. زرار الإضافة العائم (+)
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

  // فنكشن بتفتح الشيت اللي تحت عشان نضيف داتا
  void _showAddLogSheet(BuildContext context) {
    final nameController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // عشان الكيبورد مايغطيش الشيت
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
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
              const Text("Add Service Record", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              // حقل اسم الصيانة
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Service Name",
                  hintText: "e.g. Oil Change, Brake Pads",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(CupertinoIcons.wrench),
                ),
              ),
              const SizedBox(height: 15),

              // حقل التاريخ (بسيط)
              StatefulBuilder( // عشان نحدث النص لما نختار تاريخ
                builder: (context, setState) {
                  return InkWell(
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
                        border: Border.all(color: Colors.grey),
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
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 20),

              // زرار الحفظ
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      // نضيف للسجل
                      Provider.of<AppProvider>(context, listen: false)
                          .addServiceLog(nameController.text, selectedDate);
                      Navigator.pop(context); // نقفل الشيت
                    }
                  },
                  child: const Text("Save Record", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}