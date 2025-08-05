import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/local/cart_local_data_source.dart';
import '../datasources/remote/product_remote_data_source.dart';

import '../models/product_model.dart';

class CartRepositoryImpl implements CartRepository {
  final ProductRemoteDataSource remoteDataSource;
  final CartLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  // Cache for storing product details
  final Map<String, ProductModel> _productCache = {};

  CartRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Product>>> searchProducts(String query, String token, String companyId) async {
    if (await networkInfo.isConnected) {
      try {
        debugPrint("CartRepositoryImpl: Searching for query: $query");
        final products = await remoteDataSource.searchProducts(query, token, companyId);
        
        debugPrint("CartRepositoryImpl: Found ${products.length} products from remote");
        
        // Cache the products for later use
        for (final product in products) {
          _productCache[product.id] = product;
        }
        
        // Get cart items to merge with search results
        final cartItems = await localDataSource.getCartItems();
        debugPrint("CartRepositoryImpl: Found ${cartItems.length} cart items");
        
        final cartItemMap = {for (var item in cartItems) item.product.id: item.quantity};
        
        // Merge search results with cart quantities
        final productsWithQuantity = products.map((product) {
          // Note: quantity is handled by cart items, not directly on products
          return product;
        }).toList();
        
        debugPrint("CartRepositoryImpl: Returning ${productsWithQuantity.length} products");
        return Right(productsWithQuantity);
      } catch (e) {
        debugPrint("CartRepositoryImpl: Search error: $e");
        return Left(ServerFailure('Server error occurred: $e'));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<CartItem>>> getCartItems() async {
    try {
      final cartItems = await localDataSource.getCartItems();
      return Right(cartItems);
    } catch (e) {
      debugPrint("CartRepositoryImpl: Get cart items error: $e");
      return Left(CacheFailure('Failed to get cart items'));
    }
  }

  @override
  Future<Either<Failure, void>> addToCart(String productId) async {
    try {
      // Get product from cache - don't create placeholder for invalid IDs
      final product = _productCache[productId];
      if (product == null) {
        debugPrint("CartRepositoryImpl: Product $productId not found in cache - cannot add to cart");
        return Left(CacheFailure('Product not found - please search for products first'));
      }
      
      await localDataSource.addToCart(productId, product);
      return const Right(null);
    } catch (e) {
      debugPrint("CartRepositoryImpl: Add to cart error: $e");
      return Left(CacheFailure('Failed to add item to cart'));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromCart(String productId) async {
    try {
      await localDataSource.removeFromCart(productId);
      return const Right(null);
    } catch (e) {
      debugPrint("CartRepositoryImpl: Remove from cart error: $e");
      return Left(CacheFailure('Failed to remove item from cart'));
    }
  }

  @override
  Future<Either<Failure, void>> clearCart() async {
    try {
      await localDataSource.clearCart();
      return const Right(null);
    } catch (e) {
      debugPrint("CartRepositoryImpl: Clear cart error: $e");
      return Left(CacheFailure('Failed to clear cart'));
    }
  }
} 