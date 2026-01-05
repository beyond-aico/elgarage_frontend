import 'package:elgarage/screens/add_car_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/app_provider.dart';
import '../widgets/car_card.dart';
// Don't forget to import your AddCarScreen here
// import '../screens/add_car_screen.dart'; 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      
      // 1. THE BODY (The Scrollable List)
      body: CustomScrollView(
        slivers: [
          // A. Hero Section / Header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              decoration: const BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Row(
                children: [
                  // Profile Image
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                      image: const DecorationImage(
                        image: NetworkImage('https://i.pravatar.cc/300'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),

                  // Welcome Text & Phone
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                        const Text(
                          'Hesham Fathy',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(CupertinoIcons.phone, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              '+20 100 000 0000',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Notification Button
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(CupertinoIcons.bell, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
          ),

          // B. Section Title
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 25, 20, 10),
              child: Text(
                'My Garage',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),

          // C. Car List (Consumer)
          Consumer<AppProvider>(
            builder: (context, provider, child) {
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final car = provider.myCars[index];
                    final isSelected = provider.selectedCar.id == car.id;

                    return CarCard(
                      car: car,
                      isSelected: isSelected,
                      onTap: () {
                        provider.selectCar(car);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${car.make} ${car.model} Selected'),
                            backgroundColor: AppColors.secondary,
                            duration: const Duration(milliseconds: 500),
                          ),
                        );
                      },
                    );
                  },
                  childCount: provider.myCars.length,
                ),
              );
            },
          ),

          // Bottom Padding
          const SliverToBoxAdapter(child: SizedBox(height: 80)), // Increased height to avoid FAB overlap
        ],
      ),

      // 2. THE FLOATING ACTION BUTTON
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // Make sure AddCarScreen is imported or defined
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCarScreen()),
          );
        },
      ),
    );
  }
}