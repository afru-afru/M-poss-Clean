part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object> get props => [];
}

class LoadCartProducts extends CartEvent {}

class AddCartItem extends CartEvent {
  final String productId;
  const AddCartItem(this.productId);
  @override
  List<Object> get props => [productId];
}

class RemoveCartItem extends CartEvent {
  final String productId;
  const RemoveCartItem(this.productId);
  @override
  List<Object> get props => [productId];
}