import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/cart_item.dart';
import '../../../domain/usecases/cart/search_cart_products_usecase.dart';
import '../../../domain/usecases/cart/add_cart_item_usecase.dart';
import '../../../domain/usecases/cart/remove_cart_item_usecase.dart';
import '../../../domain/usecases/cart/get_cart_items_usecase.dart';
import '../../../core/usecases/usecase.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final SearchCartProductsUseCase searchCartProductsUseCase;
  final AddCartItemUseCase addCartItemUseCase;
  final RemoveCartItemUseCase removeCartItemUseCase;
  final GetCartItemsUseCase getCartItemsUseCase;

  // Keep track of selected products separately from search results
  final Map<String, int> _selectedProducts = {};

  CartBloc({
    required this.searchCartProductsUseCase,
    required this.addCartItemUseCase,
    required this.removeCartItemUseCase,
    required this.getCartItemsUseCase,
  }) : super(const CartLoaded(products: [], cartItems: [])) {
    on<SearchCartProducts>(_onSearchCartProducts);
    on<AddCartItem>(_onAddCartItem);
    on<RemoveCartItem>(_onRemoveCartItem);
    on<ClearCart>(_onClearCart);
    on<LoadCartItems>(_onLoadCartItems);
  }

  Future<void> _onSearchCartProducts(
    SearchCartProducts event,
    Emitter<CartState> emit,
  ) async {
    if (event.query.isEmpty || event.query.length < 2) {
      // When search query is empty or too short, show only selected products
      final cartItems = await _getCartItems();
      if (!emit.isDone) {
        emit(CartLoaded(products: [], cartItems: cartItems));
      }
      return;
    }

    emit(CartLoading());

    try {
      final result = await searchCartProductsUseCase(SearchCartProductsParams(
        query: event.query,
        token: event.token,
        companyId: event.companyId,
      ));

      await result.fold(
        (failure) async {
          debugPrint("CartBloc: Search failed: ${failure.toString()}");
          if (!emit.isDone) {
            emit(CartError(message: failure.toString()));
          }
        },
        (products) async {
          debugPrint("CartBloc: Found ${products.length} products");
          
          // Get current cart items to merge with search results
          final cartItems = await _getCartItems();
          
          // Create a map of product quantities from cart items
          final cartItemMap = {for (var item in cartItems) item.product.id: item.quantity};
          
          // Update the selected products map with current cart quantities
          for (final cartItem in cartItems) {
            _selectedProducts[cartItem.product.id] = cartItem.quantity;
          }
          
          // Merge search results with cart quantities
          final productsWithQuantity = products.map((product) {
            // Note: quantity is handled by cart items, not directly on products
            return product;
          }).toList();

          if (!emit.isDone) {
            emit(CartLoaded(products: productsWithQuantity, cartItems: cartItems));
          }
        },
      );
    } catch (e) {
      debugPrint("CartBloc: Search error: $e");
      if (!emit.isDone) {
        emit(CartError(message: e.toString()));
      }
    }
  }

  Future<void> _onAddCartItem(AddCartItem event, Emitter<CartState> emit) async {
    try {
      final result = await addCartItemUseCase(AddCartItemParams(productId: event.productId));
      
      await result.fold(
        (failure) async {
          debugPrint("CartBloc: Add item failed: ${failure.toString()}");
          if (!emit.isDone) {
            emit(CartError(message: failure.toString()));
          }
        },
        (_) async {
          // Update local tracking
          _selectedProducts[event.productId] = (_selectedProducts[event.productId] ?? 0) + 1;
          
          // Reload cart items
          final cartItems = await _getCartItems();
          
          // Update current state
          final currentState = state;
          if (currentState is CartLoaded && !emit.isDone) {
            emit(currentState.copyWith(cartItems: cartItems));
          } else if (!emit.isDone) {
            emit(CartLoaded(products: [], cartItems: cartItems));
          }
        },
      );
    } catch (e) {
      debugPrint("CartBloc: Add item error: $e");
      if (!emit.isDone) {
        emit(CartError(message: e.toString()));
      }
    }
  }

  Future<void> _onRemoveCartItem(RemoveCartItem event, Emitter<CartState> emit) async {
    try {
      final result = await removeCartItemUseCase(RemoveCartItemParams(productId: event.productId));
      
      await result.fold(
        (failure) async {
          debugPrint("CartBloc: Remove item failed: ${failure.toString()}");
          if (!emit.isDone) {
            emit(CartError(message: failure.toString()));
          }
        },
        (_) async {
          // Update local tracking
          final currentQuantity = _selectedProducts[event.productId] ?? 0;
          if (currentQuantity > 1) {
            _selectedProducts[event.productId] = currentQuantity - 1;
          } else {
            _selectedProducts.remove(event.productId);
          }
          
          // Reload cart items
          final cartItems = await _getCartItems();
          
          // Update current state
          final currentState = state;
          if (currentState is CartLoaded && !emit.isDone) {
            emit(currentState.copyWith(cartItems: cartItems));
          } else if (!emit.isDone) {
            emit(CartLoaded(products: [], cartItems: cartItems));
          }
        },
      );
    } catch (e) {
      debugPrint("CartBloc: Remove item error: $e");
      if (!emit.isDone) {
        emit(CartError(message: e.toString()));
      }
    }
  }

  Future<void> _onClearCart(ClearCart event, Emitter<CartState> emit) async {
    _selectedProducts.clear();
    final cartItems = await _getCartItems();
    if (!emit.isDone) {
      emit(CartLoaded(products: [], cartItems: cartItems));
    }
  }

  Future<void> _onLoadCartItems(LoadCartItems event, Emitter<CartState> emit) async {
    try {
      final result = await getCartItemsUseCase(NoParams());
      
      await result.fold(
        (failure) async {
          debugPrint("CartBloc: Load cart items failed: ${failure.toString()}");
          if (!emit.isDone) {
            emit(CartError(message: failure.toString()));
          }
        },
        (cartItems) async {
          // Update the selected products map
          for (final cartItem in cartItems) {
            _selectedProducts[cartItem.product.id] = cartItem.quantity;
          }
          
          final currentState = state;
          if (currentState is CartLoaded && !emit.isDone) {
            emit(currentState.copyWith(cartItems: cartItems));
          } else if (!emit.isDone) {
            emit(CartLoaded(products: [], cartItems: cartItems));
          }
        },
      );
    } catch (e) {
      debugPrint("CartBloc: Load cart items error: $e");
      if (!emit.isDone) {
        emit(CartError(message: e.toString()));
      }
    }
  }

  Future<List<CartItem>> _getCartItems() async {
    try {
      final result = await getCartItemsUseCase(NoParams());
      return result.fold(
        (failure) {
          debugPrint("CartBloc: Get cart items failed: ${failure.toString()}");
          return <CartItem>[];
        },
        (cartItems) => cartItems,
      );
    } catch (e) {
      debugPrint("CartBloc: Get cart items error: $e");
      return <CartItem>[];
    }
  }
} 