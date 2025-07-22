// lib/add_product_page.dart

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  // State variables for dropdowns
  String? _selectedCategory = 'Dry Food Items';
  String? _selectedSubCategory = 'Bread Aisle';
  String? _selectedType = '-';
  String? _selectedStatus = 'Pending';

  // Options for the dropdowns
  final List<String> _categoryOptions = ['Dry Food Items', 'Cold Items', 'Fresh Produce'];
  final List<String> _subCategoryOptions = ['Bread Aisle', 'Snack Aisle', 'Cereal Aisle'];
  final List<String> _typeOptions = ['-', 'Type A', 'Type B'];
  final List<String> _statusOptions = ['Pending', 'Active', 'Discontinued'];


  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF3B82F6);

    return Scaffold(
      backgroundColor:Color(0xFFF4F6F8),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSearchBar(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildTextField(label: 'Product Name', initialValue: 'Cold Cereals'),
                  _buildImageUploader(),
                  _buildDropdownField(label: 'Category', value: _selectedCategory, items: _categoryOptions, onChanged: (val) => setState(() => _selectedCategory = val)),
                  _buildDropdownField(label: 'Sub Category', value: _selectedSubCategory, items: _subCategoryOptions, onChanged: (val) => setState(() => _selectedSubCategory = val)),
                  _buildTextField(label: 'Item', initialValue: 'Cold cereals'),
                  _buildDropdownField(label: 'Type', value: _selectedType, items: _typeOptions, onChanged: (val) => setState(() => _selectedType = val)),
                  _buildTextField(label: 'Quantity', initialValue: '300', keyboardType: TextInputType.number),
                  _buildTextField(label: 'Unit', initialValue: 'Pack'),
                  _buildDropdownField(label: 'Status', value: _selectedStatus, items: _statusOptions, onChanged: (val) => setState(() => _selectedStatus = val)),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(primaryBlue),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    const Color primaryBlue = Color(0xFF3B82F6);
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: primaryBlue),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text('Add Product', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold,fontSize: 20)),
      centerTitle: false,
      actions: [
        TextButton(
          onPressed: () {},
          child: const Row(
            children: [
              Text('Hiwot M.', style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold)),
              SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, color: primaryBlue),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
       color: Color(0xFFEFF4FF),
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required String initialValue, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: initialValue,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploader() {
    const Color primaryBlue = Color(0xFF0D47A1);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Product Image', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DottedBorder(
            color: Colors.blue.shade300,
            strokeWidth: 1,
            dashPattern: const [6, 6],
            borderType: BorderType.RRect,
            radius: const Radius.circular(12),
            child: Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 7.5,
                children: [
                  const Icon(Icons.cloud_upload_outlined, color: primaryBlue),
                  const SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      text: 'Drop Files to attach, or ',
                      style: const TextStyle(color: Colors.grey),
                      children: [
                        TextSpan(
                          text: 'Browse',
                          style: const TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
                          // recognizer can be added here for tap events
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
  
  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value,
            items: items.map((item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBottomButton(Color color) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Add Product', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}