//api interceptor will be used to add the jwt token to the header of every request that requires authentication
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiInterceptor extends Interceptor {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Content-Type'] = 'application/json';
    print(' ${options.method} ${options.path}');
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(' ${response.statusCode} ${response.requestOptions.path}');
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    print(' ${err.response?.statusCode} ${err.requestOptions.path}');
    if (err.response?.statusCode == 401) {
      await _storage.delete(key: 'jwt_token');
      print(' Token expired, user must login again');
    }
    return handler.next(err);
  }
}
