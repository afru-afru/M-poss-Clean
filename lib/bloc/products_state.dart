// lib/bloc/products_state.dart

part of 'products_bloc.dart';

abstract class ProductsState extends Equatable {
  const ProductsState();
  @override
  List<Object> get props => [];
}

class ProductsInitial extends ProductsState {}

class ProductsLoading extends ProductsState {}

// UPDATED: ProductsLoaded now holds both the master list and the displayed list
class ProductsLoaded extends ProductsState {
  final List<dynamic> allProducts;
  final List<dynamic> filteredProducts;

  const ProductsLoaded({required this.allProducts, required this.filteredProducts});

  @override
  List<Object> get props => [allProducts, filteredProducts];
}

class ProductsError extends ProductsState {
  final String message;
  const ProductsError({required this.message});
  @override
  List<Object> get props => [message];
}