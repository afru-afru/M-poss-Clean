import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'add_invoice_screen.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/cart_bloc.dart';

class SelectProductsScreen extends StatefulWidget {
  const SelectProductsScreen({super.key});

  @override
  State<SelectProductsScreen> createState() => _SelectProductsScreenState();
}

class _SelectProductsScreenState extends State<SelectProductsScreen> {
  // State variable to control the visibility of the header
  bool _showTitle = true;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CartBloc(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F8),
        body: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            if (state is CartLoading) {
              return _buildProductSelectionView(context, [], isLoading: true);
            }
            if (state is CartLoaded) {
              return _buildProductSelectionView(context, state.products);
            }
            if (state is CartError) {
              return Center(child: Text(state.message));
            }
            return _buildProductSelectionView(context, []);
          },
        ),
      ),
    );
  }

  Widget _buildProductSelectionView(BuildContext context, List<Map<String, dynamic>> products, {bool isLoading = false}) {
    int totalProducts = 0;
    double totalPrice = 0;
    for (var product in products) {
      if (product['quantity'] > 0) {
        totalProducts += product['quantity'] as int;
        final price = product['price'] is String ? double.tryParse(product['price']) ?? 0.0 : product['price'];
        totalPrice += (product['quantity'] as int) * (price as num);
      }
    }

    return Material(
      color: const Color(0xFFF4F6F8),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align header to the start
            children: [
              _buildSearchBar(context),
              // Conditionally display the header based on the _showTitle state
              if (_showTitle) _buildHeader(),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : products.isEmpty
                        ? const Center(
                            child: Text(
                              'Start typing to search for products.',
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 100),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              return _buildProductItem(context, products[index]);
                            },
                          ),
              ),
            ],
          ),
          _buildSummaryBar(context, totalPrice, totalProducts),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      color: const Color(0xFFEFF4FF),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: TextField(
        onChanged: (query) {
          // Update the state to hide/show the title based on search input
          setState(() {
            _showTitle = query.isEmpty;
          });

          final authState = context.read<AuthBloc>().state;
          String token = '';
          String companyId = '';

          if (authState is AuthSuccess) {
            token = authState.user['access_token'] ?? '';
            companyId = authState.user['companyId'] ?? '';
          }
          
          debugPrint("Searching with token: $token and companyId: $companyId");

          context.read<CartBloc>().add(SearchCartProducts(query: query, token: token, companyId: companyId));
        },
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
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Products', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
          SizedBox(height: 4),
          Text('Search a product name and add to the invoice', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildProductItem(BuildContext context, Map<String, dynamic> product) {
    final price = product['price'] is String ? double.tryParse(product['price']) ?? 0.0 : product['price'];
    final total = (price as num) * (product['quantity'] as int);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Card(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            Image.network(
              product['imageUrl'] ?? 'https://via.placeholder.com/90',
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 90,
                  height: 90,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                );
              },
            ),
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
                          Text(product['name'] ?? 'No Name', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text('Quantity : ${product['quantity']}    Total : ${total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    _buildQuantityAdjuster(context, product),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityAdjuster(BuildContext context, Map<String, dynamic> product) {
    int quantity = product['quantity'];
    String productId = product['id'];

    if (quantity == 0) {
      return TextButton.icon(
        onPressed: () {
          context.read<CartBloc>().add(AddCartItem(productId));
        },
        icon: const Icon(Icons.add),
        label: const Text('Add'),
        style: TextButton.styleFrom(
          foregroundColor: Colors.blue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } else {
      return Row(
        children: [
          _buildAdjusterButton(
            icon: Icons.remove,
            onPressed: () {
              context.read<CartBloc>().add(RemoveCartItem(productId));
            },
            backgroundColor: Colors.grey.shade200,
            iconColor: Colors.grey.shade800,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          _buildAdjusterButton(
            icon: Icons.add,
            onPressed: () {
              context.read<CartBloc>().add(AddCartItem(productId));
            },
            backgroundColor: Colors.blue,
            iconColor: Colors.white,
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
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: iconColor, size: 18),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildSummaryBar(BuildContext context, double totalPrice, int totalProducts) {
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
                Text('${totalPrice.toStringAsFixed(2)} ETB', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Products : $totalProducts', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                final cartState = context.read<CartBloc>().state;
                final authBloc = context.read<AuthBloc>();

                if (cartState is CartLoaded) {
                  final selectedProducts = cartState.products.where((p) => p['quantity'] > 0).toList();
                  if (selectedProducts.isNotEmpty) {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: authBloc,
                          child: AddInvoiceScreen(selectedProducts: selectedProducts),
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select at least one product.'), backgroundColor: Colors.orange),
                    );
                  }
                }
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