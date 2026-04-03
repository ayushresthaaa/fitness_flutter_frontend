// lib/providers/meal/food_provider.dart

import 'package:flutter/material.dart';
import '../../models/meal/food_model.dart';
import '../../services/meal/food_service.dart';
import '../base/base_provider.dart';

class FoodProvider extends BaseProvider {
  final _service = FoodService();

  List<Food> _searchResults = [];
  List<Food> _recentFoods = [];
  List<Food> _customFoods = [];
  bool _isSearching = false;

  List<Food> get searchResults => _searchResults;
  List<Food> get recentFoods => _recentFoods;
  List<Food> get customFoods => _customFoods;
  bool get isSearching => _isSearching;

  Future<void> loadRecentFoods() async {
    await execute(() async {
      _recentFoods = await _service.getRecentFoods();
    });
  }

  Future<void> loadCustomFoods() async {
    await execute(() async {
      _customFoods = await _service.getCustomFoods();
    });
  }

  Future<void> searchFoods({
    String? search,
    String? category,
    bool? isNepali,
  }) async {
    _isSearching = true;
    notifyListeners();

    await executeSilent(() async {
      _searchResults = await _service.searchFoods(
        search: search,
        category: category,
        isNepali: isNepali,
      );
    });

    _isSearching = false;
    notifyListeners();
  }

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }

  Future<bool> createCustomFood({
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
    final result = await execute(() async {
      final food = await _service.createCustomFood(
        name: name,
        category: category,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
        fiber: fiber,
        servingSize: servingSize,
        servingUnit: servingUnit,
        servingLabel: servingLabel,
      );
      _customFoods = [food, ..._customFoods];
    });
    return result != null;
  }

  Future<bool> deleteCustomFood(String foodId) async {
    final result = await execute(() async {
      await _service.deleteCustomFood(foodId);
      _customFoods = _customFoods.where((f) => f.id != foodId).toList();
    });
    return result != null;
  }
}
