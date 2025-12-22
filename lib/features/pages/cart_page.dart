import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/models/product_model.dart'; // عشان نستخدم الموديل في الزيادة
import '../../core/payment/fawry_service.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "shopping_cart".tr(), // "سلة الشراء"
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 20.sp),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),
        actions: [
          // زر لحذف كل حاجة
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              Provider.of<CartProvider>(context, listen: false).clear();
            },
          )
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          // 1. حالة السلة فارغة
          if (cart.itemCount == 0) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 100.sp, color: Colors.grey.withOpacity(0.5)),
                  SizedBox(height: 20.h),
                  Text(
                    "cart_empty".tr(), // "السلة فارغة"
                    style: TextStyle(fontSize: 18.sp, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // 2. قائمة المنتجات
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: cart.items.length,
                  itemBuilder: (ctx, i) {
                    final item = cart.items.values.toList()[i];
                    return Container(
                      margin: EdgeInsets.only(bottom: 16.h),
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                        ],
                      ),
                      child: Row(
                        children: [
                          // صورة المنتج
                          Container(
                            width: 80.w,
                            height: 80.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              color: Colors.grey[100],
                              image: item.imageUrl.isNotEmpty
                                  ? DecorationImage(image: NetworkImage(item.imageUrl), fit: BoxFit.cover)
                                  : null,
                            ),
                            child: item.imageUrl.isEmpty
                                ? const Icon(Icons.image_not_supported, color: Colors.grey)
                                : null,
                          ),
                          SizedBox(width: 16.w),
                          
                          // التفاصيل
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title, 
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: AppColors.textPrimary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 5.h),
                                Text(
                                  "${item.price} EGP", 
                                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14.sp),
                                ),
                              ],
                            ),
                          ),
                          
                          // التحكم في الكمية
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 18, color: Colors.red),
                                  onPressed: () {
                                    cart.removeSingleItem(item.id);
                                  },
                                ),
                                Text(
                                  "${item.quantity}",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 18, color: Colors.green),
                                  onPressed: () {
                                    // هنا بنعمل حيلة بسيطة عشان نزود الكمية
                                    // بنبعت موديل بنفس الـ ID، فالبروفايدر هيزود الكمية أوتوماتيك
                                    cart.addItem(ProductModel(
                                      id: item.id,
                                      title: item.title,
                                      price: item.price,
                                      imageUrl: item.imageUrl,
                                      category: '', // مش مهمة هنا
                                    ));
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // 3. الفوتر (الإجمالي وزر الدفع)
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("total".tr(), style: TextStyle(fontSize: 16.sp, color: Colors.grey[600])),
                        Text(
                          "${cart.totalAmount.toStringAsFixed(2)} EGP",
                          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    
                    // زر الدفع (فوري)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC107), // أصفر فوري
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          // استدعاء خدمة فوري
                          FawryService.initiatePayment(
                            context: context,
                            amount: cart.totalAmount, // المبلغ من السلة
                            userId: "USER_123", // هنجيبه بعدين من البروفايل الحقيقي
                            userMobile: "010xxxxxxx",
                            userEmail: "client@example.com",
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.payment, color: Colors.black),
                            SizedBox(width: 10.w),
                            Text(
                              "checkout".tr(), // "دفع بواسطة فوري"
                              style: TextStyle(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}