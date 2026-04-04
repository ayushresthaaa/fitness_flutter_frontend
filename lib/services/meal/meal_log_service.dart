// lib/services/meal/meal_log_service.dart

import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import '../../models/meal/meal_log_model.dart';

class MealLogService {
  final _dio = ApiClient().dio;

  // Get today's log  auto creates with 4 default slots if not exists
  Future<MealLog> getTodayLog() async {
    final res = await _dio.get(ApiEndpoints.mealLogToday);
    return MealLog.fromJson(res.data['data']);
  }

  // Get a past day's log — returns null if no log for that date
  Future<MealLog?> getLogByDate(String date) async {
    final res = await _dio.get(ApiEndpoints.mealLogByDate(date));
    if (res.data['data'] == null) return null;
    return MealLog.fromJson(res.data['data']);
  }

  // Add a custom slot to today's log
  Future<void> addCustomSlot(String slotName) async {
    await _dio.post(ApiEndpoints.mealLogSlots, data: {'slotName': slotName});
  }

  // Log a food item to a slot
  Future<MealItem> addMealItem({
    required String slotId,
    required String foodId,
    required double quantity,
    required String unit,
  }) async {
    final res = await _dio.post(
      ApiEndpoints.mealLogSlotItems(slotId),
      data: {'foodId': foodId, 'quantity': quantity, 'unit': unit},
    );
    return MealItem.fromJson(res.data['data']);
  }

  // Update quantity of a logged item  macros recomputed on backend
  Future<MealItem> updateMealItem({
    required String itemId,
    required double quantity,
  }) async {
    final res = await _dio.patch(
      ApiEndpoints.mealLogItemById(itemId),
      data: {'quantity': quantity},
    );
    return MealItem.fromJson(res.data['data']);
  }

  // Remove a food item from a slot
  Future<void> deleteMealItem(String itemId) async {
    await _dio.delete(ApiEndpoints.mealLogItemById(itemId));
  }

  // Log water — increments existing amount
  Future<Hydration> logWater(int amountMl) async {
    final res = await _dio.patch(
      ApiEndpoints.mealLogWater,
      data: {'amountMl': amountMl},
    );
    return Hydration.fromJson(res.data['data']);
  }

  // Update daily water goal
  Future<void> updateWaterGoal(int waterGoalMl) async {
    await _dio.patch(
      ApiEndpoints.mealLogWaterGoal,
      data: {'waterGoalMl': waterGoalMl},
    );
  }

  // Send a past log for trainer review
  Future<void> sendLogForReview(String date) async {
    await _dio.patch(ApiEndpoints.mealLogReview(date));
  }

  // Get last 30 days of meal history
  Future<List<MealHistoryItem>> getMealHistory() async {
    final res = await _dio.get(ApiEndpoints.mealHistory);
    return (res.data['data'] as List)
        .map((e) => MealHistoryItem.fromJson(e))
        .toList();
  }
}
