import 'package:dio/dio.dart';
import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';

class SubscriptionService {
  final Dio _dio = ApiClient().dio;

  // GET /api/payments/subscription/status
  Future<Map<String, dynamic>> getStatus() async {
    final response = await _dio.get(ApiEndpoints.subscriptionStatus);
    return response.data['data'];
  }

  // POST /api/payments/subscription/initiate
  Future<Map<String, dynamic>> initiate() async {
    final response = await _dio.post(ApiEndpoints.subscriptionInitiate);
    return response.data['data'];
  }

  // POST /api/payments/subscription/verify
  Future<Map<String, dynamic>> verify(String pidx) async {
    final response = await _dio.post(
      ApiEndpoints.subscriptionVerify,
      data: {'pidx': pidx},
    );
    return response.data['data'];
  }
}
