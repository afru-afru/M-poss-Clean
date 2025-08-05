import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/product.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> searchProducts(String query, String token, String companyId);
  Future<Either<Failure, Product>> createProduct(Product product, String token, String companyId);
  Future<Either<Failure, List<Product>>> getProducts(String token, String companyId);
} 