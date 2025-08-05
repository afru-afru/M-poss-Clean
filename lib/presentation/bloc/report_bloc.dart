// lib/bloc/report_bloc.dart

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'report_event.dart';
part 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  // A master list to hold all invoices after the initial load
  List<dynamic> _masterInvoiceList = [];

  ReportBloc() : super(ReportInitial()) {
    on<LoadReports>(_onLoadReports);
    on<SearchReports>(_onSearchReports); // Add handler for the search event
  }

  Future<void> _onLoadReports(
    LoadReports event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    try {
      final String response = await rootBundle.loadString('assets/json/invoices.json');
      final List<dynamic> data = await json.decode(response);
      _masterInvoiceList = data; // Store the full list
      // Initially, the filtered list is the same as the full list
      emit(ReportLoaded(allInvoices: _masterInvoiceList, filteredInvoices: _masterInvoiceList));
    } catch (e) {
      emit(ReportError(message: "Failed to load reports: $e"));
    }
  }

  void _onSearchReports(
    SearchReports event,
    Emitter<ReportState> emit,
  ) {
    final currentState = state;
    if (currentState is ReportLoaded) {
      final query = event.query.toLowerCase();
      if (query.isEmpty) {
        // If query is empty, show all invoices
        emit(ReportLoaded(allInvoices: _masterInvoiceList, filteredInvoices: _masterInvoiceList));
      } else {
        // Otherwise, filter the master list by order number
        final filteredList = _masterInvoiceList.where((invoice) {
          final orderNumber = (invoice['orderNumber'] as String).toLowerCase();
          final orderType = (invoice['orderType'] as String).toLowerCase();
          return orderNumber.contains(query) || orderType.contains(query);
        }).toList();
        emit(ReportLoaded(allInvoices: _masterInvoiceList, filteredInvoices: filteredList));
      }
    }
  }
}