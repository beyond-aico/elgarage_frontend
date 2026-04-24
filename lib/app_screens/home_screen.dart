import 'package:easy_localization/easy_localization.dart';
import 'package:elgarage/core/constants/app_colors.dart';
import 'package:elgarage/app_screens/add_car_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../app_widgets/car_card.dart';
import '../core/app_ui/app_header.dart';
import '../core/app_ui/textured_background.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onCarSelected;
  const HomeScreen({super.key, this.onCarSelected});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // ✅ جلب البيانات بأمان بعد انتهاء رسم أول فريم
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final app = Provider.of<AppProvider>(context, listen: false);
      final auth = Provider.of<AuthProvider>(context, listen: false);
      
      // نقوم بجلب البيانات إذا كانت القائمة فارغة أو لضمان تحديث البيانات بناءً على الـ Role
      if (app.myCars.isEmpty) {
        app.fetchMyCars(
          role: auth.user?.role, 
          authProvider: auth
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppProvider>(context);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    // ❌ تم حذف سطر app.fetchMyCars من هنا لأنه المسبب للـ Exception

    bool isInitialLoading = app.isLoadingCars && app.myCars.isEmpty;

    return TexturedBackground(
      child: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'home.welcome',
              userName: auth.user?.name ?? 'User',
              statsText: '${app.myCars.length} ${'home.my_garage'.tr().toUpperCase()}',
              actionLabel: 'home.add_car_title',
              onActionPressed: () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => const AddCarScreen())
              ),
            ),
            
            Expanded(
              child: isInitialLoading 
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : RefreshIndicator(
                    onRefresh: () async {
                      final role = auth.user?.role;
                      await app.fetchMyCars(role: role, forceRefresh: true);
                    },
                    color: AppColors.primary,
                    child: app.myCars.isEmpty 
                      ? _buildEmptyState(context)
                      : ReorderableListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                          itemCount: app.myCars.length,
                          onReorder: (oldIndex, newIndex) {
                            app.reorderMyCars(oldIndex, newIndex);
                          },
                          itemBuilder: (context, index) {
                            final car = app.myCars[index];
                            return Container(
                              key: ValueKey(car.id), 
                              margin: const EdgeInsets.only(bottom: 12),
                              child: CarCard(
                                car: car,
                                isSelected: app.selectedCar?.id == car.id,
                                onTap: () {
                                  app.setSelectedCar(car);
                                  if (widget.onCarSelected != null) widget.onCarSelected!();
                                },
                              ),
                            );
                          },
                        ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_car_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 15),
            Text(
              "home.empty_garage".tr(),
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16)
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCarScreen())),
              icon: const Icon(Icons.add),
              label: Text('home.add_car_title'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textMain.withAlpha(30),
                foregroundColor: AppColors.textMain,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
              ),
            )
          ],
        ),
      ),
    );
  }
}