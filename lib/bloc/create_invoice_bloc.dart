import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;

part 'create_invoice_event.dart';
part 'create_invoice_state.dart';

class CreateInvoiceBloc extends Bloc<CreateInvoiceEvent, CreateInvoiceState> {
  CreateInvoiceBloc() : super(CreateInvoiceInitial()) {
    on<SubmitInvoice>(_onSubmitInvoice);
  }

  Future<void> _onSubmitInvoice(
    SubmitInvoice event,
    Emitter<CreateInvoiceState> emit,
  ) async {
    // Emit the in-progress state to show a loading indicator in the UI
    emit(CreateInvoiceInProgress());
    try {
      // Define the API endpoint
      final url = Uri.parse('http://196.190.251.122:8082/api/v2/invoice/draft');

      // Make the authenticated POST request
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}', // Add the token to the header
        },
        body: json.encode(event.invoiceData),
      );

      // Check the server's response code
      if (response.statusCode == 200 || response.statusCode == 201) {
        // If successful, emit the success state
        emit(CreateInvoiceSuccess());
      } else {
        // If the server returns an error, handle it
        String errorMessage;
        try {
          // Try to parse the error response as JSON
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? 'Failed to create invoice.';
        } catch (e) {
          // If the error response is not JSON, use the raw text from the body
          errorMessage = response.body;
        }
        emit(CreateInvoiceFailure(error: errorMessage));
      }
    } catch (e) {
      // Handle network errors or other exceptions
      emit(CreateInvoiceFailure(error: 'A network error occurred: $e'));
    }
  }
}
