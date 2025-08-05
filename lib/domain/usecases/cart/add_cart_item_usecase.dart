import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/cart_repository.dart';

class AddCartItemUseCase implements UseCase<void, AddCartItemParams> {
  final CartRepository repository;

  AddCartItemUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AddCartItemParams params) async {
    return await repository.addToCart(params.productId);
  }
}

class AddCartItemParams extends Equatable {
  final String productId;

  const AddCartItemParams({required this.productId});

  @override
  List<Object> get props => [productId];
} 