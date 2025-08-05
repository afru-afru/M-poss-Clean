import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/remote/product_remote_data_source.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Product>>> searchProducts(String query, String token, String companyId) async {
    if (await networkInfo.isConnected) {
      try {
        final productModels = await remoteDataSource.searchProducts(query, token, companyId);
        return Right(productModels);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Product>> createProduct(Product product, String token, String companyId) async {
    if (await networkInfo.isConnected) {
      try {
        // Convert Product entity to ProductModel
        final productModel = ProductModel(
          id: product.id,
          name: product.name,
          description: product.description,
          price: product.price,
          stock: product.stock,
          category: product.category,
          image: product.image,
          barcode: product.barcode,
          createdAt: product.createdAt,
          updatedAt: product.updatedAt,
        );
        
        final createdProduct = await remoteDataSource.createProduct(productModel, token, companyId);
        return Right(createdProduct);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getProducts(String token, String companyId) async {
    if (await networkInfo.isConnected) {
      try {
        final products = await remoteDataSource.getProducts(token, companyId);
        return Right(products);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }
} 