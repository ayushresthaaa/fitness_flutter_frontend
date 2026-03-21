import 'product_model.dart';

class CartItem {
  final String id;
  final String cartId;
  final String productId;
  final int quantity;
  final Product product;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartItem({
    required this.id,
    required this.cartId,
    required this.productId,
    required this.quantity,
    required this.product,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? '',
      cartId: json['cartId'] ?? '',
      productId: json['productId'] ?? '',
      quantity: json['quantity'] ?? 1,
      product: Product.fromJson(json['product']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cartId': cartId,
      'productId': productId,
      'quantity': quantity,
      'product': product.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class Cart {
  final String id;
  final int userId;
  final List<CartItem> items;
  final double total;
  final int itemCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Cart({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.itemCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'] ?? '',
      userId: json['userId'] ?? 0,
      items: (json['items'] as List? ?? [])
          .map((item) => CartItem.fromJson(item))
          .toList(),
      total: (json['total'] as num? ?? 0).toDouble(),
      itemCount: json['itemCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'itemCount': itemCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
