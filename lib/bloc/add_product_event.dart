

part of 'add_product_bloc.dart';

abstract class AddProductEvent extends Equatable {
  const AddProductEvent();

  @override
  List<Object> get props => [];
}

// Event to trigger when the "Add Product" button is pressed
class AddProductSubmitted extends AddProductEvent {
  // In a real app, you would pass all the form data here
  final String productName;

  const AddProductSubmitted({required this.productName});

  @override
  List<Object> get props => [productName];
}