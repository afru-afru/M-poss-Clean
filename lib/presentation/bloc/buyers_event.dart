part of 'buyers_bloc.dart';

abstract class BuyersEvent extends Equatable {
  const BuyersEvent();
  @override
  List<Object> get props => [];
}

class LoadBuyers extends BuyersEvent {
  final String token;
  const LoadBuyers({required this.token});
  @override
  List<Object> get props => [token];
}
