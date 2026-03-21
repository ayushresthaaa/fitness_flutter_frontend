import 'package:dio/dio.dart';
import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import '../../models/ecommerce/product_model.dart';

class ProductService {
  final Dio _dio = ApiClient().dio;

  // GET /api/products — public, paginated, filterable
  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int limit = 10,
    String? search,
    String? categoryId,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.products,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        if (categoryId != null) 'categoryId': categoryId,
      },
    );

    final data = response.data['data'];
    return {
      'products': (data['products'] as List)
          .map((p) => Product.fromJson(p))
          .toList(),
      'pagination': data['pagination'],
    };
  }

  // GET /api/products/featured — public
  Future<List<Product>> getFeaturedProducts() async {
    final response = await _dio.get(ApiEndpoints.featuredProducts);
    return (response.data['data'] as List)
        .map((p) => Product.fromJson(p))
        .toList();
  }

  // GET /api/products/:id — public
  Future<Product> getProductById(String id) async {
    final response = await _dio.get(ApiEndpoints.productById(id));
    return Product.fromJson(response.data['data']);
  }

  // GET /api/categories — public, used for filter chips
  Future<List<ProductCategory>> getCategories() async {
    final response = await _dio.get(ApiEndpoints.categories);
    return (response.data['data'] as List)
        .map((c) => ProductCategory.fromJson(c))
        .toList();
  }
}