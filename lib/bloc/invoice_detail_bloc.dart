import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'invoice_detail_event.dart';
part 'invoice_detail_state.dart';

class InvoiceDetailBloc extends Bloc<InvoiceDetailEvent, InvoiceDetailState> {
  InvoiceDetailBloc() : super(InvoiceDetailInitial()) {
    on<FetchInvoiceDetail>(_onFetchInvoiceDetail);
  }

  Future<void> _onFetchInvoiceDetail(
    FetchInvoiceDetail event,
    Emitter<InvoiceDetailState> emit,
  ) async {
    emit(InvoiceDetailLoading());
    try {
      // In a real app, you would use event.invoiceId to make an API call.
      // For now, we just load our single detail file.
      final String response = await rootBundle.loadString('assets/json/invoice_detail.json');
      final data = await json.decode(response);
      emit(InvoiceDetailLoaded(invoice: data));
    } catch (e) {
      emit(InvoiceDetailError(message: "Failed to load invoice detail: $e"));
    }
  }
}