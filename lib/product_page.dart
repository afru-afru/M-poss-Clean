import 'package:flutter/material.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  // 1. Added more products to the list (now 12 total).
  final List<Map<String, String>> _products = const [
    {'id': 'P0006', 'name': 'Cold Cereals', 'image': 'assets/product1.png', 'category': 'Dry Food'},
    {'id': 'P0005', 'name': 'Chocolate Bar', 'image': 'assets/product2.png', 'category': 'Snacks'},
    {'id': 'P0004', 'name': 'Omar Vegetable Oil', 'image': 'assets/product3.png', 'category': 'Cooking'},
    {'id': 'P0003', 'name': 'Eggs', 'image': 'assets/product4.png', 'category': 'Dairy'},
    {'id': 'P0002', 'name': 'Penne', 'image': 'assets/product1.png', 'category': 'Pasta'},
    {'id': 'P0001', 'name': 'Mayonnaise', 'image': 'assets/product2.png', 'category': 'Condiment'},
    {'id': 'P0007', 'name': 'Instant Noodles', 'image': 'assets/product3.png', 'category': 'Dry Food'},
    {'id': 'P0008', 'name': 'Potato Chips', 'image': 'assets/product1.png', 'category': 'Snacks'},
    {'id': 'P0009', 'name': 'Olive Oil', 'image': 'assets/product3.png', 'category': 'Cooking'},
    {'id': 'P0010', 'name': 'Milk', 'image': 'assets/product4.png', 'category': 'Dairy'},
    {'id': 'P0011', 'name': 'Spaghetti', 'image': 'assets/product1.png', 'category': 'Pasta'},
    {'id': 'P0012', 'name': 'Ketchup', 'image': 'assets/product4.png', 'category': 'Condiment'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF4F6F8),
      child: ListView(
        children: [
          _buildSearchBar(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('All Products', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,color:Color(0xFF0D47A1))),
                const SizedBox(height: 4),
                const Text('Lorem ipsum dolor sit amet, consectetur', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                _buildDataTable(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Color(0xFFEFF4FF),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
Widget _buildDataTable() {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.0),
    ),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        dataRowHeight: 90.0, // Set the height for each data row
        headingRowColor: MaterialStateProperty.all(const Color(0xFFF9FBFE)),
        columnSpacing: 25,
        columns: const [
          DataColumn(label: Text('Product ID', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Product Name', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Product Image', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: _products.map((product) {
          return DataRow(
            cells: [
              DataCell(Text(product['id']!)),
              DataCell(Text(product['name']!)),
              DataCell(
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(product['image']!, width: 95, height: 75, fit: BoxFit.cover),
                  ),
                ),
              ),
              DataCell(Text(product['category']!)),
            ],
          );
        }).toList(),
      ),
    ),
  );
}
}