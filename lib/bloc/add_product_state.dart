// lib/bloc/add_product_state.dart

part of 'add_product_bloc.dart';

abstract class AddProductState extends Equatable {
  const AddProductState();

  @override
  List<Object> get props => [];
}

// The form is ready to be filled
class AddProductInitial extends AddProductState {}

// The form is being submitted
class AddProductInProgress extends AddProductState {}

// The product was added successfully
class AddProductSuccess extends AddProductState {}

// An error occurred during submission
class AddProductFailure extends AddProductState {
  final String error;

  const AddProductFailure({required this.error});

  @override
  List<Object> get props => [error];
}