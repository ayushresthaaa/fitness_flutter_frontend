import 'package:dio/dio.dart';
import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import '../../models/achievement/achievement_model.dart';

class AchievementService {
  final Dio _dio = ApiClient().dio;

  // GET /api/achievements
  Future<AchievementsSummary> getAchievements() async {
    final response = await _dio.get(ApiEndpoints.achievements);
    return AchievementsSummary.fromJson(response.data['data']);
  }

  // POST /api/achievements/check
  Future<CheckAchievementsResult> checkAchievements() async {
    final response = await _dio.post(ApiEndpoints.checkAchievements);
    return CheckAchievementsResult.fromJson(response.data['data']);
  }

  // POST /api/achievements (admin only)
  Future<Achievement> createAchievement({
    required String name,
    required String description,
    required String type,
    required int requirement,
    String? iconUrl,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.addAchievement,
      data: {
        'name': name,
        'description': description,
        'type': type,
        'requirement': requirement,
        if (iconUrl != null) 'iconUrl': iconUrl,
      },
    );
    return Achievement.fromJson(response.data['data']);
  }
}
