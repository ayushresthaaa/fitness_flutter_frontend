import 'product_model.dart';

// Matches the OrderStatus enum in Prisma schema
enum OrderStatus {
  pending,
  confirmed,
  shipped,
  delivered,
  cancelled;

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderStatus.pending,
    );
  }

  String toJson() => name;
}

class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final int quantity;
  final double priceAtTime; // snapshot of price when order was placed
  final Product? product;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.priceAtTime,
    this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      orderId: json['orderId'],
      productId: json['productId'],
      quantity: json['quantity'],
      priceAtTime: (json['priceAtTime'] as num).toDouble(),
      product: json['product'] != null
          ? Product.fromJson(json['product'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'productId': productId,
      'quantity': quantity,
      'priceAtTime': priceAtTime,
      'product': product?.toJson(),
    };
  }
}

class Order {
  final String id;
  final int userId;
  final OrderStatus status;
  final double totalAmount;
  final String shippingName;
  final String shippingPhone;
  final String shippingAddress;
  final List<OrderItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.status,
    required this.totalAmount,
    required this.shippingName,
    required this.shippingPhone,
    required this.shippingAddress,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['userId'],
      status: OrderStatus.fromString(json['status']),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      shippingName: json['shippingName'],
      shippingPhone: json['shippingPhone'],
      shippingAddress: json['shippingAddress'],
      items: (json['items'] as List? ?? [])
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'status': status.toJson(),
      'totalAmount': totalAmount,
      'shippingName': shippingName,
      'shippingPhone': shippingPhone,
      'shippingAddress': shippingAddress,
      'items': items.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
