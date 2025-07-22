// lib/report_page.dart

import 'package:flutter/material.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  // Dummy data for the report list
  final List<Map<String, String>> _invoiceData = const [
    {'order_number': '00032', 'type': 'POS Order', 'date': '12/10/2024', 'status': 'Completed'},
    {'order_number': '00031', 'type': 'Online Order', 'date': '11/10/2024', 'status': 'Pending'},
    {'order_number': '00030', 'type': 'POS Order', 'date': '11/10/2024', 'status': 'Completed'},
    {'order_number': '00029', 'type': 'POS Order', 'date': '10/10/2024', 'status': 'Cancelled'},
    {'order_number': '00028', 'type': 'Online Order', 'date': '09/10/2024', 'status': 'Completed'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF4F6F8),
      child: ListView(
        children: [
          _buildSearchBar(),
          _buildHeader(),
          // Generate the list of invoice cards from the dummy data
          ..._invoiceData.map((invoice) => _buildInvoiceCard(invoice)).toList(),
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

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('All Sales Report', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Color(0xFF1E3A8A))),
          SizedBox(height: 4),
          Text('Lorem ipsum dolor sit amet, consectetur adipiscing', style: TextStyle(color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(Map<String, String> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
    
      child: Card(
          color:Colors.white,
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),side: BorderSide(color: Colors.grey.shade300)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Invoice Order ${data['order_number']}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                    const SizedBox(height: 4),
                    Text(data['type']!, style: const TextStyle(color: Colors.black, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('Ordered at: ${data['date']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildStatusChip(data['status']!),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('View Detail'),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case 'Completed':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        break;
      case 'Pending':
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        break;
      case 'Cancelled':
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        break;
      default:
        backgroundColor = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(status, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}