import 'package:flutter/material.dart';
import '../../features/pages/sos_page.dart';
import '../../features/pages/maintenance_page.dart';
import '../../features/pages/tires_batteries.dart';
import '../../features/pages/services_page.dart';
import '../../features/pages/care_page.dart';
import '../../features/pages/my_garage_page.dart';
import '../constants/app_colors.dart';

class GlobalSearchDelegate extends SearchDelegate {
  // قائمة الخدمات المتاحة للبحث
  final List<Map<String, dynamic>> _searchItems = [
    {'term': 'sos', 'title': 'SOS & Rescue', 'page': const SosPage()},
    {'term': 'winch', 'title': 'Winch Service', 'page': const SosPage()},
    {'term': 'oil', 'title': 'Oil Change', 'page': const ServicesPage()},
    {'term': 'maintenance', 'title': 'Maintenance Centers', 'page': const MaintenancePage()},
    {'term': 'mechanic', 'title': 'Find Mechanic', 'page': const MaintenancePage()},
    {'term': 'tire', 'title': 'Tires & Wheels', 'page': const TiresBatteriesPage()},
    {'term': 'battery', 'title': 'Battery Service', 'page': const TiresBatteriesPage()},
    {'term': 'wash', 'title': 'Car Wash', 'page': const CarePage()},
    {'term': 'garage', 'title': 'My Garage', 'page': const MyGaragePage()},
  ];

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white54),
        border: InputBorder.none,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear, color: Color.fromARGB(255, 0, 0, 0)),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 0, 0, 0)),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final results = _searchItems.where((item) {
      return item['term'].toLowerCase().contains(query.toLowerCase()) ||
             item['title'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return ListTile(
          leading: const Icon(Icons.search, color: AppColors.primary),
          title: Text(
            item['title'],
            style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
          ),
          onTap: () {
            close(context, null);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => item['page']),
            );
          },
        );
      },
    );
  }
}