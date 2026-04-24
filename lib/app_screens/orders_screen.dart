import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ تأكد من وجود الاستيراد
import '../providers/app_provider.dart';
import '../core/constants/app_colors.dart';
import '../core/app_ui/textured_background.dart';
import '../core/app_ui/app_footer.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String deliveryMethod = 'CENTER'; 
  String? selectedCenter; // المتغير المسؤول عن التحديد
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // ✅ أول ما الصفحة تفتح، بنشوف هل فيه مركز في الكارت ولا لأ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      if (provider.preSelectedCenterName != null) {
        setState(() {
          selectedCenter = provider.preSelectedCenterName;
          deliveryMethod = 'CENTER'; // بنحول الطريقة لـ CENTER أوتوماتيك
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: TexturedBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _sectionTitle("DELIVERY METHOD"),
                    _buildMethodToggle(),
                    const SizedBox(height: 30),
                    
                    // عرض الاختيارات بناءً على الطريقة
                    if (deliveryMethod == 'CENTER') _buildCenterSelection(provider),
                    if (deliveryMethod == 'HOME') _buildHomeForm(),
                    
                    const SizedBox(height: 50),
                    _buildConfirmButton(provider),
                  ],
                ),
              ),
              const SizedBox(height: 80), 
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          provider.setTabIndex(2);
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.storefront, color: Colors.black, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AppFooter(
        currentIndex: provider.currentTabIndex,
        onTap: (index) {
          provider.setTabIndex(index);
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
    );
  }

  // ✅ التعديل الذكي: لو اختار من الكارت بنثبت الاختيار، لو لا بنفتح القائمة
  Widget _buildCenterSelection(AppProvider provider) {
    final String? cartCenter = provider.preSelectedCenterName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("SELECT SERVICE CENTER"),
        if (cartCenter != null)
          // 1. لو اليوزر اختار مركز من صفحة My Cart بنعرضه هنا كأنه "مأكد"
          _buildPreSelectedCard(cartCenter) 
        else
          // 2. لو مأختارش، بنعرض القائمة (مع إصلاح مشكلة الـ Radio)
          ...provider.serviceCenters.map((center) {
            // حل مشكلة التعليم على الكل: التأكد من مقارنة النصوص بوضوح
            final bool isThisSelected = selectedCenter == center['name'];
            
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isThisSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isThisSelected ? AppColors.primary : Colors.black12,
                  width: isThisSelected ? 2 : 1,
                ),
              ),
              child: RadioListTile<String>(
                // ✅ تحديد النوع <String> هنا هو اللي بيحل مشكلة الـ Mark الجماعي
                value: center['name'] as String,
                groupValue: selectedCenter,
                activeColor: AppColors.primary,
                title: Text(center['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text(center['location'], style: const TextStyle(fontSize: 12)),
                secondary: IconButton(
                  icon: const Icon(CupertinoIcons.location_solid, color: AppColors.primary, size: 22),
                  onPressed: () async {
                    final String? mapUrl = center['mapUrl'];
                    if (mapUrl != null && mapUrl.isNotEmpty) {
                      final Uri url = Uri.parse(mapUrl);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    }
                  },
                ),
                onChanged: (String? val) {
                  setState(() {
                    selectedCenter = val; // تحديث المركز المختار بس
                  });
                },
              ),
            );
          }).toList(),
      ],
    );
  }

  // ويدجت للمركز اللي تم اختياره مسبقاً من الكارت
  Widget _buildPreSelectedCard(String centerName) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.stars, color: AppColors.primary, size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("LINKED TO YOUR CART", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textMain, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(centerName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textMain, fontSize: 15)),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildMethodToggle() {
    return Row(
      children: [
        _methodCard("AT CENTER", Icons.store, deliveryMethod == 'CENTER', () => setState(() => deliveryMethod = 'CENTER')),
        const SizedBox(width: 15),
        _methodCard("HOME", Icons.home, deliveryMethod == 'HOME', () => setState(() => deliveryMethod = 'HOME')),
      ],
    );
  }

  Widget _buildHomeForm() {
    return Column(
      children: [
        _buildTextField(addressController, "Detailed Address & Landmark", Icons.location_on),
        const SizedBox(height: 15),
        _buildTextField(phoneController, "Phone Number", Icons.phone, isPhone: true),
      ],
    );
  }

  Widget _buildConfirmButton(AppProvider provider) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textMain, 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
        ),
        onPressed: () {
          if (deliveryMethod == 'CENTER' && selectedCenter == null) return;
          
          Map<String, dynamic> details = {
            'method': deliveryMethod,
            'address': deliveryMethod == 'CENTER' ? selectedCenter : addressController.text,
            'phone': phoneController.text,
          };

          provider.placeOrder(details);

          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text("ORDER PLACED!"),
              content: const Text("Your maintenance request has been recorded."),
              actions: [
                CupertinoDialogAction(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
              ],
            ),
          );
        },
        child: const Text("CONFIRM FINAL ORDER", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900)),
      ),
    );
  }

  Widget _methodCard(String label, IconData icon, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: isSelected ? AppColors.primary : Colors.black12),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.black : Colors.grey),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: isSelected ? Colors.black : Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isPhone = false}) {
    return TextField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textMain),
        filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 15),
    child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppColors.textMain)),
  );

  Widget _buildHeader(BuildContext context) => Padding(
    padding: const EdgeInsets.all(15),
    child: Row(
      children: [
        IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => Navigator.pop(context)),
        const Text("DELIVERY DETAILS", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
      ],
    ),
  );
}
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final orders = provider.myOrders;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false, // ✅ يثبت العناصر عند ظهور الكيبورد
      body: TexturedBackground(
        
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: orders.isEmpty 
                ? const Center(child: Text("NO ORDERS YET", style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: orders.length,
                    padding: const EdgeInsets.all(15),
                    itemBuilder: (context, index) {
                      return _buildOrderCard(context, orders[index], provider);
                    },
                  ),
            ),
          ],
        ),
      ),
    floatingActionButton: FloatingActionButton(
    onPressed: () {
      provider.setTabIndex(2);
      Navigator.of(context).popUntil((route) => route.isFirst);
    },
    backgroundColor: AppColors.primary,
    shape: const CircleBorder(),
    child: const Icon(Icons.storefront, color: Colors.black, size: 28),
  ),
  floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

  bottomNavigationBar: AppFooter(
    currentIndex: provider.currentTabIndex,
    onTap: (index) {
      provider.setTabIndex(index);
      Navigator.of(context).popUntil((route) => route.isFirst);
    },
  ),
      
    );
  }

