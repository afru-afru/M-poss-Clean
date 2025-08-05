import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/cart_item_model.dart';
import '../../models/product_model.dart';

abstract class CartLocalDataSource {
  Future<List<CartItemModel>> getCartItems();
  Future<void> addToCart(String productId, ProductModel product);
  Future<void> removeFromCart(String productId);
  Future<void> clearCart();
  Future<void> updateCartItemQuantity(String productId, int quantity);
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String CART_KEY = 'CART_ITEMS';

  CartLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<CartItemModel>> getCartItems() async {
    final cartJson = sharedPreferences.getString(CART_KEY);
    if (cartJson != null) {
      final List<dynamic> cartList = json.decode(cartJson);
      return cartList.map((item) => CartItemModel.fromJson(item)).toList();
    }
    return [];
  }

  @override
  Future<void> addToCart(String productId, ProductModel product) async {
    final cartItems = await getCartItems();
    final existingIndex = cartItems.indexWhere((item) => item.product.id == productId);
    
    if (existingIndex != -1) {
      // Update quantity
      final existingItem = cartItems[existingIndex];
      cartItems[existingIndex] = existingItem.copyWith(quantity: existingItem.quantity + 1);
    } else {
      // Add new item
      cartItems.add(CartItemModel(product: product, quantity: 1));
    }
    
    await _saveCartItems(cartItems);
  }

  @override
  Future<void> removeFromCart(String productId) async {
    final cartItems = await getCartItems();
    final existingIndex = cartItems.indexWhere((item) => item.product.id == productId);
    
    if (existingIndex != -1) {
      final existingItem = cartItems[existingIndex];
      if (existingItem.quantity > 1) {
        // Decrease quantity
        cartItems[existingIndex] = existingItem.copyWith(quantity: existingItem.quantity - 1);
      } else {
        // Remove item completely
        cartItems.removeAt(existingIndex);
      }
      await _saveCartItems(cartItems);
    }
  }

  @override
  Future<void> clearCart() async {
    await sharedPreferences.remove(CART_KEY);
  }

  @override
  Future<void> updateCartItemQuantity(String productId, int quantity) async {
    final cartItems = await getCartItems();
    final existingIndex = cartItems.indexWhere((item) => item.product.id == productId);
    
    if (existingIndex != -1) {
      if (quantity > 0) {
        final existingItem = cartItems[existingIndex];
        cartItems[existingIndex] = existingItem.copyWith(quantity: quantity);
      } else {
        cartItems.removeAt(existingIndex);
      }
      await _saveCartItems(cartItems);
    }
  }

  Future<void> _saveCartItems(List<CartItemModel> cartItems) async {
    final cartJson = json.encode(cartItems.map((item) => item.toJson()).toList());
    await sharedPreferences.setString(CART_KEY, cartJson);
  }
} 