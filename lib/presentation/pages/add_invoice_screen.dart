import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/create_invoice_bloc.dart';
import '../bloc/buyers_bloc.dart';
import 'invoice_print_page.dart'; // Added import for InvoicePrintPage
import 'package:dropdown_search/dropdown_search.dart';

class AddInvoiceScreen extends StatefulWidget {
  final List<Map<String, dynamic>> selectedProducts;

  const AddInvoiceScreen({super.key, required this.selectedProducts});

  @override
  State<AddInvoiceScreen> createState() => _AddInvoiceScreenState();
}

class _AddInvoiceScreenState extends State<AddInvoiceScreen> {
  final _tinController = TextEditingController();
  Map<String, dynamic>? _selectedBuyer;

  double _subtotal = 0;
  double _tax = 0;
  double _total = 0;

  @override
  void initState() {
    super.initState();
    _calculateTotals();
  }

  void _calculateTotals() {
    double currentSubtotal = 0;
    for (var product in widget.selectedProducts) {
      final price = product['price'] is String ? double.tryParse(product['price']) ?? 0.0 : product['price'];
      currentSubtotal += (product['quantity'] as int) * (price as num);
    }
    
    const taxRate = 0.15; // Using a fixed 15% tax rate

    setState(() {
      _subtotal = currentSubtotal;
      _tax = _subtotal * taxRate;
      _total = _subtotal + _tax;
    });
  }

  @override
  void dispose() {
    _tinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF3B82F6);
    final authState = context.read<AuthBloc>().state;
    String token = '';
    if (authState is AuthSuccess) {
          token = authState.user.accessToken ?? '';
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => CreateInvoiceBloc()),
        BlocProvider(create: (context) => BuyersBloc()..add(LoadBuyers(token: token))),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F8),
        appBar: _buildAppBar(context),
        body: BlocListener<CreateInvoiceBloc, CreateInvoiceState>(
          listener: (context, state) {
            if (state is CreateInvoiceSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invoice created successfully!'), backgroundColor: Colors.green),
              );
              
              // Navigate to print page with the response data
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => InvoicePrintPage(
                    invoiceData: state.responseData['data'] ?? {},
                  ),
                ),
              );
            } else if (state is CreateInvoiceFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error), backgroundColor: Colors.red),
              );
            }
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                // _buildSearchBar(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProductSummaryList(),
                      const SizedBox(height: 24),
                      _buildCompanyInfoSection(),
                      const SizedBox(height: 24),
                      _buildFinancialSummary(),
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
      title: const Text('Add Invoice', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w900,fontSize: 18)),
      centerTitle: false,
      actions: [
        TextButton(
          onPressed: () {},
          child: const Row(
            children: [
              Text('Hiwot M.', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
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

  Widget _buildProductSummaryList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Products', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        const SizedBox(height: 8),
        ...widget.selectedProducts.map((product) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              '${product['name']} (Qty: ${product['quantity']})',
              style: const TextStyle(color: Colors.black, fontSize: 14)
            ),
          );
        }).toList(),
      ],
    );
  }

