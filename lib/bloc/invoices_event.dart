part of 'invoices_bloc.dart';

abstract class InvoicesEvent extends Equatable {
  const InvoicesEvent();
  @override
  List<Object> get props => [];
}

// Event to load the initial list of invoices
class LoadInvoices extends InvoicesEvent {
  final String token;
  final String companyId;
  const LoadInvoices({required this.token, required this.companyId});
  @override
  List<Object> get props => [token, companyId];
}

// Event to search for invoices
class SearchInvoices extends InvoicesEvent {
  final String query;
  final String token;
  final String companyId;
  const SearchInvoices({required this.query, required this.token, required this.companyId});
  @override
  List<Object> get props => [query, token, companyId];
}
