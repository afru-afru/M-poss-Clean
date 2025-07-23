import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'bloc/invoices_bloc.dart';
import 'select_products_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      
      create: (context) => InvoicesBloc()..add(LoadInvoices()),
      child: Scaffold(
        backgroundColor: Colors.white, 
        body: BlocBuilder<InvoicesBloc, InvoicesState>(
          
          builder: (context, state) {
            if (state is InvoicesLoading || state is InvoicesInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is InvoicesLoaded) {
              return _buildInvoiceView(context, state.filteredInvoices);
            }
            if (state is InvoicesError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('Something went wrong.'));
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SelectProductsScreen()),
            );
          },
          backgroundColor: const Color(0xFF3B82F6),
          child: const Icon(Icons.add, color: Colors.white),
          shape: const CircleBorder(),
        ),
      ),
    );
  }

  Widget _buildInvoiceView(BuildContext context, List<dynamic> invoices) {
    return Column(
    
      children: [
         
        _buildSearchBar(context),
        Expanded(
          
          child: invoices.isEmpty
              ? const Center(child: Text('No invoices found.'))
              : ListView.builder(
                  itemCount: invoices.length,
                  itemBuilder: (context, index) {
                    final invoice = invoices[index];
                    final bool showDateHeader = index == 0 || invoices[index]['orderDate'] != invoices[index - 1]['orderDate'];
                    if (showDateHeader) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDateHeader(invoice['orderDate']),
                          _buildInvoiceItem(invoice),
                        ],
                      );
                    } else {
                      return _buildInvoiceItem(invoice);
                    }
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      
      color: const Color(0xFFF0F4FF),
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        onChanged: (query) {
          context.read<InvoicesBloc>().add(SearchInvoices(query: query));
        },
        decoration: InputDecoration(
          hintText: 'Search',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            // Added a subtle border
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildDateHeader(String dateString) {
    final date = DateTime.parse(dateString);
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(date);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Text(
        formattedDate,
       
        style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
      ),
    );
  }



Widget _buildInvoiceItem(Map<String, dynamic> invoice) {
  final amountFormat = NumberFormat("#,##0.00", "en_US");
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    decoration: const BoxDecoration(
      // color: Colors.white, 
      border: Border(bottom: BorderSide(color: Color(0xFFF0F4FF), width: 2)),
    ),
    child: Row(
      children: [
        Image.asset(
          'assets/invoice-04.png', 
          width: 30,
          height: 30,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sales Invoice ${invoice['orderNumber']}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              Text(invoice['time'] ?? 'N/A', style: const TextStyle(color: Colors.grey, fontSize: 12,fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Text('${amountFormat.format(invoice['totalAmount'])} ETB', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
      ],
    ),
  );
}
}