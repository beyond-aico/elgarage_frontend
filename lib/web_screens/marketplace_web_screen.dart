// lib/web_screens/marketplace_web_screen.dart

import 'package:elgarage/core/models/product_model.dart';
import 'package:elgarage/app_screens/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/app_provider.dart';

class MarketplaceWebScreen extends StatelessWidget {
  const MarketplaceWebScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final double screenWidth = MediaQuery.of(context).size.width;

    // ملحوظة: شلنا الـ Row والـ Sidebar لأنهم موجودين في ملف الـ FleetDashboardWeb الأب
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. الهيدر (استخدمنا Expanded لمنع الـ Overflow في العناوين)
          _buildWebHeader(context, provider),
          
          const SizedBox(height: 30),
          // 2. حقل البحث
          _buildSearchBarWeb(),
          
          const SizedBox(height: 40),
          // 3. قسم التصنيفات
          _buildSectionTitle("BROWSE BY CATEGORY"),
          const SizedBox(height: 20),
          _buildCategoryListWeb(),

          const SizedBox(height: 40),
          // 4. شبكة المنتجات
          _buildSectionTitle("PREMIUM INVENTORY"),
          const SizedBox(height: 20),
          _buildProductGrid(provider, screenWidth),
          
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  // هيدر الويب مع حماية من الـ Overflow
  Widget _buildWebHeader(BuildContext context, AppProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded( // ✅ حماية العنوان من الـ Overflow لو الشاشة صغرت
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               SizedBox(height: 5),
               FittedBox( // ✅ تصغير الخط أوتوماتيكياً لو المساحة ضاقت
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  "Marketplace",
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900,                   
                  color: AppColors.textMain, 
),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        _buildCartButtonWeb(context, provider),
      ],
    );
  }

  Widget _buildProductGrid(AppProvider provider, double screenWidth) {
    final products = provider.marketProducts;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        // تعديل عدد العناصر بناءً على عرض الشاشة المتاح فعلياً
        crossAxisCount: screenWidth > 1400 ? 5 : (screenWidth > 900 ? 3 : 2),
        childAspectRatio: 0.75, // زيادة النسبة قليلاً لمنع الـ Bottom Overflow في الكارت
        crossAxisSpacing: 25,
        mainAxisSpacing: 25,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) => _buildProductCardWeb(context, products[index], provider),
    );
  }

  Widget _buildProductCardWeb(BuildContext context, ProductModel product, AppProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: product.imagePath != null
                  ? Image.asset(product.imagePath!, fit: BoxFit.contain)
                  : const Icon(CupertinoIcons.cube_box, size: 40, color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible( // ✅ منع الـ Overflow لو السعر طويل
                      child: Text(
                        '${product.price.toInt()} EGP',
                        style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: () {
                        provider.addToCart([product]);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${product.name} ADDED"), backgroundColor: AppColors.primary),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: AppColors.textMain, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.add_shopping_cart, color: AppColors.primary, size: 16),
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
  }

  Widget _buildSearchBarWeb() {
    return SizedBox(
      width: 400, // تصغير العرض قليلاً ليكون متناسقاً مع الويب
      child: TextField(
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: "Search parts...",
          prefixIcon: const Icon(Icons.search, color: AppColors.textMain),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildCartButtonWeb(BuildContext context, AppProvider provider) {
    return ElevatedButton.icon(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
      icon: const Icon(Icons.shopping_cart, color: Colors.black, size: 20),
      label: Text("CART (${provider.cartItems.length})", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildCategoryListWeb() {
    final List<Map<String, dynamic>> categories = [
      {'name': 'Fluids', 'icon': CupertinoIcons.drop_fill},
      {'name': 'Brakes', 'icon': CupertinoIcons.stop_circle_fill},
      {'name': 'Engine', 'icon': CupertinoIcons.settings_solid},
      {'name': 'Tires', 'icon': CupertinoIcons.play_circle_fill},
      {'name': 'Lighting', 'icon': CupertinoIcons.lightbulb_fill},
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 30),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Icon(cat['icon'], color: AppColors.primary, size: 24),
                ),
                const SizedBox(height: 8),
                Text(cat['name'], style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.primary, letterSpacing: 2));
  }
}