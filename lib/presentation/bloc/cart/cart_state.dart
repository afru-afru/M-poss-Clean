part of 'cart_bloc.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<Product> products;
  final List<CartItem> cartItems;

  const CartLoaded({
    required this.products,
    required this.cartItems,
  });

  @override
  List<Object> get props => [products, cartItems];

  CartLoaded copyWith({
    List<Product>? products,
    List<CartItem>? cartItems,
  }) {
    return CartLoaded(
      products: products ?? this.products,
      cartItems: cartItems ?? this.cartItems,
    );
  }
}

class CartError extends CartState {
  final String message;

  const CartError({required this.message});

  @override
  List<Object> get props => [message];
} 