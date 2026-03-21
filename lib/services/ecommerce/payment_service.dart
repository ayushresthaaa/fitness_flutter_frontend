import 'package:dio/dio.dart';
import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';

class PaymentService {
  final Dio _dio = ApiClient().dio;

  // POST /api/payments/initiate
  Future<Map<String, dynamic>> initiatePayment({
    required String orderId,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.initiatePayment,
      data: {'orderId': orderId},
    );
    return response.data['data'];
  }

  // POST /api/payments/verify
  Future<Map<String, dynamic>> verifyPayment({required String pidx}) async {
    final response = await _dio.post(
      ApiEndpoints.verifyPayment,
      data: {'pidx': pidx},
    );
    return response.data['data'];
  }
}
