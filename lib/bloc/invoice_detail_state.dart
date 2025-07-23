part of 'invoice_detail_bloc.dart';

abstract class InvoiceDetailState extends Equatable {
  const InvoiceDetailState();
  @override
  List<Object> get props => [];
}

class InvoiceDetailInitial extends InvoiceDetailState {}
class InvoiceDetailLoading extends InvoiceDetailState {}
class InvoiceDetailLoaded extends InvoiceDetailState {
  final Map<String, dynamic> invoice;
  const InvoiceDetailLoaded({required this.invoice});
  @override
  List<Object> get props => [invoice];
}
class InvoiceDetailError extends InvoiceDetailState {
  final String message;
  const InvoiceDetailError({required this.message});
  @override
  List<Object> get props => [message];
}