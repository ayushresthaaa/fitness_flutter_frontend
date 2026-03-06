import 'package:dio/dio.dart';
import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import '../../models/progress/stats_model.dart';
import '../../models/progress/progress_model.dart';

class StatsService {
  final Dio _dio = ApiClient().dio;

  // GET /api/progress/overall-stats
  Future<OverallStats> getOverallStats() async {
    final response = await _dio.get(ApiEndpoints.overallStats);
    return OverallStats.fromJson(response.data['data']);
  }

  // GET /api/progress/weekly-stats
  Future<List<WeeklyDay>> getWeeklyStats() async {
    final response = await _dio.get(ApiEndpoints.weeklyStats);
    final data = response.data['data'] as List;
    return data.map((e) => WeeklyDay.fromJson(e)).toList();
  }

  // GET /api/progress/monthly-stats
  Future<List<MonthlyData>> getMonthlyStats() async {
    final response = await _dio.get(ApiEndpoints.monthlyStats);
    final data = response.data['data'] as List;
    return data.map((e) => MonthlyData.fromJson(e)).toList();
  }

  // GET /api/progress/muscle-distribution
  Future<List<MuscleDistribution>> getMuscleDistribution() async {
    final response = await _dio.get(ApiEndpoints.muscleDistribution);
    final data = response.data['data'] as List;
    return data.map((e) => MuscleDistribution.fromJson(e)).toList();
  }

  // GET /api/progress/streak
  Future<Map<String, int>> getStreak() async {
    final response = await _dio.get(ApiEndpoints.streak);
    final data = response.data['data'];
    return {
      'currentStreak': data['currentStreak'] ?? 0,
      'longestStreak': data['longestStreak'] ?? 0,
    };
  }

  // GET /api/progress/personal-bests
  Future<List<PersonalBest>> getPersonalBests() async {
    final response = await _dio.get(ApiEndpoints.personalBests);
    final data = response.data['data'] as List;
    return data.map((e) => PersonalBest.fromJson(e)).toList();
  }
}
