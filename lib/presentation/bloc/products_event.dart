// lib/bloc/products_event.dart

part of 'products_bloc.dart';

abstract class ProductsEvent extends Equatable {
  const ProductsEvent();
  @override
  List<Object> get props => [];
}

class LoadProducts extends ProductsEvent {}

// NEW: Event to trigger a search
class SearchProducts extends ProductsEvent {
  final String query;

  const SearchProducts({required this.query});

  @override
  List<Object> get props => [query];
}