import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_provider.dart';

class MaintenanceTab extends StatelessWidget {
  const MaintenanceTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final packageItems = provider.maintenancePackage;

        // حساب إجمالي سعر الباقة
        final double packageTotal = packageItems.fold(0, (sum, item) => sum + item.price);

        return Column(
          children: [
            // عنوان توضيحي
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.primary.withOpacity(0.05),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.info, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Recommended maintenance for 60,000 KM service.",
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            // قائمة المكونات
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: packageItems.length,
                itemBuilder: (context, index) {
                  final item = packageItems[index];
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 10),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        // أيقونة حسب النوع (بسيط)
                        child: Icon(
                          item.category == 'Oils' ? CupertinoIcons.drop_fill : CupertinoIcons.settings,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(item.category),
                      trailing: Text(
                        '${item.price.toStringAsFixed(0)} EGP',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                  );
                },
              ),
            ),

            // زرار الإضافة (Sticky Bottom)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Package:", style: TextStyle(color: Colors.grey)),
                      Text(
                        '$packageTotal EGP',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        // 1. إضافة العناصر للسلة
                        provider.addToCart(packageItems);

                        // 2. رسالة تأكيد
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Package added to cart successfully!'),
                            backgroundColor: AppColors.success,
                            action: SnackBarAction(
                              label: 'GO TO CART',
                              textColor: Colors.white,
                              onPressed: () {
                                // هنا هنفعّل كود التنقل للكارت لاحقاً
                              },
                            ),
                          ),
                        );
                      },
                      icon: const Icon(CupertinoIcons.cart_badge_plus, color: Colors.white),
                      label: const Text("Add Package to Cart", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}