Widget _buildOrderCard(BuildContext context, Map<String, dynamic> order, AppProvider provider) {
  final car = order['carInfo'];
  
  // ✅ منطق استخراج اسم البراند وتنسيقه (مثلاً "HYUNDAI TUCSON" يحول لـ "Hyundai")
  String rawName = car['name'] ?? "";
  String brandName = "";
  if (rawName.isNotEmpty) {
    String firstWord = rawName.split(' ').first.toLowerCase();
    brandName = firstWord[0].toUpperCase() + firstWord.substring(1);
  }
  String assetPath = 'assets/images/cars/$brandName.png';

  return Container(
    margin: const EdgeInsets.only(bottom: 15),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.textMain,
      borderRadius: BorderRadius.circular(25),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. هيدر الكارت (رقم الأوردر والحالة)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order['id'], style: const TextStyle(color: Colors.white54, fontSize: 10)),
                const SizedBox(height: 4),
                Text(
                  order['packageType'] ?? "MAINTENANCE ORDER",
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 14),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: Text(order['status'], style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Divider(color: Colors.white10, thickness: 1),
        ),
        Row(
          children: [
            Container(
              width: 55, 
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                // ✅ التعديل: محاولة تحميل لوجو البراند المظبوط مع Fallback مزدوج
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/car_logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.directions_car, 
                      color: Colors.grey, 
                      size: 30
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rawName.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white, 
                      fontWeight: FontWeight.w900, 
                      fontSize: 16, 
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      car['plate'],
                      style: const TextStyle(
                        color: AppColors.primary, 
                        fontSize: 10, 
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // 3. تفاصيل التوصيل والوقت
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white.withAlpha(5), borderRadius: BorderRadius.circular(15)),
          child: Column(
            children: [
              _buildOrderInfoRow(Icons.location_on_rounded, "DELIVERY", order['delivery']['address']),
              const SizedBox(height: 8),
              _buildOrderInfoRow(Icons.access_time_filled_rounded, "EXPECTED", order['estimatedDelivery']),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 4. السعر وزر الإلغاء
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("TOTAL AMOUNT", style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                Text("${order['total']} EGP", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
              ],
            ),
            
            ElevatedButton.icon(
              onPressed: () => _showCancelDialog(context, provider, order['id']),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withOpacity(0.1),
                foregroundColor: Colors.redAccent,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.redAccent, width: 0.5)),
              ),
              icon: const Icon(Icons.close_rounded, size: 16),
              label: const Text("CANCEL", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    ),
  );
}

// ويدجت مساعدة للصفوف الصغيرة
Widget _buildOrderInfoRow(IconData icon, String label, String value) {
  return Row(
    children: [
      Icon(icon, color: AppColors.primary.withOpacity(0.7), size: 14),
      const SizedBox(width: 8),
      Text("$label: ", style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
      Expanded(
        child: Text(value, style: const TextStyle(color: Colors.white70, fontSize: 10), overflow: TextOverflow.ellipsis),
      ),
    ],
  );
}
  void _showCancelDialog(BuildContext context, AppProvider provider, String orderId) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("CANCEL ORDER?"),
        content: const Text("Are you sure you want to remove this order?"),
        actions: [
          CupertinoDialogAction(child: const Text("No"), onPressed: () => Navigator.pop(context)),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text("Yes, Cancel"),
            onPressed: () {
              provider.cancelOrder(orderId);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textMain), onPressed: () => Navigator.pop(context)),
          const Text("MY ORDERS", style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w900, fontSize: 20)),
        ],
      ),
    ),
  );
}