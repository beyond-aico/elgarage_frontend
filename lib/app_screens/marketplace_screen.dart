import 'package:elgarage/app_screens/orders_screen.dart';
import 'package:elgarage/core/models/product_model.dart';
import 'package:elgarage/core/app_ui/textured_background.dart';
import 'package:elgarage/app_screens/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/app_provider.dart';
import 'package:easy_localization/easy_localization.dart';
class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double headerHeight = screenWidth * 0.55;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: TexturedBackground(
        child: Column(
          children: [
            // --- 1. الهيدر المطور (مع زر الطلبات والسلة) ---
            Stack(
              children: [
                ClipPath(
                  clipper: MarketplaceWaveClipper(),
                  child: Container(
                    height: headerHeight,
                    width: double.infinity,
                    color: AppColors.textMain,
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'marketplace.title'.tr(),
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.07,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                Text(
                                  'marketplace.subtitle'.tr(),
                                  style: TextStyle(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.bold, letterSpacing: 1),
                                ),
                              ],
                            ),
                            // أزرار الأكشن الموحدة
                            Row(
                              children: [
                                _buildHeaderIcon(
                                  context, 
                                  icon: Icons.receipt_long_rounded, 
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()))
                                ),
                                const SizedBox(width: 12),
                                _buildCartButton(context),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        _buildSearchBar(),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // --- 2. المحتوى القابل للسكرول ---
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -35),
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // التصنيفات
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: _buildCategoryList(screenWidth),
                      ),
                    ),

                    // شبكة المنتجات المحدثة
                    Consumer<AppProvider>(
                      builder: (context, provider, _) {
                        final products = provider.marketProducts;
                        return SliverPadding(
                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.65, // تعديل النسبة لتناسب التفاصيل
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => _buildProductCard(context, products[index], provider),
                              childCount: products.length,
                            ),
                          ),
                        );
                      },
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 120)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- كارت المنتج المطور (Modern Sport Style) ---
  Widget _buildProductCard(BuildContext context, ProductModel product, AppProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          // 1. مساحة الصورة
          Expanded(
            flex: 11,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: const BoxDecoration(
                color: Color(0xFFF8F8F8),
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Image.asset(
                product.imagePath ?? 'assets/images/engine_oil.jpg',
                fit: BoxFit.contain,
              ),
            ),
          ),
          // 2. تفاصيل القطعة (Dark Section)
          Expanded(
            flex: 9,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.textMain,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.name.toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('marketplace.price_label'.tr(), style: TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold)),
                          Text(
                            '${product.price.toInt()} EGP',
                            style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      // زر الإضافة للسلة
                      GestureDetector(
                        onTap: () {
                          provider.addToCart([product]);
                          _showAddSuccess(context, product.name);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8)],
                          ),
                          child: const Icon(Icons.add_shopping_cart_rounded, color: Colors.black, size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- ويدجت أيقونة الهيدر ---
  Widget _buildHeaderIcon(BuildContext context, {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
    );
  }

  // --- زر السلة مع البادج ---
  Widget _buildCartButton(BuildContext context) {
    return Consumer<AppProvider>(builder: (context, provider, _) {
      return Stack(
        alignment: Alignment.topRight,
        children: [
          _buildHeaderIcon(
            context, 
            icon: CupertinoIcons.cart_fill, 
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()))
          ),
          if (provider.cartItems.isNotEmpty)
            Transform.translate(
              offset: const Offset(4, -4),
              child: CircleAvatar(
                radius: 8,
                backgroundColor: Colors.redAccent,
                child: Text(
                  '${provider.cartItems.length}',
                  style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: 'marketplace.search_hint'.tr(),
          hintStyle: TextStyle(color: Colors.white24, fontSize: 12, letterSpacing: 1),
          prefixIcon: Icon(CupertinoIcons.search, color: AppColors.primary, size: 18),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildCategoryList(double screenWidth) {
    return Consumer<AppProvider>(builder: (context, provider, _) {
      final categories = provider.categories;
      return SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            return Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                    ),
                    child: Icon(cat['icon'], color: AppColors.textMain, size: 22),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cat['name'].toString().toUpperCase(),
                    style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.textMain, letterSpacing: 0.5),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }

  void _showAddSuccess(BuildContext context, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${name.toUpperCase()} ADDED TO CART", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textMain,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }
}

// الـ Clipper كما هو مع الحفاظ على الانحناء
class MarketplaceWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 45);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 45);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}