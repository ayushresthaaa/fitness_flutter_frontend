import 'package:dio/dio.dart';
import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import '../../models/ecommerce/cart_model.dart';

class CartService {
  final Dio _dio = ApiClient().dio;

  // GET /api/cart
  Future<Cart?> getCart() async {
    final response = await _dio.get(ApiEndpoints.cart);
    final data = response.data['data'];
    print('getCart raw data: $data');
    print('getCart data id: ${data['id']}');

    if (data['id'] == null) return null;

    return Cart.fromJson(data);
  }

  // POST /api/cart — add item to cart
  Future<CartItem> addToCart({
    required String productId,
    int quantity = 1,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.cart,
      data: {'productId': productId, 'quantity': quantity},
    );
    return CartItem.fromJson(response.data['data']);
  }

  // PATCH /api/cart/:itemId — update quantity
  Future<CartItem> updateCartItem({
    required String itemId,
    required int quantity,
  }) async {
    final response = await _dio.patch(
      ApiEndpoints.cartItem(itemId),
      data: {'quantity': quantity},
    );
    return CartItem.fromJson(response.data['data']);
  }

  // DELETE /api/cart/:itemId — remove single item
  Future<void> removeCartItem(String itemId) async {
    await _dio.delete(ApiEndpoints.cartItem(itemId));
  }

  // DELETE /api/cart — clear entire cart
  Future<void> clearCart() async {
    await _dio.delete(ApiEndpoints.cart);
  }
}
