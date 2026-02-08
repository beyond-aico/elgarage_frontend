// --- FILE: lib/screens/add_car_screen.dart ---

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/app_provider.dart';
import '../core/ui/textured_background.dart'; // ✅ استيراد الخلفية

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();

  // القوائم والبيانات
  List<dynamic> _brands = [];
  List<dynamic> _models = [];
  String? _selectedBrandId;
  String? _selectedModelId;

  // Controllers - الحفاظ على مسميات الباك إند الحالية
  final _plateController = TextEditingController(); // ✅ رقم العربية
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _mileageController = TextEditingController(); // currentKm
  final _avgConsController = TextEditingController();

  bool _isLoadingBrands = true;
  bool _isLoadingModels = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadBrands();
  }

  @override
  void dispose() {
    _plateController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _mileageController.dispose();
    _avgConsController.dispose();
    super.dispose();
  }

  Future<void> _loadBrands() async {
    try {
      final brands = await Provider.of<AppProvider>(context, listen: false).fetchBrands();
      if (mounted) {
        setState(() {
          _brands = brands;
          _isLoadingBrands = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingBrands = false);
    }
  }

  Future<void> _loadModels(String brandId) async {
    setState(() {
      _isLoadingModels = true;
      _models = [];
      _selectedModelId = null; 
    });
    try {
      final models = await Provider.of<AppProvider>(context, listen: false).fetchModels(brandId);
      if (mounted) {
        setState(() {
          _models = models;
          _isLoadingModels = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingModels = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TexturedBackground( // ✅ إضافة الباكجراوند المطلوبة
      child: Scaffold(
        backgroundColor: Colors.transparent, // شفافة لتظهر الخلفية المحببة
        appBar: AppBar(
          title: const Text("REGISTER NEW VEHICLE", 
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 16)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.textMain,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader("CAR IDENTITY"),
                const SizedBox(height: 20),

                // 1. الماركة
                _buildDropdown(
                  label: "Select Brand",
                  icon: CupertinoIcons.tag_fill,
                  isLoading: _isLoadingBrands,
                  value: _selectedBrandId,
                  items: _brands.map((b) => DropdownMenuItem(
                    value: b['id'].toString(), 
                    child: Text(b['name'] ?? 'Unknown')
                  )).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedBrandId = val);
                      _loadModels(val);
                    }
                  },
                ),
                
                const SizedBox(height: 15),

                // 2. الموديل
                _buildDropdown(
                  label: "Select Model",
                  icon: CupertinoIcons.car_detailed,
                  isLoading: _isLoadingModels,
                  value: _selectedModelId,
                  items: _models.map((m) => DropdownMenuItem(
                    value: m['id'].toString(), 
                    child: Text(m['name'] ?? 'Unknown')
                  )).toList(),
                  onChanged: _models.isEmpty ? null : (val) => setState(() => _selectedModelId = val),
                ),

                const SizedBox(height: 15),

                // 3. رقم اللوحة (Plate Number)
                _buildTextField(_plateController, "PLATE NUMBER (E.G. 123 ABC)", CupertinoIcons.number),

                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(child: _buildTextField(_yearController, "YEAR", CupertinoIcons.calendar, isNumber: true)),
                    const SizedBox(width: 15),
                    Expanded(child: _buildTextField(_colorController, "COLOR", Icons.palette_outlined)),
                  ],
                ),

                const SizedBox(height: 30),
                _sectionHeader("USAGE DATA"),
                const SizedBox(height: 20),

                _buildTextField(_mileageController, "CURRENT MILEAGE (KM)", CupertinoIcons.speedometer, isNumber: true),
                _buildTextField(_avgConsController, "ESTIMATED MONTHLY KM", CupertinoIcons.chart_bar_square, isNumber: true),

                const SizedBox(height: 40),

                // زر الإرسال بتصميم Stadium
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textMain,
                      foregroundColor: AppColors.primary,
                      shape: const StadiumBorder(),
                      elevation: 5,
                    ),
                    onPressed: _isSubmitting ? null : () => _submitForm(),
                    child: _isSubmitting 
                      ? const CupertinoActivityIndicator(color: AppColors.primary)
                      : const Text("ADD CAR TO MY GARAGE", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- UI Helpers ---

  Widget _sectionHeader(String title) {
    return Text(title, style: const TextStyle(
      color: AppColors.primary, 
      fontWeight: FontWeight.w900, 
      fontSize: 12, 
      letterSpacing: 2
    ));
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required bool isLoading,
    String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(05), blurRadius: 10)]
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.textMain, size: 20),
          hintText: isLoading ? "Loading..." : label,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
        validator: (v) => v == null ? "Required" : null,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(05), blurRadius: 10)]
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
          prefixIcon: Icon(icon, color: AppColors.textMain, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        ),
        validator: (v) => v!.isEmpty ? "Required" : null,
      ),
    );
  }

  // --- Logic ---

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedModelId == null) return;

    setState(() => _isSubmitting = true);
final String mileageText = _mileageController.text.replaceAll(',', '').trim(); // ✅ إزالة الفواصل
    final carData = {
      'modelId': _selectedModelId, 
      'year': int.parse(_yearController.text),
      'color': _colorController.text,
      'plateNumber': _plateController.text, // ✅ مطابقة للسرفيس
      'mileageKm': int.parse(_mileageController.text), // ✅ مطابقة للسرفيس
      'monthlyAvgKm': double.tryParse(_avgConsController.text) ?? 0.0,
    };

    final success = await Provider.of<AppProvider>(context, listen: false).addNewCarv2(carData);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle Registered Successfully!'), backgroundColor: Colors.green),
      );
    }
  }
}