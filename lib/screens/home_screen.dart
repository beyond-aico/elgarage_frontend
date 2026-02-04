import 'package:elgarage/core/ui/home_header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/textured_background.dart';
import 'add_car_screen.dart';

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
    // جلب البيانات عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppProvider>(context, listen: false).fetchMyCars();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final app = Provider.of<AppProvider>(context);

    return TexturedBackground(
      child: SafeArea(
        child: Column(
          children: [
            // استدعاء الهيدر الموحد
            HomeHeader(
              title: 'Welcome back,',
              userName: auth.user?.name ?? 'Operator',
              statsText: '${app.myCars.length} Cars in Garage',
              actionLabel: 'ADD NEW CAR',
              onActionPressed: () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => const AddCarScreen())
              ),
            ),

            Expanded(
              child: Consumer<AppProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoadingCars) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  // ✅ حل مشكلة الـ EmptyState: استدعاء الدالة هنا لو القائمة فارغة
                  if (provider.myCars.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: provider.myCars.length,
                    itemBuilder: (context, index) => _buildIndustrialCarCard(
                      context, 
                      provider.myCars[index], 
                      provider
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

  // ✅ نقل هذه الدوال داخل الكلاس لحل مشكلة 'widget' undefined
  Widget _buildIndustrialCarCard(BuildContext context, dynamic car, AppProvider provider) {
    return GestureDetector(
      onTap: () async {
        provider.setSelectedCar(car);
        await provider.fetchDueMaintenance(carId: car.id);
        // الآن 'widget' معروفة لأننا داخل الكلاس
        if (widget.onCarSelected != null) widget.onCarSelected!();
      },
      child: Container(
        height: 170,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), 
              blurRadius: 15, 
              offset: const Offset(0, 8)
            )
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: 15, 
              bottom: -5, 
              child: Text(
                car.make.toString().toUpperCase(), 
                style: TextStyle(
                  fontSize: 55, 
                  fontWeight: FontWeight.w900, 
                  color: Colors.black.withOpacity(0.04)
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${car.make} ${car.model}', 
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(car.plateNumber ?? 'No Plate', 
                    style: const TextStyle(color: AppColors.textSub, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'System Ready • ${car.year}', 
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Positioned(
              right: -15, 
              bottom: 10, 
              child: car.imageUrl != null && car.imageUrl!.isNotEmpty
                  ? Image.network(
                      car.imageUrl!, 
                      height: 110, 
                      errorBuilder: (c, e, s) => _buildDefaultCarIcon()
                    )
                  : _buildDefaultCarIcon(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultCarIcon() {
    return const Padding(
      padding: EdgeInsets.only(right: 30, bottom: 20),
      child: Icon(Icons.directions_car_filled, size: 90, color: Colors.black12),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.car_detailed, size: 70, color: Colors.black12),
          SizedBox(height: 15),
          Text("Garage is empty", 
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
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