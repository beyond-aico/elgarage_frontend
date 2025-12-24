import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/app_provider.dart';
import '../widgets/car_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView( // استخدمنا ده عشان الصفحة تبقى Scrollable بشكل سلس
        slivers: [
          // 1. الهيرو سكشن (معمول بـ SliverAppBar عشان يبقى شكله حلو مع السكرول)
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              decoration: const BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Row(
                children: [
                  // صورة البروفايل
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                      image: const DecorationImage(
                        // صورة افتراضية لحد ما نربط Login
                        image: NetworkImage('https://i.pravatar.cc/300'), 
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  
                  // الترحيب ورقم التليفون
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                        const Text(
                          'Hesham Fathy', // اسم المستخدم (Dynamic لاحقاً)
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(CupertinoIcons.phone, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              '+20 100 000 0000',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // زرار الإشعارات (إضافة لطيفة)
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(CupertinoIcons.bell, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
          ),

          // عنوان القائمة
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 25, 20, 10),
              child: Text(
                'My Garage',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),

          // 2. قائمة العربيات
          // بنستخدم Consumer عشان نسمع لأي تغيير في الداتا
          Consumer<AppProvider>(
            builder: (context, provider, child) {
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final car = provider.myCars[index];
                    final isSelected = provider.selectedCar.id == car.id;

                    return CarCard(
                      car: car,
                      isSelected: isSelected,
                      onTap: () {
                        // 1. تحديث العربية المختارة في البروفايدر
                        provider.selectCar(car);
                        
                        // 2. إظهار رسالة صغيرة (SnackBar)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${car.make} ${car.model} Selected'),
                            backgroundColor: AppColors.secondary,
                            duration: const Duration(milliseconds: 500),
                          ),
                        );
                        
                        // ملحوظة: هنا ممكن نعمل Auto Navigate لتاب العربية لو حبيت
                      },
                    );
                  },
                  childCount: provider.myCars.length,
                ),
              );
            },
          ),
          
          // مسافة تحت عشان الفوتر مايغطيش آخر كارت
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}