// --- FILE: lib/screens/car_details_screen.dart ---

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/app_provider.dart';
import '../providers/maintenance_provider.dart';
import '../core/ui/textured_background.dart';
import 'tabs/history_tab.dart';
import 'tabs/maintenance_tab.dart';
import 'cart_screen.dart';

class CarDetailsScreen extends StatefulWidget {
  const CarDetailsScreen({super.key});

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final mainProvider = Provider.of<MaintenanceProvider>(
        context,
        listen: false,
      );

      if (appProvider.selectedCar != null) {
        // ✅ تمرير العداد الحالي لتفعيل منطق تصحيح الأرقام السالبة برمجياً
        mainProvider.fetchDueMaintenance(
          appProvider.selectedCar!.id,
          appProvider.selectedCar!.mileageKm,
        );
        mainProvider.fetchServiceHistory(appProvider.selectedCar!.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final mainProvider = Provider.of<MaintenanceProvider>(context);

    final selectedCar = appProvider.selectedCar;

    if (selectedCar == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final String healthStatus = mainProvider.realHealthStatus;
    final int remaining = mainProvider.nextServiceRemainingKm;

    Color healthColor = Colors.greenAccent;
    if (healthStatus == 'OVERDUE') healthColor = Colors.redAccent;
    if (healthStatus == 'SOON') healthColor = AppColors.primary;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.textMain),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  CupertinoIcons.cart_fill,
                  color: AppColors.textMain,
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                ),
              ),
              if (appProvider.cartItems.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: CircleAvatar(
                    radius: 7,
                    backgroundColor: Colors.red,
                    child: Text(
                      '${appProvider.cartItems.length}',
                      style: const TextStyle(
                        fontSize: 8,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.textMain,
            ),
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteConfirmation(context, appProvider, selectedCar.id);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Delete Car',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: TexturedBackground(
        child: Column(
          children: [
            const SizedBox(height: 70),
            Image.asset(
              'assets/images/car_logo.png',
              height: 80,
              fit: BoxFit.contain,
              errorBuilder: (c, e, s) =>
                  const Icon(Icons.directions_car, size: 60),
            ),
            const SizedBox(height: 10),
            Text(
              '${selectedCar.make} ${selectedCar.model}'.toUpperCase(),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            Text(
              selectedCar.licensePlate ?? 'No Plate',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSub,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.textMain,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    'Current KM',
                    '${selectedCar.mileageKm} K',
                    CupertinoIcons.speedometer,
                    AppColors.primary,
                    onTap: () =>
                        _showUpdateKmDialog(context, appProvider, mainProvider),
                  ),
                  _divider(),
                  _buildStatItem(
                    'Status',
                    healthStatus,
                    CupertinoIcons.checkmark_shield_fill,
                    healthColor,
                  ),
                  _divider(),
                  _buildStatItem(
                    'Remaining',
                    '$remaining KM',
                    CupertinoIcons.hourglass,
                    AppColors.primary,
                    onTap: () =>
                        _showNotificationThresholdSheet(context, mainProvider),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),
            TabBar(
              controller: _tabController,
              labelColor: AppColors.textMain,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: 'HISTORY'),
                Tab(text: 'MAINTENANCE'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [HistoryTab(), MaintenanceTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 25, color: Colors.white10);

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color valColor, {
    VoidCallback? onTap,
  }) {
    return Flexible(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: valColor, size: 16),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: valColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 8),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUpdateKmDialog(
    BuildContext context,
    AppProvider appProvider,
    MaintenanceProvider mainProvider,
  ) {
    final TextEditingController kmController = TextEditingController(
      text: appProvider.selectedCar?.mileageKm.toString(),
    );
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Update Current Mileage"),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: CupertinoTextField(
            controller: kmController,
            keyboardType: TextInputType.number,
            placeholder: "Enter current KM",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary),
            ),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: const Text("Update"),
            onPressed: () async {
              int? newKm = int.tryParse(kmController.text);
              if (newKm != null) {
                Navigator.pop(context);
                FocusScope.of(context).unfocus();

                bool success = await appProvider.updateCarCurrentKm(newKm);

                if (success && appProvider.selectedCar != null) {
                  // ✅ تحديث بيانات الصيانة مع العداد الجديد فوراً
                  await mainProvider.fetchDueMaintenance(
                    appProvider.selectedCar!.id,
                    newKm,
                  );
                }

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? "Odometer synced with server"
                            : "Sync failed, try again",
                      ),
                      backgroundColor: success
                          ? Colors.green
                          : Colors.redAccent,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showNotificationThresholdSheet(
    BuildContext context,
    MaintenanceProvider mainProvider,
  ) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text("Remind me before maintenance by:"),
        actions: [500, 1000, 2000]
            .map(
              (km) => CupertinoActionSheetAction(
                child: Text("$km KM"),
                onPressed: () {
                  mainProvider.setNotificationThreshold(km);
                  Navigator.pop(context);
                },
              ),
            )
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          child: const Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    AppProvider provider,
    String carId,
  ) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Delete Vehicle?"),
        content: const Text("This action cannot be undone."),
        actions: [
          CupertinoDialogAction(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text("Delete"),
            onPressed: () async {
              final success = await provider.removeCar(carId);
              if (context.mounted) {
                Navigator.pop(context);
                if (success) provider.setTabIndex(0);
              }
            },
          ),
        ],
      ),
    );
  }
}
