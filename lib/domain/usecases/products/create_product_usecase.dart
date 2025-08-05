import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/product_repository.dart';
import '../../entities/product.dart';

class CreateProductUseCase implements UseCase<Product, CreateProductParams> {
  final ProductRepository repository;

  CreateProductUseCase(this.repository);

  @override
  Future<Either<Failure, Product>> call(CreateProductParams params) async {
    return await repository.createProduct(params.product, params.token, params.companyId);
  }
}

class CreateProductParams extends Equatable {
  final Product product;
  final String token;
  final String companyId;

  const CreateProductParams({
    required this.product,
    required this.token,
    required this.companyId,
  });

  @override
  List<Object> get props => [product, token, companyId];
} 