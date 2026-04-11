import 'package:flutter/material.dart';
import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
// import '../../../providers/meal/meal_log_provider.dart';

class HomeProvider extends ChangeNotifier {
  final _dio = ApiClient().dio;

  int _caloriesBurned = 0;
  bool _isLoading = false;

  int get caloriesBurned => _caloriesBurned;
  bool get isLoading => _isLoading;

  Future<void> loadTodaySummary() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _dio.get(ApiEndpoints.todayWorkoutSummary);
      print('today-summary response: ${res.data}');
      _caloriesBurned = res.data['data']['caloriesBurned'] ?? 0;
      print('caloriesBurned set to: $_caloriesBurned');
    } catch (e) {
      print('today-summary error: $e');
      _caloriesBurned = 0;
    }
    _isLoading = false;
    notifyListeners();
  }
}
