import 'package:dio/dio.dart';
import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';

class PaymentService {
  final Dio _dio = ApiClient().dio;

  // POST /api/payments/checkout — validates cart, stores shipping details, initiates Khalti
  Future<Map<String, dynamic>> initiateCheckout({
    required String shippingName,
    required String shippingPhone,
    required String shippingAddress,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.checkoutInitiate,
      data: {
        'shippingName': shippingName,
        'shippingPhone': shippingPhone,
        'shippingAddress': shippingAddress,
      },
    );
    return response.data['data'];
  }

  // POST /api/payments/checkout/verify — verifies payment and creates order atomically
  Future<Map<String, dynamic>> verifyCheckout({required String pidx}) async {
    final response = await _dio.post(
      ApiEndpoints.checkoutVerify,
      data: {'pidx': pidx},
    );
    return response.data['data'];
  }
}
