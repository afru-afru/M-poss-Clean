import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/cart_item.dart';
import '../../repositories/cart_repository.dart';

class GetCartItemsUseCase implements UseCase<List<CartItem>, NoParams> {
  final CartRepository repository;

  GetCartItemsUseCase(this.repository);

  @override
  Future<Either<Failure, List<CartItem>>> call(NoParams params) async {
    return await repository.getCartItems();
  }
} 