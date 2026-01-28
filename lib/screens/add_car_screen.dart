import 'package:flutter/material.dart';
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

  // الاختيارات
  String? _selectedBrandId;
  String? _selectedModelId;
  
  // Controllers للحقول الباقية
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _kmController = TextEditingController();

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
      print("Error loading brands: $e");
    }
  }

  // 2. تحميل الموديلات لما يختار ماركة
  Future<void> _loadModels(String brandId) async {
    setState(() {
      _isLoadingModels = true;
      _models = [];
      _selectedModelId = null; // تصفير الموديل السابق
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
      print("Error loading models: $e");
    }
  }

  // 3. حفظ السيارة
  Future<void> _saveCar() async {
    if (!_formKey.currentState!.validate()) return;
    
    // التأكد من اختيار الموديل
    if (_selectedModelId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a car model')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    
    // تجهيز البيانات للباك إند
    final carData = {
      'modelId': _selectedModelId, // تم التصحيح: المفتاح هنا لازم يكون modelId عشان السيرفيس يحوله لـ carModelId
      'year': int.parse(_yearController.text),
      'color': _colorController.text,
      'currentKm': int.parse(_kmController.text),
    };

    final success = await Provider.of<AppProvider>(context, listen: false).addNewCarv2(carData);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Car added successfully!'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add car'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Car")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- 1. Brands Dropdown ---
              _isLoadingBrands 
                ? const LinearProgressIndicator()
                : DropdownButtonFormField<String>(
                    decoration: _inputDecoration("Car Make / Brand", Icons.branding_watermark),
                    initialValue: _selectedBrandId,
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
                        _loadModels(value); // تحميل الموديلات التابعة للماركة
                      }
                    },
                    validator: (v) => v == null ? "Required" : null,
                  ),
              
              const SizedBox(height: 15),

              // --- 2. Models Dropdown ---
              _isLoadingModels
                  ? const LinearProgressIndicator()
                  : DropdownButtonFormField<String>(
                    decoration: _inputDecoration("Car Model", Icons.directions_car),
                    initialValue: _selectedModelId,
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

              // --- 3. Year ---
              TextFormField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("Year", Icons.calendar_today),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),

              const SizedBox(height: 15),

              // --- 4. Color ---
              TextFormField(
                controller: _colorController,
                decoration: _inputDecoration("Color", Icons.color_lens),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),

              const SizedBox(height: 15),

              // --- 5. Current KM ---
              TextFormField(
                controller: _kmController,
                keyboardType: TextInputType.number,
                // تم التصحيح هنا: استخدام Icons.speed بدلاً من Icons.speedometer
                decoration: _inputDecoration("Current Mileage (KM)", Icons.speed),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),

              const SizedBox(height: 30),

              // --- Submit Button ---
              ElevatedButton(
                onPressed: _isSubmitting ? null : _saveCar,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: AppColors.primary,
                ),
                child: _isSubmitting 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Add Car", style: TextStyle(color: Colors.white, fontSize: 16)),
              )
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}