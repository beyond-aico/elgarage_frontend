import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/app_provider.dart';
import '../core/ui/textured_background.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();

  List<dynamic> _brands = [];
  List<dynamic> _models = [];
  String? _selectedBrandId;
  String? _selectedModelId;
  String? _selectedYear;
  String? _selectedColorName;

  // قائمة الألوان المتاحة
  final Map<String, Color> _carColors = {
    'Black': Colors.black,
    'White': Colors.white,
    'Silver': const Color(0xFFC0C0C0),
    'Grey': Colors.grey,
    'Red': Colors.red[800]!,
    'Blue': Colors.blue[900]!,
    'Navy': const Color(0xFF000080),
    'Brown': Colors.brown,
    'Gold': const Color(0xFFFFD700),
    'Beige': const Color(0xFFF5F5DC),
  };

  final List<String> _years = List.generate(50, (index) => (DateTime.now().year - index).toString());

  final _plateController = TextEditingController(); 
  final _mileageController = TextEditingController();

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
    _mileageController.dispose();
    super.dispose();
  }

  Future<void> _loadBrands() async {
    try {
      final brands = await Provider.of<AppProvider>(context, listen: false).fetchBrands();
      if (mounted) setState(() { _brands = brands; _isLoadingBrands = false; });
    } catch (e) { if (mounted) setState(() => _isLoadingBrands = false); }
  }

  Future<void> _loadModels(String brandId) async {
    setState(() { _isLoadingModels = true; _models = []; _selectedModelId = null; });
    try {
      final models = await Provider.of<AppProvider>(context, listen: false).fetchModels(brandId);
      if (mounted) setState(() { _models = models; _isLoadingModels = false; });
    } catch (e) { if (mounted) setState(() => _isLoadingModels = false); }
  }

  @override
  Widget build(BuildContext context) {
    return TexturedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text("home.add_car_title".tr(), 
            style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 16)),
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
                _sectionHeader("home.car_identity".tr()),
                const SizedBox(height: 20),

                _buildDropdown(
                  label: "home.select_brand".tr(),
                  icon: CupertinoIcons.tag_fill,
                  isLoading: _isLoadingBrands,
                  value: _selectedBrandId,
                  items: _brands.map((b) => DropdownMenuItem(value: b['id'].toString(), child: Text(b['name'] ?? ''))).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedBrandId = val);
                      _loadModels(val);
                    }
                  },
                ),
                const SizedBox(height: 15),

                _buildDropdown(
                  label: "home.select_model".tr(),
                  icon: CupertinoIcons.car_detailed,
                  isLoading: _isLoadingModels,
                  value: _selectedModelId,
                  items: _models.map((m) => DropdownMenuItem(value: m['id'].toString(), child: Text(m['name'] ?? ''))).toList(),
                  onChanged: _models.isEmpty ? null : (val) => setState(() => _selectedModelId = val),
                ),
                const SizedBox(height: 15),

                // دروب ليست السنة
                _buildDropdown(
                  label: "home.year_label".tr(),
                  icon: CupertinoIcons.calendar,
                  isLoading: false,
                  value: _selectedYear,
                  items: _years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                  onChanged: (val) => setState(() => _selectedYear = val),
                ),
                const SizedBox(height: 15),

                // دروب ليست اللون مع دائرة لونية بجانب الاسم
                _buildDropdown(
                  label: "home.color_label".tr(),
                  icon: Icons.palette_outlined,
                  isLoading: false,
                  value: _selectedColorName,
                  items: _carColors.keys.map((colorName) => DropdownMenuItem(
                    value: colorName,
                    child: Row(
                      children: [
                        Container(width: 12, height: 12, decoration: BoxDecoration(color: _carColors[colorName], shape: BoxShape.circle, border: Border.all(color: Colors.black12))),
                        const SizedBox(width: 10),
                        Text("colors.${colorName.toLowerCase()}".tr()),
                      ],
                    ),
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedColorName = val),
                ),

                const SizedBox(height: 30),
                _sectionHeader("home.usage_data".tr()),
                const SizedBox(height: 20),

                _buildTextField(_mileageController, "home.mileage_label".tr(), CupertinoIcons.speedometer, isNumber: true, isRequired: true),
                const SizedBox(height: 15),
                
                // اللوحة اختيارية
                _buildTextField(_plateController, "${"home.plate_label".tr()} (${"common.optional_skip".tr()})", CupertinoIcons.number),

                const SizedBox(height: 40),

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
                      : Text("home.save_btn".tr(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
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

  Widget _sectionHeader(String title) {
    return Text(title, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2));
  }

  Widget _buildDropdown({required String label, required IconData icon, required bool isLoading, String? value, required List<DropdownMenuItem<String>> items, required Function(String?)? onChanged}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withAlpha(05), blurRadius: 10)]),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items,
        onChanged: onChanged,
        isExpanded: true,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.textMain, size: 20),
          hintText: isLoading ? "common.loading".tr() : label,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        ),
        validator: (v) => v == null ? "common.required".tr() : null,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false, bool isRequired = false}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withAlpha(05), blurRadius: 10)]),
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
        validator: isRequired ? (v) => (v == null || v.isEmpty) ? "common.required".tr() : null : null,
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedModelId == null || _selectedYear == null || _selectedColorName == null) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("common.fill_all".tr())));
       return;
    }

    setState(() => _isSubmitting = true);
    
    final carData = {
      'modelId': _selectedModelId, 
      'year': int.parse(_selectedYear!),
      'color': _selectedColorName, // نرسل الاسم (مثل Black) ليتم التعرف عليه في الـ Card
      'plateNumber': _plateController.text.isEmpty ? null : _plateController.text,
      'mileageKm': int.parse(_mileageController.text.replaceAll(',', '').trim()),
      'monthlyAvgKm': 0.0,
    };

    final success = await Provider.of<AppProvider>(context, listen: false).addNewCarv2(carData);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('home.car_added_success'.tr()), backgroundColor: Colors.green));
    }
  }
}