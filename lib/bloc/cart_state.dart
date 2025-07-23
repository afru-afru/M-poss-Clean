part of 'cart_bloc.dart';

abstract class CartState extends Equatable {
  const CartState();
  @override
  List<Object> get props => [];
}

class CartInitial extends CartState {}
class CartLoading extends CartState {}

class CartLoaded extends CartState {
  // This list will hold all products with their current quantities
  final List<Map<String, dynamic>> products;

  const CartLoaded({this.products = const []});
  @override
  List<Object> get props => [products];
}

class CartError extends CartState {
  final String message;
  const CartError({required this.message});
  @override
  List<Object> get props => [message];
}