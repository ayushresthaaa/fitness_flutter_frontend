import 'package:dio/dio.dart';
import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';

class ForgotPasswordService {
  final Dio _dio = ApiClient().dio;

  // POST /api/auth/forgot-password
  Future<void> requestOtp(String email) async {
    await _dio.post(ApiEndpoints.forgotPassword, data: {'email': email});
  }

  // POST /api/auth/verify-otp
  Future<String> verifyOtp(String email, String otp) async {
    final response = await _dio.post(
      ApiEndpoints.verifyOtp,
      data: {'email': email, 'otp': otp},
    );
    return response.data['data']['resetToken'] as String;
  }

  // POST /api/auth/reset-password
  Future<void> resetPassword(String resetToken, String newPassword) async {
    await _dio.post(
      ApiEndpoints.resetPassword,
      data: {'resetToken': resetToken, 'newPassword': newPassword},
    );
  }
}
