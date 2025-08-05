import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  // Keep track of selected products separately from search results
  final Map<String, Map<String, dynamic>> _selectedProducts = {};
  
  CartBloc() : super(const CartLoaded(products: [])) {
    on<SearchCartProducts>(_onSearchCartProducts);
    on<AddCartItem>(_onAddCartItem);
    on<RemoveCartItem>(_onRemoveCartItem);
  }

  Future<void> _onSearchCartProducts(
    SearchCartProducts event,
    Emitter<CartState> emit,
  ) async {
    if (event.query.length < 2) {
      // When search query is too short, show only selected products
      final selectedProductsList = _selectedProducts.values.toList();
      emit(CartLoaded(products: selectedProductsList));
      return;
    }

    emit(CartLoading());
    try {
      final url = Uri.parse('http://196.190.251.122:8086/api/Products/search/invoice-items?searchTerm=${event.query}&companyId=${event.companyId}');
      
      debugPrint("CartBloc: Calling URL: $url");

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
      );

      if (response.statusCode == 200) {
        // THIS IS THE FIX: Decode the response as a Map
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        // Check if the response indicates success
        if (responseData['success'] == true && responseData['data'] is List) {
          // Extract the list of products from the 'data' key
          final List<dynamic> data = responseData['data'];
          
          final productsWithQuantity = data.map((product) {
            final p = Map<String, dynamic>.from(product);
            p['price'] = p['sellingPrice'] ?? 0.0;
            
            // Check if this product is already selected and preserve its quantity
            final productId = p['id'].toString();
            if (_selectedProducts.containsKey(productId)) {
              p['quantity'] = _selectedProducts[productId]!['quantity'];
            } else {
              p['quantity'] = 0;
            }
            
            return p;
          }).toList();
          
          // Add any selected products that are not in the current search results
          for (final selectedProduct in _selectedProducts.values) {
            final productId = selectedProduct['id'].toString();
            final isInSearchResults = productsWithQuantity.any((p) => p['id'].toString() == productId);
            
            if (!isInSearchResults) {
              productsWithQuantity.add(selectedProduct);
            }
          }
          
          emit(CartLoaded(products: productsWithQuantity));
        } else {
          // Handle cases where "success" is false or "data" is not a list
          throw Exception(responseData['message'] ?? 'Invalid response structure from API');
        }
      } else {
        debugPrint("CartBloc: API Error ${response.statusCode} - ${response.body}");
        throw Exception('Failed to load products from API. Status: ${response.statusCode}');
      }
    } catch (e) {
      emit(CartError(message: e.toString()));
    }
  }

  void _onAddCartItem(AddCartItem event, Emitter<CartState> emit) {
    final currentState = state;
    if (currentState is CartLoaded) {
      final updatedProducts = List<Map<String, dynamic>>.from(currentState.products);
      final productIndex = updatedProducts.indexWhere((p) => p['id'].toString() == event.productId);

      if (productIndex != -1) {
        final product = Map<String, dynamic>.from(updatedProducts[productIndex]);
        final newQuantity = (product['quantity'] as int) + 1;
        product['quantity'] = newQuantity;
        updatedProducts[productIndex] = product;
        
        // Update the selected products map
        _selectedProducts[event.productId] = product;
        
        emit(CartLoaded(products: updatedProducts));
      }
    }
  }

  void _onRemoveCartItem(RemoveCartItem event, Emitter<CartState> emit) {
    final currentState = state;
    if (currentState is CartLoaded) {
      final updatedProducts = List<Map<String, dynamic>>.from(currentState.products);
      final productIndex = updatedProducts.indexWhere((p) => p['id'].toString() == event.productId);

      if (productIndex != -1) {
        final product = Map<String, dynamic>.from(updatedProducts[productIndex]);
        if ((product['quantity'] as int) > 0) {
          final newQuantity = (product['quantity'] as int) - 1;
          product['quantity'] = newQuantity;
          updatedProducts[productIndex] = product;
          
          // Update the selected products map
          if (newQuantity > 0) {
            _selectedProducts[event.productId] = product;
          } else {
            // Remove from selected products if quantity becomes 0
            _selectedProducts.remove(event.productId);
          }
          
          emit(CartLoaded(products: updatedProducts));
        }
      }
    }
  }
}
