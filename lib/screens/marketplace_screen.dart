import 'package:elgarage/core/models/product_model.dart';
import 'package:elgarage/core/ui/textured_background.dart';
import 'package:elgarage/screens/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/app_provider.dart';

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
            // --- 1. الهيدر المقوس (Fixed Header) ---
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
                                  'Marketplace',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.07,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const Text(
                                  'Premium Parts & Accessories',
                                  style: TextStyle(fontSize: 12, color: Colors.white70),
                                ),
                              ],
                            ),
                            _buildCartButton(context),
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

            // --- 2. الجزء القابل للسكرول (تم سحبه للأعلى لإلغاء الفراغ) ---
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -35), // ✅ سحب المحتوى للأعلى ليدخل في تجويف الهيدر
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // أ. قسم التصنيفات (بدون مسافات زائدة)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 0, bottom: 10), // ✅ إلغاء التوب بادينج
                        child: _buildCategoryList(screenWidth),
                      ),
                    ),

                    // ب. شبكة المنتجات
                    Consumer<AppProvider>(
                      builder: (context, provider, _) {
                        final products = provider.marketProducts;
                        return SliverPadding(
                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.62,
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => _buildIndustrialProductCard(context, products[index], provider),
                              childCount: products.length,
                            ),
                          ),
                        );
                      },
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- دوال بناء الـ UI (كما هي مع تحسينات طفيفة) ---

  Widget _buildIndustrialProductCard(BuildContext context, ProductModel product, AppProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withAlpha(05), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(08), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: product.imagePath != null
                    ? Image.asset(product.imagePath!, fit: BoxFit.contain)
                    : const Icon(CupertinoIcons.cube_box, size: 40, color: Colors.grey),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppColors.textMain,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.name.toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                  const Divider(color: Colors.white10, height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${product.price.toInt()} EGP',
                        style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w900),
                      ),
                      GestureDetector(
                        onTap: () {
                          provider.addToCart([product]);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("${product.name} added"), behavior: SnackBarBehavior.floating, backgroundColor: AppColors.primary),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                          child: const Icon(CupertinoIcons.add, color: Colors.black, size: 16),
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
  
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: const TextField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search engine oils, brake pads...",
          hintStyle: TextStyle(color: AppColors.textMain, fontSize: 14),
          prefixIcon: Icon(CupertinoIcons.search, color: AppColors.textMain, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

 Widget _buildCartButton(BuildContext context) {
    return Consumer<AppProvider>(builder: (context, provider, _) {
      return Stack(
        alignment: Alignment.topRight,
        children: [
          // الوعاء الأساسي للأيقونة
          Container(
            // إضافة padding لضمان مساحة لمس مريحة وشكل متناسق
            padding: const EdgeInsets.all(8), 
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(15), 
              borderRadius: BorderRadius.circular(12)
            ),
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
              // ✅ التصحيح: استخدام خاصية child بدلاً من icon
              child: const Icon(
                CupertinoIcons.cart_fill, 
                size: 26, 
                color: AppColors.primary
              ),
            ),
          ),
          
          // البادج (الرقم) يظهر فقط إذا كانت السلة غير فارغة
          if (provider.cartItems.isNotEmpty)
            Transform.translate(
              // إزاحة بسيطة للبادج ليكون مظهره احترافي أكثر
              offset: const Offset(5, -5), 
              child: CircleAvatar(
                radius: 8,
                backgroundColor: AppColors.error,
                child: FittedBox( // حماية النص من الـ Overflow لو الرقم كبر
                  child: Text(
                    '${provider.cartItems.length}', 
                    style: const TextStyle(
                      fontSize: 10, 
                      color: Colors.white, 
                      fontWeight: FontWeight.w900
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
  Widget _buildCategoryList(double screenWidth) {
    final List<Map<String, dynamic>> categories = [
      {'name': 'Fluids', 'icon': CupertinoIcons.drop_fill},
      {'name': 'Brakes', 'icon': CupertinoIcons.stop_circle_fill},
      {'name': 'Engine', 'icon': CupertinoIcons.settings_solid},
      {'name': 'Tires', 'icon': CupertinoIcons.play_circle_fill},
      {'name': 'Lighting', 'icon': CupertinoIcons.lightbulb_fill},
      {'name': 'Electronics', 'icon': CupertinoIcons.device_phone_portrait},
      {'name': 'Interior', 'icon': CupertinoIcons.house_fill},
    ];

    return SizedBox(
      height: 95,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withAlpha(50)),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                  ),
                  child: Icon(cat['icon'], color: AppColors.primary, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  cat['name'],
                  style: const TextStyle(fontSize: 11, color: AppColors.textMain, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

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