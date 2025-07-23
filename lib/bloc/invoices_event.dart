part of 'invoices_bloc.dart';

abstract class InvoicesEvent extends Equatable {
  const InvoicesEvent();
  @override
  List<Object> get props => [];
}

class LoadInvoices extends InvoicesEvent {}

class SearchInvoices extends InvoicesEvent {
  final String query;
  const SearchInvoices({required this.query});
  @override
  List<Object> get props => [query];
}