part of 'invoice_detail_bloc.dart';

abstract class InvoiceDetailEvent extends Equatable {
  const InvoiceDetailEvent();
  @override
  List<Object> get props => [];
}

class FetchInvoiceDetail extends InvoiceDetailEvent {
  final String invoiceId;
  const FetchInvoiceDetail({required this.invoiceId});
  @override
  List<Object> get props => [invoiceId];
}