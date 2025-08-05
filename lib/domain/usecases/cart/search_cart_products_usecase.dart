import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/product.dart';
import '../../repositories/cart_repository.dart';

class SearchCartProductsParams {
  final String query;
  final String token;
  final String companyId;

  SearchCartProductsParams({
    required this.query,
    required this.token,
    required this.companyId,
  });
}

class SearchCartProductsUseCase implements UseCase<List<Product>, SearchCartProductsParams> {
  final CartRepository repository;

  SearchCartProductsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(SearchCartProductsParams params) async {
    return await repository.searchProducts(params.query, params.token, params.companyId);
  }
} 