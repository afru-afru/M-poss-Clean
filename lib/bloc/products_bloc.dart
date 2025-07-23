// lib/bloc/products_bloc.dart

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'products_event.dart';
part 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  // A master list to hold all products after the initial load
  List<dynamic> _masterProductList = [];

  ProductsBloc() : super(ProductsInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<SearchProducts>(_onSearchProducts); // Add handler for the search event
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductsState> emit,
  ) async {
    emit(ProductsLoading());
    try {
      final String response = await rootBundle.loadString('assets/json/products.json');
      final List<dynamic> data = await json.decode(response);
      _masterProductList = data; // Store the full list
      // Initially, the filtered list is the same as the full list
      emit(ProductsLoaded(allProducts: _masterProductList, filteredProducts: _masterProductList));
    } catch (e) {
      emit(ProductsError(message: "Failed to load products: $e"));
    }
  }

  void _onSearchProducts(
    SearchProducts event,
    Emitter<ProductsState> emit,
  ) {
    final currentState = state;
    if (currentState is ProductsLoaded) {
      final query = event.query.toLowerCase();
      if (query.isEmpty) {
        // If query is empty, show all products
        emit(ProductsLoaded(allProducts: _masterProductList, filteredProducts: _masterProductList));
      } else {
        // Otherwise, filter the master list
        final filteredList = _masterProductList.where((product) {
          final productName = (product['name'] as String).toLowerCase();
          return productName.contains(query);
        }).toList();
        emit(ProductsLoaded(allProducts: _masterProductList, filteredProducts: filteredList));
      }
    }
  }
}