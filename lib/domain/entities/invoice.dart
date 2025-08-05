import 'package:equatable/equatable.dart';

class Invoice extends Equatable {
  final String id;
  final String invoiceNumber;
  final String customerName;
  final String customerEmail;
  final List<InvoiceItem> items;
  final double subtotal;
  final double tax;
  final double total;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.customerName,
    required this.customerEmail,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    invoiceNumber,
    customerName,
    customerEmail,
    items,
    subtotal,
    tax,
    total,
    status,
    createdAt,
    updatedAt,
  ];
}

class InvoiceItem extends Equatable {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double total;

  const InvoiceItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  @override
  List<Object?> get props => [
    productId,
    productName,
    quantity,
    unitPrice,
    total,
  ];
} 