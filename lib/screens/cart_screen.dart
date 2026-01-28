import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/app_provider.dart';
import '../data/models/product_model.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("My Cart", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          final cartItems = provider.cartItems;
          
          if (cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.cart, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 20),
                  const Text("Your cart is empty", style: TextStyle(color: Colors.grey, fontSize: 18)),
                ],
              ),
            );
          }

          return Column(
            children: [
              // 1. قائمة المنتجات
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartItems.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Dismissible( // عشان نسحب العنصر نمسحه
                      key: Key(item.id + index.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: AppColors.error,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        provider.removeFromCart(item);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 50, height: 50,
                            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                            child: Icon(item.category == 'Service' ? CupertinoIcons.wrench_fill : CupertinoIcons.cube_box, color: AppColors.primary),
                          ),
                          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(item.category),
                          trailing: Text('${item.price.toInt()} EGP', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 2. الجزء السفلي (زرار المراكز + الدفع)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(1), blurRadius: 10, offset: const Offset(0, -5))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- زرار مراكز الخدمة (المطلوب) ---
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: const BorderSide(color: AppColors.primary, width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(CupertinoIcons.wrench, color: AppColors.primary),
                        label: const Text("Book Installation at Service Center", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        onPressed: () => _showServiceCentersSheet(context),
                      ),
                    ),
                    
                    const SizedBox(height: 20),

                    // تفاصيل السعر
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Amount:", style: TextStyle(fontSize: 16, color: Colors.grey)),
                        Text(
                          '${provider.cartTotal.toInt()} EGP',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // زرار الدفع (Checkout)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          // هنا هنربط ببوابة الدفع (Paymob/Stripe) مستقبلاً
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Proceeding to Payment..."), backgroundColor: AppColors.success),
                          );
                        },
                        child: const Text("Checkout Now", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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

  // --- دالة عرض مراكز الخدمة (Sheet) ---
  void _showServiceCentersSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        final provider = Provider.of<AppProvider>(context, listen: false);
        final centers = provider.serviceCenters;

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Select Service Center", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("Choose a center to install your parts. Labor cost will be added to cart.", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              
              Expanded(
                child: ListView.builder(
                  itemCount: centers.length,
                  itemBuilder: (context, index) {
                    final center = centers[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 0,
                      color: Colors.grey[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(backgroundColor: Colors.white, child: Icon(CupertinoIcons.location_solid, color: AppColors.primary)),
                        title: Text(center['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(center['location']),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('+${center['labor_cost']} EGP', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary)),
                            const SizedBox(height: 4),
                            const Icon(CupertinoIcons.add_circled_solid, color: AppColors.primary, size: 20),
                          ],
                        ),
                        onTap: () {
                          // إضافة تكلفة التركيب كمنتج في السلة
                          provider.addToCart([
                            ProductModel(
                              id: 'SVC-${DateTime.now().millisecondsSinceEpoch}',
                              name: 'Installation: ${center['name']}',
                              price: center['labor_cost'],
                              category: 'Service', // تصنيف خاص
                            )
                          ]);
                          Navigator.pop(context); // قفل الشيت
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Installation at ${center['name']} added!"), backgroundColor: AppColors.success),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}