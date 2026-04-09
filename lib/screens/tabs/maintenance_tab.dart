// --- FILE: lib/screens/tabs/maintenance_tab.dart ---

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../providers/maintenance_provider.dart';
import '../../core/models/product_model.dart'; // ✅ إضافة موديل المنتج
import '../cart_screen.dart';

class MaintenanceTab extends StatefulWidget {
  final bool isReadOnly; // ✅ إضافة المتغير
const MaintenanceTab({super.key, this.isReadOnly = false}); // ✅ تحديث الـ Constructor
  @override
  State<MaintenanceTab> createState() => _MaintenanceTabState();
}

class _MaintenanceTabState extends State<MaintenanceTab> {
  int? _selectedMilestone;

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final mainProvider = Provider.of<MaintenanceProvider>(context);

    // حساب الـ Milestone الحالي
    final int current = mainProvider.getCurrentMilestone(
      appProvider.selectedCar?.mileageKm ?? 0,
    );
    final int prev = current - 10000;
    final int next = current + 10000;


    _selectedMilestone ??= current;

    // جلب القطع
    final List<ProductModel> items = mainProvider.getMaintenanceItemsFor(
      _selectedMilestone!,
    );
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
              if (prev > 0)
                _milestoneCard(prev, "Previous", _selectedMilestone == prev),
              _milestoneCard(
                current,
                "Recommended",
                _selectedMilestone == current,
              ),
              _milestoneCard(next, "Upcoming", _selectedMilestone == next),
            ],
          ),
        ),

        // 2. قائمة قطع الصيانة
        if (items.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text("No items defined for this milestone."),
            ),
          )
        else
          ...items.map((ProductModel item) {
            // ✅ تحديد نوع البيانات هنا
            bool isPastView = _selectedMilestone! < current;
            bool isDone = isPastView && !item.isMissed;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: item.isMissed
                    ? Colors.amber.withAlpha(20)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: item.isMissed
                      ? Colors.amber.withAlpha(50)
                      : Colors.grey.shade200,
                  width: item.isMissed ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  _buildStatusIcon(item),
                  const SizedBox(width: 15),
                Expanded(child: _buildItemDetails(item, isDone)),
                  if (!widget.isReadOnly)
                    _buildAction(item, isDone, appProvider, context),
                ],
              ),
            );
          }),

        const SizedBox(height: 30),

        if (items.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ElevatedButton.icon(
              onPressed: () {
                appProvider.addToCart(items);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
              icon: const Icon(
                Icons.shopping_basket_rounded,
                color: AppColors.textMain,
              ),
              label: const Text(
                "ADD ALL TO CART",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
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

  // --- Widgets المساعدة مع تحديد الأنواع بدقة لإزالة أخطاء الـ Diagnostic ---

  Widget _buildStatusIcon(ProductModel item) {
    // ✅ إضافة النوع ProductModel
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: item.isMissed
            ? Colors.amber.withAlpha(40)
            : AppColors.primary.withAlpha(20),
        shape: BoxShape.circle,
      ),
      child: Icon(
        item.isMissed
            ? CupertinoIcons.exclamationmark_triangle_fill
            : CupertinoIcons.settings,
        color: item.isMissed ? Colors.amber[700] : AppColors.primary,
        size: 20,
      ),
    );
  }

  Widget _buildItemDetails(ProductModel item, bool isDone) {
    // ✅ إضافة النوع ProductModel
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        if (item.isMissed)
          const Text(
            "Missed in previous service!",
            style: TextStyle(
              fontSize: 11,
              color: Colors.amber,
              fontWeight: FontWeight.bold,
            ),
          )
        else if (isDone)
          const Text(
            "Completed",
            style: TextStyle(
              fontSize: 11,
              color: AppColors.success,
              fontWeight: FontWeight.bold,
            ),
          )
        else
          Text(
            item.category,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
      ],
    );
  }

  Widget _buildAction(
    ProductModel item,
    bool isDone,
    AppProvider provider,
    BuildContext context,
  ) {
    // ✅ إضافة النوع ProductModel
    if (isDone) {
      return const Icon(
        CupertinoIcons.check_mark_circled_solid,
        color: AppColors.success,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${item.price.toInt()} EGP',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 5),
        InkWell(
          onTap: () {
            provider.addToCart([item]);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("${item.name} added to cart")),
            );
          },
          child: const Icon(
            CupertinoIcons.add_circled_solid,
            color: AppColors.primary,
            size: 28,
          ),
        ),
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
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? Colors.white70 : Colors.grey,
              ),
            ),
            Text(
              "${km ~/ 1000}k",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const Text(
              "km",
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
