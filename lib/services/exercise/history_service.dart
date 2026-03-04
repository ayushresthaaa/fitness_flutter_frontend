import 'package:dio/dio.dart';
import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import '../../models/exercise/history_model.dart';

class HistoryService {
  final Dio _dio = ApiClient().dio;

  // GET /api/history?month=2026-02
  Future<List<WorkoutHistory>> getHistoryByMonth(String month) async {
    final response = await _dio.get(
      ApiEndpoints.history,
      queryParameters: {'month': month},
    );
    return (response.data['data'] as List)
        .map((w) => WorkoutHistory.fromJson(w))
        .toList();
  }

  // GET /api/history/search?q=push
  Future<List<WorkoutHistory>> searchWorkouts(String q) async {
    final response = await _dio.get(
      ApiEndpoints.historySearch,
      queryParameters: {'q': q},
    );
    return (response.data['data'] as List)
        .map((w) => WorkoutHistory.fromJson(w))
        .toList();
  }

  // GET /api/history/streak
  Future<StreakData> getStreak() async {
    final response = await _dio.get(ApiEndpoints.historyStreak);
    return StreakData.fromJson(response.data['data']);
  }

  // GET /api/history/monthly-stats?month=2026-02
  Future<MonthlyStats> getMonthlyStats(String month) async {
    final response = await _dio.get(
      ApiEndpoints.historyMonthlyStats,
      queryParameters: {'month': month},
    );
    return MonthlyStats.fromJson(response.data['data']);
  }
}