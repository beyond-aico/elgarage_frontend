import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/car_card.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppProvider>(context, listen: false).fetchMyCars();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<AppProvider>(context, listen: false).fetchMyCars();
        },
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Welcome back,", style: TextStyle(color: Colors.white70, fontSize: 16)),
                            Text(
                              authProvider.currentUser?.name ?? "User",
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white24,
                          child: Text(
                            (authProvider.currentUser?.name ?? "U")[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Stats
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem("My Cars", "${Provider.of<AppProvider>(context).myCars.length}"),
                          _buildStatItem("Due Services", "${Provider.of<AppProvider>(context).dueMaintenance.length}"), 
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: Text("Your Garage", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),

            // Cars List
            Consumer<AppProvider>(
              builder: (context, provider, child) {
                if (provider.isLoadingCars) {
                  return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
                }

                if (provider.myCars.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.car_detailed, size: 60, color: Colors.grey),
                          SizedBox(height: 10),
                          Text("No cars added yet", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final car = provider.myCars[index];
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        child: CarCard(
                          car: car,
                          onTap: () async {
                            // ✅ التصحيح هنا: شيلنا .name لأن car.model هو سترينج بالفعل
                            debugPrint("Car tapped: ${car.model} (ID: ${car.id})");
                            
                            // 1. تحديد العربية
                            provider.setSelectedCar(car);

                            // 2. جلب الصيانة
                            await provider.fetchDueMaintenance(carId: car.id);

                            // 3. التحويل للتاب
                            if (widget.onCarSelected != null) {
                              widget.onCarSelected!();
                            }
                          },
                        ),
                      );
                    },
                    childCount: provider.myCars.length,
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddCarScreen()));
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}