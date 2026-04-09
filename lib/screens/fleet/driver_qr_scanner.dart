/*import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../providers/fleet_provider.dart';
import '../../providers/auth_provider.dart'; 
import '../../core/constants/app_colors.dart';

class DriverQRScanner extends StatefulWidget {
  const DriverQRScanner({super.key});

  @override
  State<DriverQRScanner> createState() => _DriverQRScannerState();
}

class _DriverQRScannerState extends State<DriverQRScanner> {
  // ✅ إضافة كنترولر للتحكم في الكاميرا
  final MobileScannerController controller = MobileScannerController();
  bool isScanning = true;
  String? identifiedCode;

  @override
  void dispose() {
    controller.dispose(); // ✅ ضروري لقفل الكاميرا نهائياً عند الخروج
    super.dispose();
  }


// ✅ تعديل دالة معالجة الكود لتكون أكثر مرونة
  void _onCodeFound(String rawCode) async {
    if (!isScanning) return;
    
    String processedCode = rawCode.trim();

    // 🎯 لو الممسوح رابط (أي رابط)، هناخد آخر جزء فيه
    if (processedCode.startsWith("http")) {
      processedCode = processedCode.split("/").last;
    }

    // وقف الكاميرا بأمان
    if (controller.value.isInitialized) {
      setState(() => isScanning = false);
      try {
        await controller.stop();
      } catch (e) {
        debugPrint("Scanner stop error: $e");
      }
    }

    if (mounted) {
      _showPasswordDialog(processedCode);
    }
  }
  
  void _showPasswordDialog(String barcode) {
    final TextEditingController passController = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.textMain,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Vehicle identified: $barcode", 
          style: const TextStyle(color: AppColors.primary, fontSize: 15, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: passController,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter vehicle password",
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              setState(() {
                isScanning = true;
                identifiedCode = null;
              });
              // ✅ إعادة تشغيل الكاميرا لو السائق كنسل
              await controller.start();
            }, 
            child: const Text("Cancel", style: TextStyle(color: Colors.white38))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              final fleet = Provider.of<FleetProvider>(context, listen: false);
              final auth = Provider.of<AuthProvider>(context, listen: false);

              bool success = await fleet.linkDriverToVehicle(barcode, passController.text);
              
              if (!mounted) return;

              if (success) {
                await auth.tryAutoLogin(); 
                if (mounted) {
                  Navigator.pop(dialogContext); 
                  Navigator.pop(context); 
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(backgroundColor: Colors.redAccent, content: Text(fleet.error ?? "Wrong Password")),
                );
                Navigator.pop(dialogContext);
                setState(() => isScanning = true);
                await controller.start(); // إعادة التشغيل عند الخطأ
              }
            },
            child: const Text("Connect", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Vehicle Login", style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // ✅ لو مش بنعمل سكان، بنخفي الكاميرا تماماً عشان اللوجات تقف
      body: !isScanning 
        ? _buildProcessingView() 
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
    );
  }

  // ✅ واجهة تظهر مكان الكاميرا لما بنلقط الكود (بتنضف الشاشة وتوقف اللوج)
  Widget _buildProcessingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, color: AppColors.primary, size: 80),
          const SizedBox(height: 20),
          Text("Identified: $identifiedCode", 
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text("Please complete the password verification", 
            style: TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return Center(
      child: Container(
        width: 260,
        height: 260,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 2),
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}*/