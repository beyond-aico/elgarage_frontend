import 'package:elgarage/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/ui/textured_background.dart';
import '../../widgets/car_header.dart';

class DriverScreen extends StatefulWidget {
  const DriverScreen({super.key});
  @override
  State<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  final TextEditingController _odoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    
    // للسائق نأخذ أول سيارة في القائمة (لأن الباك إند يرجع له سيارته المخصصة فقط)
    final myCar = provider.myCars.isNotEmpty ? provider.myCars.first : null;

    if (myCar == null) {
      return const Scaffold(body: Center(child: Text("NO ASSIGNED UNIT FOUND")));
    }

    bool isMaintenanceNear = (myCar.currentKm % 10000) >= 9000;

    return TexturedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppColors.secondary,
          elevation: 0,
          title: Text("TERMINAL ID: ${auth.user?.name.toUpperCase()}", 
            style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w900)),
          actions: [
            IconButton(icon: const Icon(Icons.power_settings_new, color: AppColors.error), onPressed: () => auth.logout())
          ],
        ),
        body: Column(
          children: [
            // الهيرو الخاص بالسائق
            _buildDriverHero(myCar.plateNumber ?? "UNIT_UNIDENTIFIED"),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // عرض بيانات السيارة (الـ Header الأصلي)
                    CarHeader(car: myCar),
                    
                    const SizedBox(height: 40),

                    // خانة تحديث العداد الصناعية
                    const Text("LOG CURRENT KILOMETERS", 
                      style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 12)),
                    const SizedBox(height: 15),
                    _buildMileageInput(myCar.currentKm.toString()),

                    const SizedBox(height: 30),

                    // بوابة دفع الصيانة تظهر عند اقتراب الـ 1000 كم
                    if (isMaintenanceNear) 
                      _buildPaymentPort(myCar),
                  ],
                ),
              ),
            ),
            
            // زر الحفظ النهائي في أسفل الشاشة
            _buildSubmitButton(provider, myCar.id),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverHero(String plate) {
    return ClipPath(
      clipper: HeroClipper(),
      child: Container(
        height: 140, width: double.infinity, color: AppColors.secondary,
        child: Column(
          children: [
            const SizedBox(height: 5),
            const Icon(Icons.account_box, color: Colors.white30, size: 30),
            const SizedBox(height: 5),
            Text("ACTIVE UNIT: $plate", 
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 2)),
          ],
        ),
      ),
    );
  }

  Widget _buildMileageInput(String current) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.secondary, width: 2)),
      child: TextField(
        controller: _odoController,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 45, fontWeight: FontWeight.w900, color: AppColors.secondary, letterSpacing: 5),
        decoration: InputDecoration(
          hintText: current,
          hintStyle: TextStyle(color: AppColors.secondary.withAlpha(2)),
          suffixIcon: const Padding(padding: EdgeInsets.all(15), child: Text("KM", style: TextStyle(fontWeight: FontWeight.bold))),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildPaymentPort(car) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.warning.withAlpha(15), 
        border: Border.all(color: AppColors.warning, width: 2),
      ),
      child: Column(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 50),
          const SizedBox(height: 10),
          const Text("MAINTENANCE PORT OPEN", style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.error, fontSize: 16)),
          const Text("Unit is within 1000km of service milestone.", textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // توجيه لصفحة دفع المكونات
            }, 
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 50),
              elevation: 5,
            ),
            child: const Text("INITIALIZE MAINTENANCE PAYMENT", 
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 12)),
          )
        ],
      ),
    );
  }

  Widget _buildSubmitButton(AppProvider provider, String carId) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: () async {
          int? val = int.tryParse(_odoController.text);
          if (val != null) {
            bool success = await provider.updateDriverMileage(carId, val);
            if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text("LOG SUBMITTED SUCCESSFULLY"), backgroundColor: AppColors.success)
);
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary, 
          minimumSize: const Size(double.infinity, 70),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        child: const Text("SUBMIT TERMINAL LOG", 
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 2)),
      ),
    );
  }
}