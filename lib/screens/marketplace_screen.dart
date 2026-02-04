import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/app_provider.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // --- 1. الهيرو والبحث (Header) ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // العنوان وسلة المشتريات
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Marketplace',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      // زرار الكارت الصغير فوق
                      Stack(
                        children: [
                          const Icon(CupertinoIcons.cart, size: 28, color: AppColors.textPrimary),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                              child: const SizedBox(width: 4, height: 4), // نقطة حمراء لو فيه حاجات في السلة
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // شريط البحث
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Search parts, centers...",
                      prefixIcon: const Icon(CupertinoIcons.search, color: Colors.grey),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // --- 2. التصنيفات (Categories) - سكرول بالعرض ---
            SizedBox(
              height: 100,
              child: Consumer<AppProvider>(
                builder: (context, provider, _) {
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: provider.categories.length,
                    itemBuilder: (context, index) {
                      final cat = provider.categories[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
                                ],
                              ),
                              child: Icon(cat['icon'], color: AppColors.primary),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              cat['name'],
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // --- 3. شبكة المنتجات (Products Grid) ---
            Expanded(
              child: Consumer<AppProvider>(
                builder: (context, provider, _) {
                  final products = provider.marketProducts;
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // عمودين
                      childAspectRatio: 0.75, // نسبة الطول للعرض (عشان الكارت يبقى طويل شوية)
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // صورة المنتج
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                ),
                                child: Center(
                                  child: Icon(CupertinoIcons.cube_box, size: 50, color: Colors.grey[400]),
                                  // لما تربط صور حقيقية استخدم Image.network هنا
                                ),
                              ),
                            ),
                            
                            // التفاصيل
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.category,
                                    style: TextStyle(fontSize: 10, color: AppColors.primary.withOpacity(0.8), fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${product.price.toInt()} EGP',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
                                      ),
                                      // زرار الإضافة السريع
                                      InkWell(
                                        onTap: () {
                                          provider.addToCart([product]);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("Added to Cart"), duration: Duration(milliseconds: 500)),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                                          child: const Icon(CupertinoIcons.add, color: Colors.white, size: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}