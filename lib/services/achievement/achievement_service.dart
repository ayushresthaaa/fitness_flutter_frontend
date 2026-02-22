import 'package:dio/dio.dart';
import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import '../../models/achievement/achievement_model.dart';

class AchievementService {
  final Dio _dio = ApiClient().dio;

  Future<AchievementsSummary> getAchievements() async {
    final response = await _dio.get(ApiEndpoints.achievements);
    return AchievementsSummary.fromJson(response.data['data']);
  }
}
