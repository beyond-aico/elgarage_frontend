import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/app_provider.dart';
import '../data/models/car_model.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();

  // State local to the form
  String? _selectedBrand;
  String? _selectedModel;
  final _yearController = TextEditingController();
  final _mileageController = TextEditingController();
  final _avgConsController = TextEditingController();
  final _lastMaintKmController = TextEditingController();
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    // Calling the Provider
    final carProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Add New Car")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Car Identity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

              // --- Brand Dropdown (From Provider) ---
              DropdownButtonFormField<String>(
                value: _selectedBrand,
                decoration: _inputDecoration("Select Brand", CupertinoIcons.tag),
                items: carProvider.brands.map((brand) {
                  return DropdownMenuItem(value: brand, child: Text(brand));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBrand = value;
                    _selectedModel = null; 
                  });
                },
                validator: (value) => value == null ? "Required" : null,
              ),

              const SizedBox(height: 15),

              // --- Model Dropdown (From Provider) ---
              DropdownButtonFormField<String>(
                value: _selectedModel,
                disabledHint: const Text("Select Brand First"),
                decoration: _inputDecoration("Select Model", CupertinoIcons.car_detailed),
                // We ask the provider for models based on the selected brand
                items: carProvider.getModelsForBrand(_selectedBrand).map((model) {
                  return DropdownMenuItem(value: model, child: Text(model));
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedModel = value);
                },
                validator: (value) => value == null ? "Required" : null,
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(child: _buildTextField(_yearController, "Year", CupertinoIcons.calendar, isNumber: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTextField(_mileageController, "Current KM", CupertinoIcons.speedometer, isNumber: true)),
                ],
              ),

              _buildTextField(_avgConsController, "Monthly Avg KM", CupertinoIcons.graph_square, isNumber: true),

              const Divider(height: 40),
              const Text("Last Maintenance", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

              _buildDatePicker(),
              const SizedBox(height: 15),
              _buildTextField(_lastMaintKmController, "Maintenance KM", CupertinoIcons.wrench, isNumber: true),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _submitForm(carProvider), // Pass provider to the submit function
                  child: const Text("Save Car", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Helper Methods ---

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
        final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2010), lastDate: DateTime.now());
        if (picked != null) setState(() => _selectedDate = picked);
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            const Icon(CupertinoIcons.calendar, color: AppColors.primary),
            const SizedBox(width: 10),
            Text(_selectedDate == null ? "Select Maintenance Date" : "${_selectedDate!.toLocal()}".split(' ')[0]),
          ],
        ),
      ),
    );
  }

  void _submitForm(AppProvider provider) {
    if (_formKey.currentState!.validate()) {
      final newCar = CarModel(
        id: DateTime.now().toString(),
        make: _selectedBrand!,
        model: _selectedModel!,
        year: _yearController.text,
        imageUrl: 'assets/images/car1.png',
        currentKm: double.parse(_mileageController.text),
        monthlyAvgKm: double.parse(_avgConsController.text),
        lastMaintenanceDate: _selectedDate,
        lastMaintenanceKm: double.tryParse(_lastMaintKmController.text),
      );

      provider.addCar(newCar);
      Navigator.pop(context);
    }
  }
}