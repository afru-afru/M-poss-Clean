part of 'invoices_bloc.dart';

abstract class InvoicesState extends Equatable {
  const InvoicesState();
  @override
  List<Object> get props => [];
}

class InvoicesInitial extends InvoicesState {}
class InvoicesLoading extends InvoicesState {}

class InvoicesLoaded extends InvoicesState {
  final List<dynamic> allInvoices;
  final List<dynamic> filteredInvoices;

  const InvoicesLoaded({required this.allInvoices, required this.filteredInvoices});
  @override
  List<Object> get props => [allInvoices, filteredInvoices];
}

class InvoicesError extends InvoicesState {
  final String message;
  const InvoicesError({required this.message});
  @override
  List<Object> get props => [message];
}