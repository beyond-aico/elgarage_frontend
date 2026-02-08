// --- FILE: lib/screens/tabs/maintenance_tab.dart ---

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
    // ✅ مكان التعديل: طلب بيانات الصيانة من السيرفر فور فتح الشاشة
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
      // ✅ إذا كان السيرفر (PostgreSQL) أرسل داتا، اعرضها فوراً
      // وإذا كانت فارغة، استخدم المصفوفة المحلية كـ Fallback
      items = provider.dueMaintenance.isNotEmpty 
          ? provider.dueMaintenance 
          : provider.getMaintenanceItemsFor(_selectedMilestone!);
    } else {
      // التابات الأخرى (Previous/Upcoming) تعرض المصفوفة المحلية حالياً
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
              child: Text("No items defined for this milestone.", 
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
          )
        else
          ...items.map((item) {
            bool isPastView = _selectedMilestone! < current;
            bool isDone = isPastView && !item.isMissed;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: item.isMissed ? Colors.amber.withAlpha(20) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: item.isMissed ? Colors.amber.withAlpha(50) : Colors.grey.shade200,
                  width: item.isMissed ? 1.5 : 1,
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

        // زر ADD ALL TO CART
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

  // --- Widgets مساعدة للحفاظ على نظافة الكود والـ UI الأصلي ---

  Widget _buildStatusIcon(item) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: item.isMissed ? Colors.amber.withAlpha(40) : AppColors.primary.withAlpha(20),
        shape: BoxShape.circle,
      ),
      child: Icon(
        item.isMissed ? CupertinoIcons.exclamationmark_triangle_fill : CupertinoIcons.settings,
        color: item.isMissed ? Colors.amber[700] : AppColors.primary,
        size: 20,
      ),
    );
  }

  Widget _buildItemDetails(item, bool isDone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        if (item.isMissed)
          const Text("Missed in previous service!", style: TextStyle(fontSize: 11, color: Colors.amber, fontWeight: FontWeight.bold))
        else if (isDone)
          const Text("Completed", style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.bold))
        else
          Text(item.category, style: const TextStyle(fontSize: 11, color: Colors.grey)),
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