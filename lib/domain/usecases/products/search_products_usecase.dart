import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/product.dart';
import '../../repositories/product_repository.dart';

class SearchProductsUseCase implements UseCase<List<Product>, SearchProductsParams> {
  final ProductRepository repository;

  SearchProductsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(SearchProductsParams params) async {
    return await repository.searchProducts(params.query, params.token, params.companyId);
  }
}

class SearchProductsParams extends Equatable {
  final String query;
  final String token;
  final String companyId;

  const SearchProductsParams({
    required this.query,
    required this.token,
    required this.companyId,
  });

  @override
  List<Object> get props => [query, token, companyId];
} 