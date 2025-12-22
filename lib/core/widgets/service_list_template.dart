import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/place_card.dart';

class ServiceListTemplate extends StatefulWidget {
  final String title;
  final Color primaryColor;
  final List<dynamic> initialData; // الداتا المبدئية

  const ServiceListTemplate({
    super.key,
    required this.title,
    required this.primaryColor,
    required this.initialData,
  });

  @override
  State<ServiceListTemplate> createState() => _ServiceListTemplateState();
}

class _ServiceListTemplateState extends State<ServiceListTemplate> {
  late List<dynamic> filteredList;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredList = widget.initialData;
  }

  void _filterData(String query) {
    setState(() {
      filteredList = widget.initialData.where((place) {
        return place.name.contains(query) || place.address.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          // منطقة البحث
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
              boxShadow: [
                BoxShadow(color: Colors.grey.withAlpha(05), blurRadius: 10, offset: const Offset(0, 5)),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _filterData,
              decoration: InputDecoration(
                hintText: "ابحث في ${widget.title}...",
                prefixIcon: Icon(Icons.search, color: widget.primaryColor),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: widget.primaryColor, width: 1.5),
                ),
              ),
            ),
          ),
          
          // القائمة
          Expanded(
            child: filteredList.isEmpty
                ? Center(child: Text("لا توجد نتائج", style: TextStyle(color: Colors.grey.shade600)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      return PlaceCard(place: filteredList[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}