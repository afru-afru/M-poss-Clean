import '../../domain/entities/cart_item.dart';
import '../../domain/entities/product.dart';
import 'product_model.dart';

class CartItemModel extends CartItem {
  const CartItemModel({
    required Product product,
    required int quantity,
  }) : super(product: product, quantity: quantity);

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      product: ProductModel.fromJson(json['product']),
      quantity: json['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': (product as ProductModel).toJson(),
      'quantity': quantity,
    };
  }

  CartItemModel copyWith({
    Product? product,
    int? quantity,
  }) {
    return CartItemModel(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
} 