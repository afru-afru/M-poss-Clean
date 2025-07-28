

import 'package:flutter/material.dart';

class AddInvoiceScreen extends StatefulWidget {
  const AddInvoiceScreen({super.key});

  @override
  State<AddInvoiceScreen> createState() => _AddInvoiceScreenState();
}

class _AddInvoiceScreenState extends State<AddInvoiceScreen> {
  String? _selectedCompany = 'Matrix Technologies';
  final List<String> _companyOptions = ['Matrix Technologies', 'Another Company', 'Client Inc.'];

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF0D47A1);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSearchBar(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(),
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
      // This page has its OWN bottom button, NOT the shared navigation bar
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
      title: const Text('Add Invoice', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w900,fontSize: 18)),
      centerTitle: false,
      actions: [
        TextButton(
          onPressed: () {},
          child:  Row(
            children: [
              Text('Hiwot M.', style: TextStyle(color: primaryBlue)),
              SizedBox(width: 4),
                  Image.asset(
        'assets/dropdownIcon.png', 
        width: 10, 
        height: 10,
        
      ),
            ],
          ),
        ),
      ],
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
Widget _buildSummaryCard() {
  return SizedBox( // Wrap the Card with a SizedBox
    width: double.infinity, // Force it to take the full width
    child: Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product Name', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            SizedBox(height: 8),
            Text('Dry Snak', style: TextStyle(color: Colors.black, fontSize: 14)),
            Text('Quantity : 1', style: TextStyle(color: Colors.black, fontSize: 14)),
            Text('Total : 30,000 ETB', style: TextStyle(color: Colors.black, fontSize: 14)),
          ],
        ),
      ),
    ),
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
        DropdownButtonFormField<String>(
          value: _selectedCompany,
          items: _companyOptions.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedCompany = newValue;
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Company TIN Number', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: '00023467294',
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialSummary() {
   
    return Container(
       color:Colors.grey.shade100,
      
    child:Column(
      
      
      children: [
        
        _buildSummaryRow('Total (Before VAT)', '60,000 ETB', isTotal: true),
        const Divider(),
        _buildSummaryRow('Tax 15%', '(+) 9,000 ETB'),
        const Divider(),
        _buildSummaryRow('Delivery', '(+) 250 ETB'),
        const Divider(),
        _buildSummaryRow('Discount', '(-) 4,500 ETB'),
        const Divider(),
        _buildSummaryRow('Discount', '0 ETB'),
        const Divider(),
        _buildSummaryRow('Total Amount :', '64,750 ETB', isTotal: true),
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
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor:Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Add Invoice', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}