import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/product_repository.dart';
import '../../entities/product.dart';

class GetProductsUseCase implements UseCase<List<Product>, GetProductsParams> {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(GetProductsParams params) async {
    return await repository.getProducts(params.token, params.companyId);
  }
}

class GetProductsParams extends Equatable {
  final String token;
  final String companyId;

  const GetProductsParams({
    required this.token,
    required this.companyId,
  });

  @override
  List<Object> get props => [token, companyId];
} 