Widget _buildCompanyInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Company Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,color: Color(0xFF1E3A8A))),
        const Text('Add the information of the client company', style: TextStyle(color: Colors.black)),
        const SizedBox(height: 16),
        const Text('Company Name', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        BlocBuilder<BuyersBloc, BuyersState>(
          builder: (context, state) {
            if (state is BuyersLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is BuyersLoaded) {
              return DropdownSearch<Map<String, dynamic>>(
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      hintText: "Search for a company...",
                      // Set the border color when the field is not focused
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      // Set the border color when the field is focused (being typed in)
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF3B82F6)), // Your primary blue color
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  menuProps: const MenuProps(
                    backgroundColor: Colors.white,
                  ),
                  fit: FlexFit.loose,
                ),
                items: state.buyers.cast<Map<String, dynamic>>(),
                itemAsString: (Map<String, dynamic> buyer) => buyer['legal_name'] ?? 'Unknown Buyer',
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    hintText: 'Select a company',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
                  ),
                ),
                selectedItem: _selectedBuyer,
                onChanged: (newValue) {
                  setState(() {
                    _selectedBuyer = newValue;
                    _tinController.text = newValue?['tin'] ?? '';
                  });
                },
              );
            }
            if (state is BuyersError) {
              return Text('Error: ${state.message}');
            }
            return const Text('Could not load companies.');
          },
        ),
        const SizedBox(height: 16),
        const Text('Company TIN Number', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _tinController,
          readOnly: true,
          decoration: InputDecoration(
             hintText: 'TIN Number', 
            filled: true,
            fillColor: Colors.grey.shade200,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialSummary() {
    return Container(
       color:Colors.grey.shade100,
      padding: const EdgeInsets.all(16.0),
      child:Column(
      children: [
        _buildSummaryRow('Total (Before VAT)', '${_subtotal.toStringAsFixed(2)} ETB', isTotal: true),
        const Divider(),
        _buildSummaryRow('Tax 15%', '(+) ${_tax.toStringAsFixed(2)} ETB'),
        const Divider(),
        _buildSummaryRow('Delivery', '(+) 250.00 ETB'),
        const Divider(),
        _buildSummaryRow('Discount', '(-) 0.00 ETB'),
        const Divider(),
        _buildSummaryRow('Total Amount :', '${(_total + 250).toStringAsFixed(2)} ETB'),
      ],
    ));
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    final Color textColor = isTotal ? const Color(0xFF0D47A1) : Colors.black87;
    final FontWeight fontWeight = isTotal ? FontWeight.w900 : FontWeight.normal;
    final double fontSize = isTotal ? 18 : 14;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: textColor, fontWeight: fontWeight, fontSize: fontSize)),
          Text(value, style: TextStyle(color: textColor, fontWeight: fontWeight, fontSize: fontSize)),
        ],
      ),
    );
  }

  Widget _buildBottomButton(Color color) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: BlocBuilder<CreateInvoiceBloc, CreateInvoiceState>(
        builder: (context, state) {
          return ElevatedButton(
            onPressed: state is CreateInvoiceInProgress
                ? null
                : () {
                    final authState = context.read<AuthBloc>().state;
                    String token = '';
                    String companyId = '';

                    if (authState is AuthSuccess) {
                              token = authState.user.accessToken ?? '';
        companyId = authState.user.companyId ?? '';
                    }

                    if (token.isEmpty || companyId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Authentication error. Please log in again.'), backgroundColor: Colors.red),
                      );
                      return;
                    }

                    // Validate that all products have valid IDs
                    for (var product in widget.selectedProducts) {
                      if (product['id'] == null || product['id'].toString().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invalid product data. Please select products from search results.'), backgroundColor: Colors.red),
                        );
                        return;
                      }
                    }

                    final List<Map<String, dynamic>> itemsPayload = widget.selectedProducts.map((product) {
                      int index = widget.selectedProducts.indexOf(product);
                      return {
                        "description": product['name'],
                        "discount": 0,
                        "excise_tax_value": 0,
                        "line_number": index + 1,
                        "product_id": product['id'],
                        "quantity": product['quantity'],
                        "tax_code": "VAT15", // Hardcoded tax code
                        "unit_price": product['price']
                      };
                    }).toList();

                    final invoicePayload = {
                      "buyer_tin": _tinController.text,
                      "company_id": companyId,
                      "document_type": "INV",
                      "excise_value": 0,
                      "invoice_currency": "ETB",
                      "items": itemsPayload,
                      "payment_mode": "CASH",
                      "payment_term": "IMMIDIATE",
                      "transaction_type": "B2B",
                      "transaction_withhold_value": 0
                    };
                    
                    context.read<CreateInvoiceBloc>().add(SubmitInvoice(invoiceData: invoicePayload, token: token));
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: state is CreateInvoiceInProgress
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                : const Text('Create & Print Invoice', style: TextStyle(fontSize: 16)),
          );
        },
      ),
    );
  }
}
