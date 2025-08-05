import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'add_product_event.dart';
part 'add_product_state.dart';

class AddProductBloc extends Bloc<AddProductEvent, AddProductState> {
  AddProductBloc() : super(AddProductInitial()) {
    on<AddProductSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    AddProductSubmitted event,
    Emitter<AddProductState> emit,
  ) async {
    emit(AddProductInProgress());
    try {
      // Simulate a network request
      await Future.delayed(const Duration(seconds: 2));

      // --- Simple Validation Logic ---
      if (event.productName.isEmpty) {
        throw Exception('Product Name cannot be empty.');
      }
      
      // In a real app, you would save the data to a database here.
      // For now, we'll just simulate success.
      print('Product "${event.productName}" added successfully!');

      emit(AddProductSuccess());
    } catch (e) {
      emit(AddProductFailure(error: e.toString()));
    }
  }
}