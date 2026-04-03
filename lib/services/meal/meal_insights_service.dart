// lib/services/meal/meal_insights_service.dart

import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import '../../models/meal/meal_insights_model.dart';

class MealInsightsService {
  final _dio = ApiClient().dio;

  Future<MealInsights> getInsights() async {
    final res = await _dio.get(ApiEndpoints.mealInsights);
    return MealInsights.fromJson(res.data['data']);
  }

  Future<List<MealHistoryItem>> getHistory() async {
    final res = await _dio.get(ApiEndpoints.mealHistory);
    return (res.data['data'] as List)
        .map((e) => MealHistoryItem.fromJson(e))
        .toList();
  }
}