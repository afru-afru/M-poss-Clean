import 'package:flutter/material.dart';
import 'add_invoice_screen.dart';

class SelectProductsScreen extends StatefulWidget {
  const SelectProductsScreen({super.key});

  @override
  State<SelectProductsScreen> createState() => _SelectProductsScreenState();
}

class _SelectProductsScreenState extends State<SelectProductsScreen> {
  // Declare the list here
  List<Map<String, dynamic>> _products = [];

  // This is a constant list, so it's fine to initialize here.
  final List<String> _productImages = [
    'assets/product1.png',
    'assets/product2.png',
    'assets/product3.png',
    'assets/product4.png',
  ];

  // Initialize the data when the widget is first created
  @override
  void initState() {
    super.initState();
    // Generate the products list inside initState
    _products = List.generate(
      10,
      (index) => {
        'id': index,
        'name': 'Product Name',
        'image': _productImages[index % _productImages.length],
        'price': 3000,
        'quantity': index % 3,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate totals based on the current state
    int totalProducts = 0;
    double totalPrice = 0;
    for (var product in _products) {
      if (product['quantity'] > 0) {
        totalProducts += product['quantity'] as int;
        totalPrice += (product['quantity'] as int) * (product['price'] as int);
      }
    }

    // The Scaffold and AppBar have been removed. The widget now returns a Stack directly.
    return  Material( 
        color: const Color(0xFFF4F6F8),
    child:Stack(
      children: [
        Column(
          children: [
            _buildSearchBar(),
            _buildHeader(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 100), // Padding to avoid overlap with summary bar
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  return _buildProductItem(index);
                },
              ),
            ),
          ],
        ),
        // Floating Summary Bar at the bottom
        _buildSummaryBar(totalPrice, totalProducts),
      ],
    ));
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
          fillColor: const Color(0xFFFFFFFF),
          
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      // color: Colors.white,
      // padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Products', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,color: Color(0xFF1E3A8A))),
          SizedBox(height: 4),
          Text('Search a product name and add to the invoice', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

 // In _SelectProductsScreenState, replace the old _buildProductItem method

Widget _buildProductItem(int index) {
  final product = _products[index];
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
    child: Card(
      color: Colors.white,
      elevation: 1,
      shape:  RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        // Add this 'side' property for the border
        side: BorderSide(
          color: Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      // This is important: it forces the image to have rounded corners
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          // 1. The Image is now a direct child of the Row
          Image.asset(
            product['image'],
            width: 90, // Set a fixed width for the image
            height: 90,
            fit: BoxFit.cover,
          ),
          // 2. The rest of the content is wrapped in Expanded and Padding
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(product['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('Quantity : ${product['quantity']}    Total : ${product['price'] * product['quantity']}',
                            style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  _buildQuantityAdjuster(index),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
  Widget _buildQuantityAdjuster(int index) {
    int quantity = _products[index]['quantity'];

    if (quantity == 0) {
      return TextButton.icon(
        onPressed: () {
          setState(() {
            _products[index]['quantity']++;
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('Add'),
        style: TextButton.styleFrom(
          foregroundColor: Colors.blue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } 
    else {
      return Row(
      children: [
        // Minus Button
        _buildAdjusterButton(
          icon: Icons.remove,
          onPressed: () {
            if (quantity > 0) {
              setState(() {
                _products[index]['quantity']--;
              });
            }
          },
          backgroundColor: Colors.grey.shade300, // Grey background
          iconColor: Colors.white,      // Dark grey icon
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        // Plus Button
        _buildAdjusterButton(
          icon: Icons.add,
          onPressed: () {
            setState(() {
              _products[index]['quantity']++;
            });
          },
          backgroundColor: Colors.blue,          // Blue background
          iconColor: Colors.white,               // White icon
        ),
      ],
    );
    }
  
  }
Widget _buildAdjusterButton({
  required IconData icon,
  required VoidCallback onPressed,
  required Color backgroundColor,
  required Color iconColor,
}) {
  return Container(
    width: 32,
    height: 32,
    decoration: BoxDecoration(
      color: backgroundColor, // Use the passed-in color
      borderRadius: BorderRadius.circular(8),
    ),
    child: IconButton(
      padding: EdgeInsets.zero,
      icon: Icon(icon, color: iconColor, size: 18), // Use the passed-in color
      onPressed: onPressed,
    ),
  );
}

  Widget _buildSummaryBar(double totalPrice, int totalProducts) {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF3B82F6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.receipt_long, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${totalPrice.toStringAsFixed(0)} ETB',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Number of Products : $totalProducts',
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
            const Spacer(),
            ElevatedButton(
            // Inside _buildSummaryBar in select_products_screen.dart
onPressed: () {
  Navigator.of(context, rootNavigator: true).push( // This uses the main navigator
    MaterialPageRoute(builder: (context) => const AddInvoiceScreen()),
  );
},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0D47A1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Create Invoice'),
            ),
          ],
        ),
      ),
    );
  }
}