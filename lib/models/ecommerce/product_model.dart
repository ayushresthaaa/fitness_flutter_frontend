class ProductCategory {
  final String id;
  final String name;

  ProductCategory({required this.id, required this.name});

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class Product {
  final String id;
  final String name;
  final String? description;
  final double price;
  final int stock;
  final List<String> imageUrls;
  final bool isActive;
  final bool isFeatured;
  final String categoryId;
  final ProductCategory? category;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    required this.imageUrls,
    required this.isActive,
    required this.isFeatured,
    required this.categoryId,
    this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] ?? 0,
      imageUrls: (json['imageUrls'] as List? ?? [])
          .map((url) => url.toString())
          .toList(),
      isActive: json['isActive'] ?? true,
      isFeatured: json['isFeatured'] ?? false,
      categoryId: json['categoryId'] ?? '', // handle null
      category: json['category'] != null
          ? ProductCategory.fromJson(json['category'])
          : null,
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
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'imageUrls': imageUrls,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'categoryId': categoryId,
      'category': category?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
