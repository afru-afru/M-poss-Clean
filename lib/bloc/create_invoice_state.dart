part of 'create_invoice_bloc.dart';

abstract class CreateInvoiceState extends Equatable {
  const CreateInvoiceState();

  @override
  List<Object> get props => [];
}

class CreateInvoiceInitial extends CreateInvoiceState {}
class CreateInvoiceInProgress extends CreateInvoiceState {}
class CreateInvoiceSuccess extends CreateInvoiceState {}
class CreateInvoiceFailure extends CreateInvoiceState {
  final String error;

  const CreateInvoiceFailure({required this.error});

  @override
  List<Object> get props => [error];
}