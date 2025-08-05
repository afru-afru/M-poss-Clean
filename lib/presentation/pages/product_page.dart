import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/products_bloc.dart';


class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
 
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductsBloc()..add(LoadProducts()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F8),
        body: BlocBuilder<ProductsBloc, ProductsState>(
          builder: (context, state) {
            if (state is ProductsLoading || state is ProductsInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ProductsLoaded) {
              //  Pass the filtered list to the UI
              return _buildProductListView(context, state.filteredProducts);
            }
            if (state is ProductsError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('Something went wrong.'));
          },
        ),
      ),
    );
  }

 

Widget _buildProductListView(BuildContext context, List<dynamic> products) {
  return Column(
    children: [
      _buildSearchBar(context),
      Expanded(
        // Add a check here. If the list is empty, show a message.
        child: products.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 60, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No products found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              )
            // Otherwise, show the list with the data table.
            : ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('All Products', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
                        const SizedBox(height: 4),
                        const Text('Lorem ipsum dolor sit amet, consectetur', style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 16),
                        _buildDataTable(products),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    ],
  );
}

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      color: Color(0xFFEFF4FF),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: TextField(
        controller: _searchController,
        // Send a search event every time the text changes
        onChanged: (query) {
          context.read<ProductsBloc>().add(SearchProducts(query: query));
        },
        decoration: InputDecoration(
          hintText: 'Search',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFFF4F6F8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }


  Widget _buildDataTable(List<dynamic> products) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          dataRowHeight: 90.0, // Set a consistent row height
          headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
          columnSpacing: 25,
          columns: const [
            DataColumn(label: Text('Product ID', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Product Name', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Product Image', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: products.map((product) {
            return DataRow(
              cells: [
                DataCell(Text(product['id'] ?? '')),
                DataCell(Text(product['name'] ?? '')),
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      // Use the imageUrl from the JSON file
                      child: Image.asset(product['imageUrl'] ?? 'assets/product_placeholder.png', width: 95, height: 75, fit: BoxFit.cover),
                    ),
                  ),
                ),
                DataCell(Text(product['category'] ?? '')),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}