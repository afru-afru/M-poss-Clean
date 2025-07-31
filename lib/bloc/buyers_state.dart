part of 'buyers_bloc.dart';

abstract class BuyersState extends Equatable {
  const BuyersState();
  @override
  List<Object> get props => [];
}

class BuyersInitial extends BuyersState {}
class BuyersLoading extends BuyersState {}

class BuyersLoaded extends BuyersState {
  final List<dynamic> buyers;
  const BuyersLoaded({required this.buyers});
  @override
  List<Object> get props => [buyers];
}

class BuyersError extends BuyersState {
  final String message;
  const BuyersError({required this.message});
  @override
  List<Object> get props => [message];
}
