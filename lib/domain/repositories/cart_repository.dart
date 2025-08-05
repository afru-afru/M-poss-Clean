import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/cart_item.dart';
import '../entities/product.dart';

abstract class CartRepository {
  Future<Either<Failure, List<Product>>> searchProducts(String query, String token, String companyId);
  Future<Either<Failure, List<CartItem>>> getCartItems();
  Future<Either<Failure, void>> addToCart(String productId);
  Future<Either<Failure, void>> removeFromCart(String productId);
  Future<Either<Failure, void>> clearCart();
} 