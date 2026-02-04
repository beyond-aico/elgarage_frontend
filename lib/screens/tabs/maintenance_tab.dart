import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_provider.dart';

class MaintenanceTab extends StatefulWidget {
  const MaintenanceTab({super.key});

  @override
  State<MaintenanceTab> createState() => _MaintenanceTabState();
}

class _MaintenanceTabState extends State<MaintenanceTab> {
  int? _selectedMilestone;

  @override
  Widget build(BuildContext context) {
    // استخدام listen: true (الافتراضي) لأننا نحتاج لتحديث الواجهة عند تغيير أي داتا في البروفايدر
    final provider = Provider.of<AppProvider>(context);
    
    // 1. حساب المسافات بناءً على قراءة العداد الحالية من البروفايدر
    final current = provider.currentMilestone;
    final prev = current - 10000;
    final next = current + 10000;

    // تعيين المسافة المختارة افتراضياً لتكون المسافة الموصى بها
    _selectedMilestone ??= current;

    // 2. جلب العناصر بناءً على المسافة المختارة (المنطق ده موجود داخل البروفايدر)
    final items = provider.getMaintenanceItemsFor(_selectedMilestone!);

    return Column(
      children: [
        // --- القسم الأول: شريط اختيار المسافة (Milestone Selector) ---
        Container(
          height: 100,
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            children: [
              if (prev > 0) 
                _milestoneCard(prev, "Previous", _selectedMilestone == prev),
              _milestoneCard(current, "Recommended", _selectedMilestone == current),
              _milestoneCard(next, "Upcoming", _selectedMilestone == next),
            ],
          ),
        ),

        // --- القسم الثاني: قائمة قطع الصيانة ---
        Expanded(
          child: items.isEmpty 
          ? const Center(child: Text("No items defined for this milestone."))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 5, 16, 16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                
                // أعلام مساعدة لتحديد الحالة البصرية (Flags)
                bool isPastView = _selectedMilestone! < current;
                bool isDone = isPastView && !item.isMissed;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    // تحويل اللون للكهرماني (Amber) في حالة الـ Missed لتعزيز الهوية التحذيرية
                    color: item.isMissed ? Colors.amber.withOpacity(0.08) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: item.isMissed ? Colors.amber.withOpacity(0.5) : Colors.grey.shade200,
                      width: item.isMissed ? 1.5 : 1,
                    ),
                    boxShadow: [
                      if (!item.isMissed)
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
                    ],
                  ),
                  child: Row(
                    children: [
                      // أيقونة الحالة (Status Icon)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: item.isMissed 
                              ? Colors.amber.withOpacity(0.2) 
                              : AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item.isMissed 
                              ? CupertinoIcons.exclamationmark_triangle_fill 
                              : CupertinoIcons.settings,
                          color: item.isMissed ? Colors.amber[700] : AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 15),
                      
                      // تفاصيل القطعة
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: item.isMissed ? Colors.brown[700] : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            if (item.isMissed)
                              const Text(
                                "Missed in previous service!", 
                                style: TextStyle(fontSize: 11, color: Colors.amber, fontWeight: FontWeight.bold)
                              )
                            else if (isDone)
                               const Text(
                                "Completed", 
                                style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.bold)
                              )
                            else
                              Text(
                                item.category, 
                                style: const TextStyle(fontSize: 11, color: Colors.grey)
                              ),
                          ],
                        ),
                      ),

                      // الأكشن (Action)
                      if (isDone)
                        const Icon(CupertinoIcons.check_mark_circled_solid, color: AppColors.success)
                      else 
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${item.price.toInt()} EGP', 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)
                            ),
                            const SizedBox(height: 5),
                            InkWell(
                              onTap: () {
                                provider.addToCart([item]);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("${item.name} added to cart"), duration: const Duration(seconds: 1))
                                );
                              },
                              child: const Icon(CupertinoIcons.add_circled_solid, color: AppColors.primary, size: 28),
                            )
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
        ),

        // --- القسم الثالث: زر "إضافة الكل" (يظهر فقط في المسافة الموصى بها) ---
        if (_selectedMilestone == current && items.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
              onPressed: () {
                provider.addToCart(items);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("All recommended items added to cart"))
                );
              },
              child: const Text(
                "Add All to Cart", 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
              ),
            ),
          )
      ],
    );
  }

  // ودجت كارت المسافة (Helper)
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
          boxShadow: [
            if(isSelected)
              BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label, 
              style: TextStyle(
                fontSize: 11, 
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white70 : Colors.grey
              )
            ),
            const SizedBox(height: 4),
            Text(
              "${km ~/ 1000}k", 
              style: TextStyle(
                fontSize: 22, 
                fontWeight: FontWeight.bold, 
                color: isSelected ? Colors.white : AppColors.textPrimary
              )
            ),
            Text(
              "km", 
              style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : AppColors.textPrimary)
            ),
          ],
        ),
      ),
    );
  }
}