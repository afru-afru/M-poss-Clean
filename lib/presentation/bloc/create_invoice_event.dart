part of 'create_invoice_bloc.dart';

abstract class CreateInvoiceEvent extends Equatable {
  const CreateInvoiceEvent();

  @override
  List<Object> get props => [];
}

// Event triggered when the "Add Invoice" button is pressed
class SubmitInvoice extends CreateInvoiceEvent {
  final Map<String, dynamic> invoiceData;
  final String token; // Token is now required

  const SubmitInvoice({required this.invoiceData, required this.token});

  @override
  List<Object> get props => [invoiceData, token];
}
