// lib/invoice_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/invoice_detail_bloc.dart';

class InvoiceDetailPage extends StatelessWidget {
  final String invoiceId;
  const InvoiceDetailPage({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InvoiceDetailBloc()..add(FetchInvoiceDetail(invoiceId: invoiceId)),
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: BlocBuilder<InvoiceDetailBloc, InvoiceDetailState>(
          builder: (context, state) {
            if (state is InvoiceDetailLoading || state is InvoiceDetailInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is InvoiceDetailLoaded) {
              return _buildInvoiceView(state.invoice);
            }
            if (state is InvoiceDetailError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('Something went wrong'));
          },
        ),
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
      title: Text('Invoice #$invoiceId', style: const TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInvoiceView(Map<String, dynamic> invoice) {
    final companyInfo = invoice['companyInfo'] as Map<String, dynamic>;
    final lineItems = invoice['lineItems'] as List<dynamic>;
    final summary = invoice['financialSummary'] as Map<String, dynamic>;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Company Info
        Text('Billed To:', style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 8),
        Text(companyInfo['name'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text('TIN: ${companyInfo['tinNumber'] ?? 'N/A'}'),
        const SizedBox(height: 8),
        Text('Date: ${invoice['orderDate']} at ${invoice['time']}'),
        const Divider(height: 32),

        // Line Items
        const Text('Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),
        ...lineItems.map((item) => ListTile(
              title: Text(item['productName']),
              subtitle: Text('Quantity: ${item['quantity']}'),
              trailing: Text('${item['total']} ETB'),
            )),
        const Divider(height: 32),

        // Financial Summary
        _buildSummaryRow('Subtotal', '${summary['subtotal']} ETB'),
        _buildSummaryRow('Tax (15%)', '+ ${summary['tax']} ETB'),
        _buildSummaryRow('Delivery', '+ ${summary['delivery']} ETB'),
        _buildSummaryRow('Discount', '- ${summary['discount']} ETB'),
        const Divider(),
        _buildSummaryRow('Total Amount', '${summary['total']} ETB', isTotal: true),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    final style = TextStyle(
      fontSize: isTotal ? 18 : 14,
      fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
      color: isTotal ? const Color(0xFF0D47A1) : Colors.black87,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}