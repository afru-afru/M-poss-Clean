import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/report_bloc.dart';
import 'invoice_detail_page.dart';

// 1. Convert to StatefulWidget
class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  // 2. Create a TextEditingController
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReportBloc()..add(LoadReports()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F8),
        body: BlocBuilder<ReportBloc, ReportState>(
          builder: (context, state) {
            if (state is ReportLoading || state is ReportInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ReportLoaded) {
              return _buildReportView(context, state.filteredInvoices);
            }
            if (state is ReportError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('Something went wrong.'));
          },
        ),
      ),
    );
  }

  Widget _buildReportView(BuildContext context, List<dynamic> invoices) {
    return Column(
      children: [
        _buildSearchBar(context),
        _buildHeader(),
        Expanded(
          child: invoices.isEmpty
              ? const Center(
                  child: Text('No matching invoices found.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                )
              : ListView(
                  children: invoices.map((invoice) => _buildInvoiceCard(invoice)).toList(),
                ),
        ),
      ],
    );
  }

  // --- All your styled helper methods are below, with only the search bar modified ---

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      color: const Color(0xFFEFF4FF),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: TextField(
        controller: _searchController,
        onChanged: (query) {
          // This makes the search bar functional
          context.read<ReportBloc>().add(SearchReports(query: query));
        },
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
      color: const Color(0xFFF4F6F8),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('All Sales Report', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
          SizedBox(height: 4),
          Text('Lorem ipsum dolor sit amet, consectetur adipiscing', style: TextStyle(color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Card(
        color: Colors.white,
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade300)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Invoice Order ${data['orderNumber']}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                    const SizedBox(height: 4),
                    Text(data['orderType']!, style: const TextStyle(color: Colors.black, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('Ordered at: ${data['orderDate']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildStatusChip(data['status']!),
                  const SizedBox(height: 8),
                  ElevatedButton(
                      onPressed: () {
    // Navigate to the detail page, passing the invoice ID
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InvoiceDetailPage(invoiceId: data['orderNumber']!),
      ),
    );
  },
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