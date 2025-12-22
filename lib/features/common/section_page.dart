import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/data/dummy_data.dart';
import '../../core/widgets/place_card.dart';

class SectionPage extends StatefulWidget {
  final String title;
  final List<Place> dataList;
  final Color primaryColor; // لون القسم

  const SectionPage({
    super.key,
    required this.title,
    required this.dataList,
    required this.primaryColor,
  });

  @override
  State<SectionPage> createState() => _SectionPageState();
}

class _SectionPageState extends State<SectionPage> {
  late List<Place> filteredList;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredList = widget.dataList;
  }

  void _filterData(String query) {
    setState(() {
      filteredList = widget.dataList
          .where((place) =>
              place.name.contains(query) || place.address.contains(query))
          .toList();
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
          // رأس الصفحة مع البحث
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
              boxShadow: [
                BoxShadow(color: Colors.grey.withAlpha(05), blurRadius: 10, offset: const Offset(0, 5)),
              ],
            ),
            child: Column(
              children: [
                // Hero Icon Small
                Hero(
                  tag: widget.title,
                  child: Icon(Icons.circle, size: 10, color: widget.primaryColor), // Placeholder for animation continuity
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _searchController,
                  onChanged: _filterData,
                  decoration: InputDecoration(
                    hintText: "ابحث عن ${widget.title}...",
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
              ],
            ),
          ),
          
          // القائمة
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 60, color: Colors.grey.shade300),
                        const SizedBox(height: 10),
                        const Text("لا توجد نتائج مطابقة", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      // PlaceCard يحتاج تعديل بسيط ليستقبل اللون (اختياري)
                      return PlaceCard(place: filteredList[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}