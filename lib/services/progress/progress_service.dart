import 'package:dio/dio.dart';
import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import '../../models/progress/progress_model.dart';

class ProgressService {
  final Dio _dio = ApiClient().dio;

  // GET /api/progress/stats
  Future<OverallStats> getOverallStats() async {
    final response = await _dio.get(ApiEndpoints.progressStats);
    return OverallStats.fromJson(response.data['data']);
  }

  // GET /api/progress/streak
  Future<Streak> getStreak() async {
    final response = await _dio.get(ApiEndpoints.progressStreak);
    return Streak.fromJson(response.data['data']);
  }

  // GET /api/progress/weekly
  Future<List<WeeklyDay>> getWeeklyStats() async {
    final response = await _dio.get(ApiEndpoints.progressWeekly);
    final List data = response.data['data'];
    return data.map((d) => WeeklyDay.fromJson(d)).toList();
  }

  // GET /api/progress/monthly
  Future<List<MonthlyData>> getMonthlyStats() async {
    final response = await _dio.get(ApiEndpoints.progressMonthly);
    final List data = response.data['data'];
    return data.map((d) => MonthlyData.fromJson(d)).toList();
  }

  // GET /api/progress/muscles
  Future<List<MuscleDistribution>> getMuscleDistribution() async {
    final response = await _dio.get(ApiEndpoints.progressMuscles);
    final List data = response.data['data'];
    return data.map((d) => MuscleDistribution.fromJson(d)).toList();
  }

  // GET /api/progress/personal-bests
  Future<List<PersonalBest>> getPersonalBests() async {
    final response = await _dio.get(ApiEndpoints.progressPersonalBests);
    final List data = response.data['data'];
    return data.map((d) => PersonalBest.fromJson(d)).toList();
  }

  // GET /api/progress/exercise/:id
  Future<ExerciseProgressData> getExerciseProgress(String exerciseId) async {
    final response = await _dio.get(ApiEndpoints.exerciseProgress(exerciseId));
    return ExerciseProgressData.fromJson(response.data['data']);
  }

  // GET /api/progress/history
  Future<Map<String, dynamic>> getWorkoutHistory({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.progressHistory,
      queryParameters: {'page': page, 'limit': limit},
    );

    final data = response.data['data'];
    return {
      'workouts': (data['workouts'] as List)
          .map((w) => WorkoutHistoryItem.fromJson(w))
          .toList(),
      'pagination': data['pagination'],
    };
  }
}
