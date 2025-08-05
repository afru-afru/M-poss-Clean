part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object> get props => [];
}

class SearchCartProducts extends CartEvent {
  final String query;
  final String token;
  final String companyId; // Add companyId
  const SearchCartProducts({required this.query, required this.token, required this.companyId});
  @override
  List<Object> get props => [query, token, companyId];
}

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
