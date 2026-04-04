// lib/services/trainer/trainer_request_service.dart

import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import '../../../../models/trainer/trainer_request_model.dart';

class TrainerRequestService {
  final _dio = ApiClient().dio;

  Future<Map<String, dynamic>> getMyTrainer() async {
    final res = await _dio.get(ApiEndpoints.myTrainer);
    return res.data['data'];
  }

  Future<TrainerChangeRequest> submitRequest({String? reason}) async {
    final res = await _dio.post(
      ApiEndpoints.submitTrainerRequest,
      data: {if (reason != null && reason.isNotEmpty) 'reason': reason},
    );
    return TrainerChangeRequest.fromJson(res.data['data']);
  }

  Future<List<TrainerChangeRequest>> getMyRequests() async {
    final res = await _dio.get(ApiEndpoints.myTrainerRequests);
    return (res.data['data'] as List)
        .map((e) => TrainerChangeRequest.fromJson(e))
        .toList();
  }
}
