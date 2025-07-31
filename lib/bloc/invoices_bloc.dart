import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;

part 'invoices_event.dart';
part 'invoices_state.dart';

class InvoicesBloc extends Bloc<InvoicesEvent, InvoicesState> {
  List<dynamic> _masterInvoiceList = [];

  InvoicesBloc() : super(InvoicesInitial()) {
    on<LoadInvoices>(_onLoadInvoices);
    on<SearchInvoices>(_onSearchInvoices);
  }

  Future<void> _onLoadInvoices(
    LoadInvoices event,
    Emitter<InvoicesState> emit,
  ) async {
    emit(InvoicesLoading());
    try {
      // Use the new API endpoint
      final url = Uri.parse('http://196.190.251.122:8082/api/v2/invoices');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
      );

      if (response.statusCode == 200) {
        // Assuming the response body is a list of invoices
        final List<dynamic> data = json.decode(response.body);
        _masterInvoiceList = data;
        emit(InvoicesLoaded(allInvoices: _masterInvoiceList, filteredInvoices: _masterInvoiceList));
      } else {
        throw Exception('Failed to load invoices. Status: ${response.statusCode}');
      }
    } catch (e) {
      emit(InvoicesError(message: e.toString()));
    }
  }

  void _onSearchInvoices(
    SearchInvoices event,
    Emitter<InvoicesState> emit,
  ) {
    final currentState = state;
    if (currentState is InvoicesLoaded) {
      final query = event.query.toLowerCase();
      if (query.isEmpty) {
        emit(InvoicesLoaded(allInvoices: _masterInvoiceList, filteredInvoices: _masterInvoiceList));
      } else {
        // Filter the master list by invoice_number
        final filteredList = _masterInvoiceList.where((invoice) {
          final invoiceNumber = (invoice['invoice_number'] as String?)?.toLowerCase() ?? '';
          return invoiceNumber.contains(query);
        }).toList();
        emit(InvoicesLoaded(allInvoices: _masterInvoiceList, filteredInvoices: filteredList));
      }
    }
  }
}
