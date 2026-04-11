// lib/providers/meal/nutrition_goal_provider.dart

import '../../models/meal/nutrition_goal_model.dart';
import '../../services/meal/nutrition_goal_service.dart';
import '../base/base_provider.dart';

class NutritionGoalProvider extends BaseProvider {
  final _service = NutritionGoalService();

  NutritionGoal? _goal;

  NutritionGoal? get goal => _goal;

  Future<void> loadGoals() async {
    await execute(() async {
      _goal = await _service.getGoals();
    });
  }

  // pass only calories auto split by fitness goal
  // pass all four  manual mode
  Future<bool> updateGoals({
    required double calories,
    double? protein,
    double? carbs,
    double? fat,
  }) async {
    await execute(() async {
      _goal = await _service.updateGoals(
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
      );
    });
    // If execute caught an error it sets _error; no error means success.
    return !hasError;
  }
}
