// lib/providers/meal/meal_insights_provider.dart

import '../../models/meal/meal_insights_model.dart';
import '../../services/meal/meal_insights_service.dart';
import '../base/base_provider.dart';

class MealInsightsProvider extends BaseProvider {
  final _service = MealInsightsService();

  MealInsights? _insights;
  List<MealHistoryItem> _history = [];

  MealInsights? get insights => _insights;
  List<MealHistoryItem> get history => _history;

  Future<void> loadInsights() async {
    await execute(() async {
      _insights = await _service.getInsights();
    });
  }

  Future<void> loadHistory() async {
    await execute(() async {
      _history = await _service.getHistory();
    });
  }
}
