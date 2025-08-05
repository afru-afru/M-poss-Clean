

import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../bloc/add_product_bloc.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _productNameController = TextEditingController(text: 'Cold Cereals');
  final _itemController = TextEditingController(text: 'Cold cereals');
  final _quantityController = TextEditingController(text: '300');
  final _unitController = TextEditingController(text: 'Pack');

  String? _selectedCategory = 'Dry Food Items';
  String? _selectedSubCategory = 'Bread Aisle';
  String? _selectedType = '-';
  String? _selectedStatus = 'Pending';
  
  XFile? _selectedImage;

  final List<String> _categoryOptions = ['Dry Food Items', 'Cold Items', 'Fresh Produce'];
  final List<String> _subCategoryOptions = ['Bread Aisle', 'Snack Aisle', 'Cereal Aisle'];
  final List<String> _typeOptions = ['-', 'Type A', 'Type B'];
  final List<String> _statusOptions = ['Pending', 'Active', 'Discontinued'];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _itemController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF3B82F6);

    return BlocProvider(
      create: (context) => AddProductBloc(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F8),
        appBar: _buildAppBar(context),
        body: BlocListener<AddProductBloc, AddProductState>(
          listener: (context, state) {
            if (state is AddProductSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product Added Successfully!'), backgroundColor: Colors.green),
              );
            } else if (state is AddProductFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error), backgroundColor: Colors.red),
              );
            }
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildSearchBar(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildTextField(label: 'Product Name', controller: _productNameController),
                      _buildImageUploader(),
                      _buildDropdownField(label: 'Category', value: _selectedCategory, items: _categoryOptions, onChanged: (val) => setState(() => _selectedCategory = val)),
                      _buildDropdownField(label: 'Sub Category', value: _selectedSubCategory, items: _subCategoryOptions, onChanged: (val) => setState(() => _selectedSubCategory = val)),
                      _buildTextField(label: 'Item', controller: _itemController),
                      _buildDropdownField(label: 'Type', value: _selectedType, items: _typeOptions, onChanged: (val) => setState(() => _selectedType = val)),
                      _buildTextField(label: 'Quantity', controller: _quantityController, keyboardType: TextInputType.number),
                      _buildTextField(label: 'Unit', controller: _unitController),
                      _buildDropdownField(label: 'Status', value: _selectedStatus, items: _statusOptions, onChanged: (val) => setState(() => _selectedStatus = val)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomButton(primaryBlue),
      ),
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
      title: const Text('Add Product', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 20)),
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
      color: const Color(0xFFEFF4FF),
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

  Widget _buildTextField({required String label, required TextEditingController controller, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
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
          GestureDetector(
            onTap: _pickImage,
            child: DottedBorder(
              color: Colors.blue.shade300,
              strokeWidth: 1,
              dashPattern: const [6, 6],
              borderType: BorderType.RRect,
              radius: const Radius.circular(12),
              child: Container(
                height: 65,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _selectedImage == null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_upload_outlined, color: primaryBlue),
                          const SizedBox(width: 8),
                          Text.rich(
                            TextSpan(
                              text: 'Drop Files to attach, or ',
                              style: const TextStyle(color: Colors.grey),
                              children: [
                                TextSpan(
                                  text: 'Browse',
                                  style: const TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          )
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.file(File(_selectedImage!.path), width: 40, height: 40, fit: BoxFit.cover),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _selectedImage!.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _selectedImage = null;
                              });
                            },
                          ),
                        ],
                      ),
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
      child: BlocBuilder<AddProductBloc, AddProductState>(
        builder: (context, state) {
          return ElevatedButton(
            onPressed: state is AddProductInProgress
                ? null
                : () {
                    context.read<AddProductBloc>().add(
                          AddProductSubmitted(productName: _productNameController.text),
                        );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: state is AddProductInProgress
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                : const Text('Add Product', style: TextStyle(fontSize: 16)),
          );
        },
      ),
    );
  }
}