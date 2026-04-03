// lib/services/meal/food_service.dart

import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import '../../models/meal/food_model.dart';

class FoodService {
  final _dio = ApiClient().dio;

  // Search foods — system + user's custom
  Future<List<Food>> searchFoods({
    String? search,
    String? category,
    bool? isNepali,
  }) async {
    final params = <String, dynamic>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (category != null) params['category'] = category;
    if (isNepali != null) params['isNepali'] = isNepali;

    final res = await _dio.get(ApiEndpoints.mealFoods, queryParameters: params);
    return (res.data['data'] as List).map((e) => Food.fromJson(e)).toList();
  }

  // Last 8 distinct foods user logged — for quick add chips
  Future<List<Food>> getRecentFoods() async {
    final res = await _dio.get(ApiEndpoints.mealFoodsRecent);
    return (res.data['data'] as List).map((e) => Food.fromJson(e)).toList();
  }

  // User's own custom foods
  Future<List<Food>> getCustomFoods() async {
    final res = await _dio.get(ApiEndpoints.mealFoodsCustom);
    return (res.data['data'] as List).map((e) => Food.fromJson(e)).toList();
  }

  // Create a custom food
  Future<Food> createCustomFood({
    required String name,
    required String category,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    double? fiber,
    required double servingSize,
    required String servingUnit,
    String? servingLabel,
  }) async {
    final res = await _dio.post(
      ApiEndpoints.mealFoodsCustom,
      data: {
        'name': name,
        'category': category,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        if (fiber != null) 'fiber': fiber,
        'servingSize': servingSize,
        'servingUnit': servingUnit,
        if (servingLabel != null) 'servingLabel': servingLabel,
      },
    );
    return Food.fromJson(res.data['data']);
  }

  // Delete a custom food
  Future<void> deleteCustomFood(String foodId) async {
    await _dio.delete(ApiEndpoints.mealFoodsCustomById(foodId));
  }
}
