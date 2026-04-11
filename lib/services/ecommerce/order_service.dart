import 'package:dio/dio.dart';
import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import '../../models/ecommerce/order_model.dart';

class OrderService {
  final Dio _dio = ApiClient().dio;

  // POST /api/orders — place order from cart
  Future<Order> placeOrder({
    required String shippingName,
    required String shippingPhone,
    required String shippingAddress,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.orders,
      data: {
        'shippingName': shippingName,
        'shippingPhone': shippingPhone,
        'shippingAddress': shippingAddress,
      },
    );
    return Order.fromJson(response.data['data']);
  }

  // GET /api/orders — get own order history
  Future<Map<String, dynamic>> getOrders({int page = 1, int limit = 10}) async {
    final response = await _dio.get(
      ApiEndpoints.orders,
      queryParameters: {'page': page, 'limit': limit},
    );

    final data = response.data['data'];
    return {
      'orders': (data['orders'] as List).map((o) => Order.fromJson(o)).toList(),
      'pagination': data['pagination'],
    };
  }

  // GET /api/orders/:id — single order detail
  Future<Order> getOrderById(String id) async {
    final response = await _dio.get(ApiEndpoints.orderById(id));
    return Order.fromJson(response.data['data']);
  }

}
