// --- FILE: lib/screens/home_screen.dart ---

import 'package:elgarage/screens/add_car_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/car_card.dart';
import '../../core/ui/app_header.dart';
import '../../core/ui/textured_background.dart';

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
    // ✅ جلب السيارات فور فتح التطبيق
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final role = Provider.of<AuthProvider>(context, listen: false).user?.role;
      Provider.of<AppProvider>(context, listen: false).fetchMyCars(role: role);
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

bool isStillDetermining = auth.isLoading || app.isLoadingCars;

    return TexturedBackground(
      child: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Welcome back,',
userName: auth.user?.name ?? 'User', // سيظهر "Nour" الآن
              statsText: '${app.myCars.length} CARS IN GARAGE',
              actionLabel: 'ADD NEW CAR',
              onActionPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCarScreen())),
            ),
            
       Expanded(
              child: isStillDetermining 
                ? const Center(child: CircularProgressIndicator(color: Colors.amber))
                : app.myCars.isEmpty 
                  ? _buildEmptyState()
                  : ReorderableListView.builder( // ✅ التعديل هنا لتمكين الترتيب
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                      itemCount: app.myCars.length,
                      // ✅ دالة معالجة إعادة الترتيب
                      onReorder: (oldIndex, newIndex) {
                        app.reorderMyCars(oldIndex, newIndex);
                      },
                      itemBuilder: (context, index) {
                        final car = app.myCars[index];
                        return Container(
                          // ✅ ضروري جداً استخدام Key فريد لكل كارت
                          key: ValueKey(car.id), 
                          margin: const EdgeInsets.only(bottom: 5), // مسافة بسيطة لمنع تداخل الظلال أثناء السحب
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
          ],
        ),
      ),
    );
  }
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car_outlined, size: 80, color: Colors.grey.withAlpha(3)),
          const SizedBox(height: 10),
          const Text("Your garage is empty", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// الكليبر يظل بالخارج لأنه كلاس مستقل
class HeroClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 60);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}