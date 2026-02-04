import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/app_provider.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();

  // القوائم القادمة من الباك إند
  List<dynamic> _brands = [];
  List<dynamic> _models = [];

  // الاختيارات (IDs للباك إند)
  String? _selectedBrandId;
  String? _selectedModelId;

  // Controllers (نفس مسميات الكود الثاني مع إضافة Color)
  final _yearController = TextEditingController();
  final _mileageController = TextEditingController(); // currentKm
  final _colorController = TextEditingController();
  final _avgConsController = TextEditingController();
  final _lastMaintKmController = TextEditingController();
  DateTime? _selectedDate;

  bool _isLoadingBrands = true;
  bool _isLoadingModels = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadBrands();
  }

  // 1. تحميل الماركات عند فتح الشاشة
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

  // 2. تحميل الموديلات لما يختار ماركة
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
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Add New Car", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Car Identity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

              // --- 1. Brands Dropdown ---
              _isLoadingBrands 
                ? const LinearProgressIndicator()
                : DropdownButtonFormField<String>(
                    value: _selectedBrandId,
                    decoration: _inputDecoration("Car Make / Brand", CupertinoIcons.tag),
                    hint: const Text("Select Brand"),
                    items: _brands.map<DropdownMenuItem<String>>((brand) {
                      return DropdownMenuItem(
                        value: brand['id'].toString(), 
                        child: Text(brand['name'] ?? 'Unknown'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedBrandId = value);
                        _loadModels(value); 
                      }
                    },
                    validator: (v) => v == null ? "Required" : null,
                  ),
              
              const SizedBox(height: 15),

              // --- 2. Models Dropdown ---
              _isLoadingModels
                  ? const LinearProgressIndicator()
                  : DropdownButtonFormField<String>(
                      value: _selectedModelId,
                      disabledHint: const Text("Select Brand First"),
                      decoration: _inputDecoration("Car Model", CupertinoIcons.car_detailed),
                      hint: const Text("Select Model"),
                      items: _models.map<DropdownMenuItem<String>>((model) {
                        return DropdownMenuItem(
                          value: model['id'].toString(),
                          child: Text(model['name'] ?? 'Unknown'),
                        );
                      }).toList(),
                      onChanged: _models.isEmpty ? null : (value) {
                        setState(() => _selectedModelId = value);
                      },
                      validator: (v) => v == null ? "Required" : null,
                    ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(child: _buildTextField(_yearController, "Year", CupertinoIcons.calendar, isNumber: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTextField(_colorController, "Color", Icons.color_lens)),
                ],
              ),

              _buildTextField(_mileageController, "Current Mileage (KM)", Icons.speed, isNumber: true),
              _buildTextField(_avgConsController, "Monthly Avg KM", CupertinoIcons.graph_square, isNumber: true),

              const Divider(height: 40),
              const Text("Last Maintenance", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

              _buildDatePicker(),
              const SizedBox(height: 15),
              _buildTextField(_lastMaintKmController, "Maintenance KM", CupertinoIcons.wrench, isNumber: true),

              const SizedBox(height: 30),

              // --- Submit Button ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSubmitting ? null : () => _submitForm(appProvider),
                  child: _isSubmitting 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Save Car", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Helper Methods (نفس هيكل الكود الثاني) ---

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: _inputDecoration(label, icon),
        validator: (value) => value!.isEmpty ? "Required" : null,
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context, 
          initialDate: DateTime.now(), 
          firstDate: DateTime(2010), 
          lastDate: DateTime.now()
        );
        if (picked != null) setState(() => _selectedDate = picked);
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.transparent)
        ),
        child: Row(
          children: [
            const Icon(CupertinoIcons.calendar, color: AppColors.primary, size: 20),
            const SizedBox(width: 10),
            Text(
              _selectedDate == null 
                ? "Select Last Maintenance Date" 
                : DateFormat('yyyy-MM-dd').format(_selectedDate!),
              style: TextStyle(color: _selectedDate == null ? Colors.grey[600] : Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  // --- Logic Helper ---

  Future<void> _submitForm(AppProvider provider) async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedModelId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a car model')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    
    // تجهيز البيانات للباك إند (دمج الحقول من الكودين)
    final carData = {
      'modelId': _selectedModelId, 
      'year': int.parse(_yearController.text),
      'color': _colorController.text,
      'currentKm': int.parse(_mileageController.text),
      'monthlyAvgKm': double.tryParse(_avgConsController.text) ?? 0.0,
      'lastMaintenanceDate': _selectedDate?.toIso8601String(),
      'lastMaintenanceKm': double.tryParse(_lastMaintKmController.text) ?? 0.0,
    };

    final success = await provider.addNewCarv2(carData);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Car added successfully!'), backgroundColor: AppColors.success),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add car'), backgroundColor: AppColors.error),
      );
    }
  }
}