// lib/web_screens/add_car_web_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart';
import '../core/app_ui/textured_background.dart';

class AddCarWebScreen extends StatefulWidget {
  const AddCarWebScreen({super.key});

  @override
  State<AddCarWebScreen> createState() => _AddCarWebScreenState();
}

class _AddCarWebScreenState extends State<AddCarWebScreen> {
  final _formKey = GlobalKey<FormState>();
  final int _currentIndex = -1; // علامة لتمييز أننا في شاشة فرعية

  List<dynamic> _brands = [];
  List<dynamic> _models = [];
  String? _selectedBrandId;
  String? _selectedModelId;

  final _plateController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _mileageController = TextEditingController();
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
      if (mounted) setState(() { _brands = brands; _isLoadingBrands = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoadingBrands = false);
    }
  }

  Future<void> _loadModels(String brandId) async {
    setState(() { _isLoadingModels = true; _models = []; _selectedModelId = null; });
    try {
      final models = await Provider.of<AppProvider>(context, listen: false).fetchModels(brandId);
      if (mounted) setState(() { _models = models; _isLoadingModels = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoadingModels = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    // ✅ الحل الجذري: استخدام Scaffold لتوفير Material context للـ Dropdowns
    return TexturedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Row(
          children: [
            // 1. السايد بار الموحد (للحفاظ على تناسق التنقل)
            _buildSidebar(auth),

            // 2. منطقة الفورم (Workspace)
            Expanded(
              child: Material( // ✅ إضافة Material إضافي لضمان عمل الـ Dropdowns
                color: Colors.transparent,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(50),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWebHeader(),
                        const SizedBox(height: 50),

                        // تقسيم الفورم لعمودين (نفس ستايل الويب الاحترافي)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // عمود الهوية
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _sectionTitle("CAR IDENTITY"),
                                  const SizedBox(height: 25),
                                  _buildDropdownWeb(
                                    label: "SELECT BRAND",
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
                                  const SizedBox(height: 20),
                                  _buildDropdownWeb(
                                    label: "SELECT MODEL",
                                    icon: CupertinoIcons.car_detailed,
                                    isLoading: _isLoadingModels,
                                    value: _selectedModelId,
                                    items: _models.map((m) => DropdownMenuItem(
                                      value: m['id'].toString(), 
                                      child: Text(m['name'] ?? 'Unknown')
                                    )).toList(),
                                    onChanged: _models.isEmpty ? null : (val) => setState(() => _selectedModelId = val),
                                  ),
                                  const SizedBox(height: 20),
                                  _buildTextFieldWeb(_plateController, "PLATE NUMBER", CupertinoIcons.number),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(child: _buildTextFieldWeb(_yearController, "YEAR", CupertinoIcons.calendar, isNumber: true)),
                                      const SizedBox(width: 15),
                                      Expanded(child: _buildTextFieldWeb(_colorController, "COLOR", Icons.palette_outlined)),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 60),

                            // عمود الاستخدام
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _sectionTitle("USAGE & ANALYTICS"),
                                  const SizedBox(height: 25),
                                  _buildTextFieldWeb(_mileageController, "CURRENT ODOMETER (KM)", CupertinoIcons.speedometer, isNumber: true),
                                  const SizedBox(height: 20),
                                  _buildTextFieldWeb(_avgConsController, "ESTIMATED MONTHLY KM", CupertinoIcons.chart_bar_square, isNumber: true),
                                  
                                  const SizedBox(height: 60),
                                  
                                  _buildSubmitButton(),
                                  const SizedBox(height: 20),
                                  Center(
                                    child: TextButton.icon(
                                      onPressed: () => Navigator.pop(context),
                                      icon: const Icon(Icons.close, size: 16, color: Colors.white24),
                                      label: const Text("CANCEL AND DISCARD", style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- عناصر واجهة المستخدم الموحدة ---

  Widget _buildWebHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("FLEET EXPANSION PROTOCOL", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        const Text("Register New Vehicle", style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white)),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Text(text, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2));
  }

  Widget _buildSidebar(AuthProvider auth) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppColors.textMain.withOpacity(0.95),
        border: const Border(right: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        children: [
          _buildSidebarHeader(),
          const SizedBox(height: 20),
          _buildSidebarItem(0, Icons.dashboard_rounded, "DASHBOARD"),
          _buildSidebarItem(1, Icons.directions_car_filled_rounded, "CAR DETAILS"),
          _buildSidebarItem(2, Icons.local_shipping, "MARKETPLACE"),
          _buildSidebarItem(3, Icons.emergency_share_rounded, "EMERGENCY"),
          _buildSidebarItem(4, Icons.more_horiz_rounded, "MORE"),
          const Spacer(),
          _buildSidebarItem(-1, Icons.logout_rounded, "LOGOUT", onTap: () => auth.logout()),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Image.asset('assets/images/logo.png', height: 70),
          const SizedBox(height: 15),
          const Text("EL GARAGE", style: TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const Text("WEB TERMINAL", style: TextStyle(color: Colors.white24, fontSize: 9, letterSpacing: 1.5)),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String title, {VoidCallback? onTap}) {
    bool isSelected = _currentIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      child: ListTile(
        onTap: onTap ?? () => Navigator.pop(context), // الرجوع لو أي زرار اتداس
        selected: isSelected,
        leading: Icon(icon, color: isSelected ? AppColors.primary : Colors.white30),
        title: Text(title, style: TextStyle(color: isSelected ? AppColors.primary : Colors.white30, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
      ),
    );
  }

  Widget _buildDropdownWeb({required String label, required IconData icon, required bool isLoading, String? value, required List<DropdownMenuItem<String>> items, required Function(String?)? onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        items: items,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.textMain),
          hintText: isLoading ? "SYNCING..." : label,
          border: InputBorder.none,
        ),
        validator: (v) => v == null ? "Required" : null,
      ),
    );
  }

  Widget _buildTextFieldWeb(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12, color: Colors.grey),
          prefixIcon: Icon(icon, color: AppColors.textMain),
          border: InputBorder.none,
        ),
        validator: (v) => v!.isEmpty ? "Required" : null,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 65,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 10,
        ),
        onPressed: _isSubmitting ? null : () => _submitForm(),
        child: _isSubmitting 
          ? const CircularProgressIndicator(color: Colors.black)
          : const Text("INITIALIZE VEHICLE DEPLOYMENT", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.2)),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedModelId == null) return;
    setState(() => _isSubmitting = true);
    final carData = {
      'modelId': _selectedModelId, 
      'year': int.parse(_yearController.text),
      'color': _colorController.text,
      'plateNumber': _plateController.text,
      'mileageKm': int.parse(_mileageController.text.replaceAll(',', '').trim()),
      'monthlyAvgKm': double.tryParse(_avgConsController.text) ?? 0.0,
    };
    final success = await Provider.of<AppProvider>(context, listen: false).addNewCarv2(carData);
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vehicle Registered!'), backgroundColor: Colors.green));
    }
  }
}