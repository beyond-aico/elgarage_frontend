import 'package:elgarage/core/models/product_model.dart';
import 'package:elgarage/core/ui/textured_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/app_provider.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, 
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: TexturedBackground(
          child: Column(
            children: [
              // --- 1. الهيدر الموحد ---
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02, vertical: 5),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textMain),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'MY CART',
                        style: TextStyle(
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textMain, 
                          letterSpacing: 1,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),

              // --- 2. محتوى السلة ---
              Expanded(
                child: Consumer<AppProvider>(
                  builder: (context, provider, _) {
                    final cartItems = provider.cartItems;
                    if (cartItems.isEmpty) return _buildEmptyCart(screenWidth);

                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 10),
                      itemCount: cartItems.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _buildCartItem(context, cartItems[index], provider, screenWidth, index);
                      },
                    );
                  },
                ),
              ),

              // --- 3. قسم الدفع والمراكز ---
              _buildBottomSummary(context, screenWidth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, ProductModel item, AppProvider provider, double screenWidth, int index) {
    return Dismissible(
      key: Key(item.id + index.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 25),
        decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(20)),
        child: const Icon(CupertinoIcons.delete, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => provider.removeFromCart(item),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 80,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                ),
                child: Center(
                  child: Icon(
                    item.category == 'Service' ? CupertinoIcons.wrench_fill : CupertinoIcons.cube_box_fill,
                    color: AppColors.textMain.withAlpha(100),
                    size: 30,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: const BoxDecoration(
                    color: AppColors.textMain,
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.name.toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              item.category,
                              style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${item.price.toInt()} EGP',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSummary(BuildContext context, double screenWidth) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        if (provider.cartItems.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: EdgeInsets.fromLTRB(25, 20, 25, MediaQuery.of(context).padding.bottom + 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
            boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 20, offset: const Offset(0, -5))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.textMain, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  icon: const Icon(CupertinoIcons.wrench, color: AppColors.textMain, size: 18),
                  label: const Text("Book Installation Center", style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w900, fontSize: 13)),
                  onPressed: () => _showServiceCentersSheet(context),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("TOTAL AMOUNT", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                  Text(
                    '${provider.cartTotal.toInt()} EGP',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.textMain),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textMain,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                    shadowColor: AppColors.textMain.withAlpha(100),
                  ),
                  onPressed: () {
                    // تحويل السعر لصيغة نصية عشرية (0.00)
                    final String amountStr = provider.cartTotal.toStringAsFixed(2);

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) => PaypalCheckoutView(
                          sandboxMode: true,
                          clientId: "AS3ird1lER-YiSo5GBwcetm6XkRZEMJw4PXkATyn-uwHmtDVqOOsvu5bPqJo3dixDCZT8K9fGqXsd2Nz",
                          secretKey: "EOcshM8io2zPZ8eI4WvfA-0-wddnedvvZNJLWwj_hwi9iSytoDoH_cGNeulGGnc3VT7U661F9GF5mmhd",
                          transactions: [
                            {
                              "amount": {
                                "total": amountStr,
                                "currency": "USD",
                                "details": {
                                  "subtotal": amountStr,
                                  "shipping": '0',
                                  "shipping_discount": 0
                                }
                              },
                              "description": "General Maintenance", // وصف مبسط لتجنب الرفض
                              "item_list": {
                                "items": provider.cartItems.map((item) => {
                                  "name": "Service Unit", // اسم ثابت لتجاوزCompliance check
                                  "quantity": 1,
                                  "price": item.price.toStringAsFixed(2),
                                  "currency": "USD"
                                }).toList(),
                              }
                            }
                          ],
                          note: "Beyond AI Terminal - Safe Payment",
                          onSuccess: (Map params) async {
                            provider.addServiceLog({
                              'name': 'Paid via PayPal',
                              'date': DateTime.now(),
                              'mileage': provider.selectedCar?.currentKm ?? 0.0,
                              'parts': provider.cartItems.map((e) => e.name).toList(),
                            });
                            provider.cartItems.clear();
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Payment Successful!"), backgroundColor: AppColors.success),
                            );
                          },
                          onError: (error) {
                            print("❌ PayPal Error: $error");
                            Navigator.pop(context);
                          },
                          onCancel: () => Navigator.pop(context),
                        ),
                      ),
                    );
                  },
                  child: const Text("PROCEED TO CHECKOUT", style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyCart(double screenWidth) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.cart, size: screenWidth * 0.25, color: Colors.grey.withAlpha(50)),
          const SizedBox(height: 20),
          const Text("Your cart is empty", style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text("Add premium parts to get started", style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  void _showServiceCentersSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        final provider = Provider.of<AppProvider>(context, listen: false);
        final centers = provider.serviceCenters;

        return Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("SELECT CENTER", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(CupertinoIcons.xmark_circle_fill, color: Colors.grey)),
                ],
              ),
              const Text("Installation cost will be added automatically.", style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 20),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: centers.length,
                  itemBuilder: (context, index) {
                    final center = centers[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.black.withAlpha(5)),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(backgroundColor: Colors.white, child: Icon(CupertinoIcons.location_solid, color: AppColors.primary, size: 20)),
                        title: Text(center['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text(center['location']),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('+${center['labor_cost']} EGP', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textMain, fontSize: 12)),
                            const Icon(CupertinoIcons.add_circled_solid, color: AppColors.primary, size: 22),
                          ],
                        ),
                        onTap: () {
                          provider.addToCart([
                            ProductModel(
                              id: 'SVC-${DateTime.now().millisecondsSinceEpoch}',
                              name: 'Installation: ${center['name']}',
                              price: center['labor_cost'],
                              category: 'Service', 
                              imagePath: provider.getImageForPart('Service'), 
                            )
                          ]);
                          Navigator.pop(context);
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