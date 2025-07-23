import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartInitial()) {
    on<LoadCartProducts>(_onLoadCartProducts);
    on<AddCartItem>(_onAddCartItem);
    on<RemoveCartItem>(_onRemoveCartItem);
  }

  Future<void> _onLoadCartProducts(
    LoadCartProducts event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());
    try {
      final String response = await rootBundle.loadString('assets/json/products.json');
      final List<dynamic> data = await json.decode(response);
      
      final List<Map<String, dynamic>> typedData = data.cast<Map<String, dynamic>>();

final productsWithQuantity = typedData.map((product) {
  return {...product, 'quantity': 0};
}).toList();

      emit(CartLoaded(products: productsWithQuantity));
    } catch (e) {
      emit(CartError(message: "Failed to load products: $e"));
    }
  }

  void _onAddCartItem(AddCartItem event, Emitter<CartState> emit) {
    final currentState = state;
    if (currentState is CartLoaded) {
      // Create a new list to maintain immutability
      final List<Map<String, dynamic>> updatedProducts = List.from(currentState.products);
      // Find the index of the product to update
      final int productIndex = updatedProducts.indexWhere((p) => p['id'] == event.productId);

      if (productIndex != -1) {
        // Create a copy of the product and update its quantity
        final product = Map<String, dynamic>.from(updatedProducts[productIndex]);
        product['quantity'] = (product['quantity'] as int) + 1;
        updatedProducts[productIndex] = product;
        // Emit a new state with the updated list
        emit(CartLoaded(products: updatedProducts));
      }
    }
  }

  void _onRemoveCartItem(RemoveCartItem event, Emitter<CartState> emit) {
    final currentState = state;
    if (currentState is CartLoaded) {
      final List<Map<String, dynamic>> updatedProducts = List.from(currentState.products);
      final int productIndex = updatedProducts.indexWhere((p) => p['id'] == event.productId);

      if (productIndex != -1) {
        final product = Map<String, dynamic>.from(updatedProducts[productIndex]);
        if ((product['quantity'] as int) > 0) {
          product['quantity'] = (product['quantity'] as int) - 1;
          updatedProducts[productIndex] = product;
          emit(CartLoaded(products: updatedProducts));
        }
      }
    }
  }
}