import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

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
      final String response = await rootBundle.loadString('assets/json/invoices.json');
      final List<dynamic> data = await json.decode(response);
      _masterInvoiceList = data;
      emit(InvoicesLoaded(allInvoices: _masterInvoiceList, filteredInvoices: _masterInvoiceList));
    } catch (e) {
      emit(InvoicesError(message: "Failed to load invoices: $e"));
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
        final filteredList = _masterInvoiceList.where((invoice) {
          return (invoice['orderNumber'] as String).toLowerCase().contains(query);
        }).toList();
        emit(InvoicesLoaded(allInvoices: _masterInvoiceList, filteredInvoices: filteredList));
      }
    }
  }
}