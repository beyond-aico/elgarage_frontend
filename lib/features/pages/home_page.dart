import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart'; // إضافة البروفايدر

import '../../core/constants/app_colors.dart';
import '../../core/widgets/hero_section.dart';
import '../../core/providers/cart_provider.dart'; // استدعاء السلة
// import 'cart_page.dart'; // (سيتم إنشاؤها لاحقاً)

import 'spare_parts_page.dart';
import 'care_page.dart';
import 'maintenance_page.dart';
import 'services_page.dart';
import 'sos_page.dart';
import 'tires_batteries.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // قائمة الخدمات
    final List<Map<String, dynamic>> services = [
      {
        'title': 'services_title',
        'icon': Icons.speed,
        'page': const ServicesPage(),
        'color': Colors.teal
      },
      {
        'title': 'spare_parts_title',
        'icon': Icons.settings_input_component,
        'page': const SparePartsPage(),
        'color': Colors.indigo
      },
      {
        'title': 'maintenance_title',
        'icon': Icons.build_circle_outlined,
        'page': const MaintenancePage(),
        'color': Colors.blue
      },
      {
        'title': 'car_care_title',
        'icon': Icons.cleaning_services_outlined,
        'page': const CarePage(),
        'color': Colors.purple
      },
      {
        'title': 'tires_batteries',
        'icon': Icons.car_repair,
        'page': const TiresBatteriesPage(),
        'color': Colors.orange
      },
      {
        'title': 'sos_title',
        'icon': Icons.warning_amber_rounded,
        'page': const SosPage(),
        'color': Colors.redAccent
      },
      {
        'title': 'my_garage',
        'icon': Icons.garage_outlined,
        'page': null,
        'color': const Color.fromARGB(255, 51, 51, 51)
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      // 1. إضافة AppBar شفاف لعرض السلة
      extendBodyBehindAppBar: true, // عشان الهيرو سكشن ياخد الشاشة من فوق
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // أيقونة السلة مع العداد
          Consumer<CartProvider>(
            builder: (_, cart, ch) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Badge(
                label: Text(cart.itemCount.toString()), // رقم المنتجات
                isLabelVisible: cart.itemCount > 0, // يظهر فقط لو فيه منتجات
                backgroundColor: Colors.red,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2), // خلفية شفافة للأيقونة
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.shopping_cart, color: Color.fromARGB(255, 0, 0, 0)),
                    onPressed: () {
                      // الانتقال لصفحة السلة (سنفعل هذا السطر بعد إنشاء الصفحة)
                      // Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage()));
                      
                      // مؤقتاً: رسالة بسيطة
                      ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text("Cart Page Coming Soon!"))
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column( // شلنا SafeArea عشان التصميم يغطي الشاشة ورا الـ AppBar
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 2. الهيرو سكشن (أضفنا padding علوي عشان نعوض الـ AppBar)
          Padding(
            padding: EdgeInsets.only(top: 0.h), 
            child: HeroSection(
              onSearch: (query) {
                // منطق البحث
              },
            ),
          ),
          
          // 3. شبكة الخدمات
          Expanded(
            child: AnimationLimiter(
              child: GridView.builder(
                padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 10.h, bottom: 80.h), // Bottom padding عشان الـ Assistant FAB
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15.w,
                  mainAxisSpacing: 15.h,
                  childAspectRatio: 1.1,
                ),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 500),
                    columnCount: 2,
                    child: ScaleAnimation(
                      child: FadeInAnimation(
                        child: _buildGlassCard(context, services[index]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard(BuildContext context, Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        if (item['title'] == 'my_garage') {
          Navigator.pushNamed(context, '/garage');
        } else if (item['page'] != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => item['page']));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10.r, offset: Offset(0, 5.h))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: (item['color'] as Color).withAlpha(30), // تعديل الشفافية لتكون أجمل
                shape: BoxShape.circle,
              ),
              child: Icon(item['icon'], color: item['color'], size: 28.sp),
            ),
            SizedBox(height: 12.h),
            Text(
              (item['title'] as String).tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary, // استخدام لون التطبيق
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}