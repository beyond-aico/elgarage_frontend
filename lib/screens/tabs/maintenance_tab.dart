// --- FILE: lib/screens/tabs/maintenance_tab.dart ---

import 'package:elgarage/core/models/maintenance_item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_provider.dart';
import '../cart_screen.dart'; 

class MaintenanceTab extends StatefulWidget {
  const MaintenanceTab({super.key});

  @override
  State<MaintenanceTab> createState() => _MaintenanceTabState();
}

class _MaintenanceTabState extends State<MaintenanceTab> {
  int? _selectedMilestone;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      if (provider.selectedCar != null) {
        provider.fetchDueMaintenance(carId: provider.selectedCar!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final current = provider.currentMilestone;
    final prev = current - 10000;
    final next = current + 10000;

    _selectedMilestone ??= current;

    List<dynamic> items;
    
    // إذا كنا في التاب الموصى به (Recommended)
    if (_selectedMilestone == current) {
      if (provider.dueMaintenance.isNotEmpty) {
        // ✅ منطق "اللي عليه الدور" الذكي:
        // 1. العثور على أقرب مسافة صيانة قادمة (أصغر Remaining KM)
        final validItems = provider.dueMaintenance.where((e) => e.remainingKm != null);
        
        if (validItems.isNotEmpty) {
          int minRemaining = validItems
              .map((e) => e.remainingKm!)
              .reduce((a, b) => a < b ? a : b);

          // 2. عرض فقط القطع التي موعدها هو الأقرب ( Milestone الحالي) أو المتأخرة
          items = provider.dueMaintenance.where((item) {
            return item.remainingKm == minRemaining || item.status == 'OVERDUE';
          }).toList();
        } else {
          items = provider.dueMaintenance;
        }
      } else {
        // إذا كان السيرفر فارغ، نستخدم المصفوفة المحلية كـ Fallback
        items = provider.getMaintenanceItemsFor(_selectedMilestone!);
      }
    } else {
      // التابات الأخرى تعرض المصفوفة المحلية كالمعتاد
      items = provider.getMaintenanceItemsFor(_selectedMilestone!);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 150),
      children: [
        // 1. شريط اختيار المسافة
        Container(
          height: 100,
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            children: [
              if (prev > 0) _milestoneCard(prev, "Previous", _selectedMilestone == prev),
              _milestoneCard(current, "Recommended", _selectedMilestone == current),
              _milestoneCard(next, "Upcoming", _selectedMilestone == next),
            ],
          ),
        ),

        if (provider.isLoadingMaintenance && _selectedMilestone == current)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else if (items.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text("✨ All Systems Healthy!\nCheck later for maintenance items.", 
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
          )
        else
          ...items.map((item) {
            bool isPastView = _selectedMilestone! < current;
            bool isDone = isPastView && !item.isMissed;

            bool isWarning = false;
            if (item is MaintenanceItem) {
              isWarning = item.status == 'DUE_SOON' || item.status == 'OVERDUE';
            } else {
              isWarning = item.isMissed;
            }

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isWarning ? (item is MaintenanceItem && item.status == 'OVERDUE' ? Colors.red.withAlpha(10) : Colors.amber.withAlpha(20)) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isWarning ? (item is MaintenanceItem && item.status == 'OVERDUE' ? Colors.red.withAlpha(30) : Colors.amber.withAlpha(50)) : Colors.grey.shade200,
                  width: isWarning ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  _buildStatusIcon(item),
                  const SizedBox(width: 15),
                  Expanded(child: _buildItemDetails(item, isDone)),
                  _buildAction(item, isDone, provider, context),
                ],
              ),
            );
          }),

        const SizedBox(height: 30),

        if (items.isNotEmpty && !provider.isLoadingMaintenance)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ElevatedButton.icon(
              onPressed: () {
                provider.addToCart(items);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
              },
              icon: const Icon(Icons.shopping_basket_rounded, color: AppColors.textMain),
              label: const Text("ADD ALL TO CART", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textMain,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: const StadiumBorder(),
                elevation: 6,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusIcon(item) {
    Color iconColor = AppColors.primary;
    IconData iconData = CupertinoIcons.settings;

    if (item is MaintenanceItem) {
      if (item.status == 'OVERDUE') {
        iconColor = Colors.red;
        iconData = CupertinoIcons.exclamationmark_circle_fill;
      } else if (item.status == 'DUE_SOON') {
        iconColor = Colors.orange;
        iconData = CupertinoIcons.exclamationmark_triangle_fill;
      }
    } else if (item.isMissed) {
      iconColor = Colors.amber[700]!;
      iconData = CupertinoIcons.exclamationmark_triangle_fill;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withAlpha(20),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: iconColor, size: 20),
    );
  }

  Widget _buildItemDetails(item, bool isDone) {
    String? remainingText;
    if (item is MaintenanceItem && item.remainingKm != null) {
      remainingText = "${item.remainingKm} KM REMAINING";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        
        if (item is MaintenanceItem && (item.status == 'DUE_SOON' || item.status == 'OVERDUE'))
          Text(
            item.status == 'DUE_SOON' ? "Service Due Soon!" : "Urgent: Service Overdue!", 
            style: TextStyle(
              fontSize: 11, 
              color: item.status == 'DUE_SOON' ? Colors.orange : Colors.red, 
              fontWeight: FontWeight.bold
            )
          )
        else if (item.isMissed)
          const Text("Missed in previous service!", style: TextStyle(fontSize: 11, color: Colors.amber, fontWeight: FontWeight.bold))
        else if (isDone)
          const Text("Completed", style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.bold))
        else
          Text(item.category, style: const TextStyle(fontSize: 11, color: Colors.grey)),

        if (remainingText != null && item is MaintenanceItem)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(remainingText, style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w900)),
          ),
      ],
    );
  }

  Widget _buildAction(item, bool isDone, provider, context) {
    if (isDone) return const Icon(CupertinoIcons.check_mark_circled_solid, color: AppColors.success);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('${item.price.toInt()} EGP', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 5),
        InkWell(
          onTap: () {
            provider.addToCart([item]);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${item.name} added to cart")));
          },
          child: const Icon(CupertinoIcons.add_circled_solid, color: AppColors.primary, size: 28),
        )
      ],
    );
  }

  Widget _milestoneCard(int km, String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedMilestone = km),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 110,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white70 : Colors.grey)),
            Text("${km ~/ 1000}k", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppColors.textPrimary)),
            const Text("km", style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}