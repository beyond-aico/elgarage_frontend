// --- FILE: lib/screens/fleet/driver_qr_scanner.dart ---
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../providers/fleet_provider.dart';
import '../../providers/auth_provider.dart'; 
import '../../providers/app_provider.dart'; 
import '../../providers/maintenance_provider.dart';
import '../../core/constants/app_colors.dart';
import 'driver_screen.dart';

class DriverQRScanner extends StatefulWidget {
  const DriverQRScanner({super.key});
  @override
  State<DriverQRScanner> createState() => _DriverQRScannerState();
}

class _DriverQRScannerState extends State<DriverQRScanner> {
  final MobileScannerController controller = MobileScannerController();
  bool isScanning = true;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _forceLogoutAndExit() async {
    try { await controller.stop().catchError((e) => debugPrint("Camera already stopped")); } catch (_) {}
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final app = Provider.of<AppProvider>(context, listen: false);
    final fleet = Provider.of<FleetProvider>(context, listen: false);
    app.resetOnLogout();
    fleet.resetOnLogout();
    await auth.logout();
    if (mounted) { Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false); }
  }

  void _onCodeFound(String rawCode) async {
    if (!isScanning) return;
    String processedCode = rawCode.trim();
    if (processedCode.contains("/")) { processedCode = processedCode.split("/").last; }
    setState(() => isScanning = false);
    try { await controller.stop(); } catch (_) {}
    if (mounted) { _handleVehicleLinking(processedCode); }
  }
  
  void _handleVehicleLinking(String barcode) async {
    final fleet = Provider.of<FleetProvider>(context, listen: false);
    final maintenance = Provider.of<MaintenanceProvider>(context, listen: false);
    final app = Provider.of<AppProvider>(context, listen: false);

    // ✅ نمرر الـ appProvider عشان نجيب منه البيانات الكاملة للعربية
    bool success = await fleet.linkDriverToVehicle(barcode, app); 
    
    if (success && mounted) {
      final car = fleet.authenticatedCar!;
      
      // 🎯 مزامنة البيانات فوراً لضمان فتح صفحة الدرايفر بكل معلوماتها (اسم، عداد، صيانة)
      app.setSelectedCar(car); 
      await maintenance.fetchDueMaintenance(car.id, car.mileageKm);

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context, 
          MaterialPageRoute(builder: (_) => const DriverScreen()),
          (route) => false
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(fleet.error ?? "فشل الربط")));
      Future.delayed(const Duration(milliseconds: 500), () async {
        if (mounted) { 
          try { await controller.start(); setState(() => isScanning = true); } catch (_) {} 
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async { if (!didPop) await _forceLogoutAndExit(); },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text("Scan Vehicle Barcode", style: TextStyle(color: Colors.white, fontSize: 16)),
          backgroundColor: Colors.transparent,
          leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: _forceLogoutAndExit),
        ),
        body: !isScanning 
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary)) 
          : Stack(
              children: [
                MobileScanner(
                  controller: controller,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                      _onCodeFound(barcodes.first.rawValue!);
                    }
                  },
                ),
                _buildScannerOverlay(),
              ],
            ),
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return Center(
      child: Container(
        width: 260, height: 260,
        decoration: BoxDecoration(border: Border.all(color: AppColors.primary, width: 3), borderRadius: BorderRadius.circular(30)),
        child: const Align(alignment: Alignment.topCenter, child: Padding(padding: EdgeInsets.only(top: 20), child: Text("Place barcode inside box", style: TextStyle(color: Colors.white)))),
      ),
    );
  }
}