import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/cart_repository.dart';

class RemoveCartItemUseCase implements UseCase<void, RemoveCartItemParams> {
  final CartRepository repository;

  RemoveCartItemUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RemoveCartItemParams params) async {
    return await repository.removeFromCart(params.productId);
  }
}

class RemoveCartItemParams extends Equatable {
  final String productId;

  const RemoveCartItemParams({required this.productId});

  @override
  List<Object> get props => [productId];
} 