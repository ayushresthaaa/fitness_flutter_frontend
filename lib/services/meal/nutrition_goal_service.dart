// lib/services/meal/nutrition_goal_service.dart

import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import '../../models/meal/nutrition_goal_model.dart';

class NutritionGoalService {
  final _dio = ApiClient().dio;

  // Get goals  auto creates from fitness goal if none exist
  Future<NutritionGoal> getGoals() async {
    final res = await _dio.get(ApiEndpoints.mealGoal);
    return NutritionGoal.fromJson(res.data['data']);
  }

  // Mode 1  pass only calories auto split by fitness goal
  // Mode 2 pass all four      manual mode, use exactly as provided
  Future<NutritionGoal> updateGoals({
    required double calories,
    double? protein,
    double? carbs,
    double? fat,
  }) async {
    final res = await _dio.put(
      ApiEndpoints.mealGoal,
      data: {
        'calories': calories,
        if (protein != null) 'protein': protein,
        if (carbs != null) 'carbs': carbs,
        if (fat != null) 'fat': fat,
      },
    );
    return NutritionGoal.fromJson(res.data['data']);
  }
}
