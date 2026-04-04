// lib/providers/meal/meal_log_provider.dart

import '../../models/meal/meal_log_model.dart';
import '../../services/meal/meal_log_service.dart';
import '../base/base_provider.dart';

class MealLogProvider extends BaseProvider {
  final _service = MealLogService();

  MealLog? _todayLog;
  MealLog? _selectedLog;
  DateTime _selectedDate = DateTime.now();

  MealLog? get todayLog => _todayLog;
  MealLog? get selectedLog => _selectedLog;
  DateTime get selectedDate => _selectedDate;

  bool get isToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  // returns today's log if selected date is today, else past log
  MealLog? get currentLog => isToday ? _todayLog : _selectedLog;

  Future<void> loadTodayLog() async {
    await execute(() async {
      _todayLog = await _service.getTodayLog();
    });
  }

  Future<void> selectDate(DateTime date) async {
    _selectedDate = date;
    notifyListeners();

    if (isToday) {
      if (_todayLog == null) await loadTodayLog();
    } else {
      await _loadLogForDate(date);
    }
  }

  Future<void> _loadLogForDate(DateTime date) async {
    await execute(() async {
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      _selectedLog = await _service.getLogByDate(dateStr);
    });
  }

  Future<bool> addMealItem({
    required String slotId,
    required String foodId,
    required double quantity,
    required String unit,
  }) async {
    final result = await execute(() async {
      await _service.addMealItem(
        slotId: slotId,
        foodId: foodId,
        quantity: quantity,
        unit: unit,
      );
      await loadTodayLog();
      return true; // ← add this
    });
    return result == true;
  }

  Future<bool> updateMealItem({
    required String itemId,
    required double quantity,
  }) async {
    final result = await execute(() async {
      await _service.updateMealItem(itemId: itemId, quantity: quantity);
      await loadTodayLog();
    });
    return result != null;
  }

  Future<bool> deleteMealItem(String itemId) async {
    final result = await execute(() async {
      await _service.deleteMealItem(itemId);
      await loadTodayLog();
    });
    return result != null;
  }

  Future<bool> logWater(int amountMl) async {
    final result = await executeSilent(() async {
      await _service.logWater(amountMl);
      _todayLog = await _service.getTodayLog();
    });
    notifyListeners();
    return result != null;
  }

  Future<bool> updateWaterGoal(int waterGoalMl) async {
    final result = await execute(() async {
      await _service.updateWaterGoal(waterGoalMl);
      await loadTodayLog();
    });
    return result != null;
  }

  Future<bool> addCustomSlot(String slotName) async {
    final result = await execute(() async {
      await _service.addCustomSlot(slotName);
      await loadTodayLog();
    });
    return result != null;
  }

  List<MealHistoryItem> _history = [];
  List<MealHistoryItem> get history => _history;

  List<MealHistoryItem> get notSentLogs =>
      _history.where((l) => l.notSent).toList();
  List<MealHistoryItem> get pendingLogs =>
      _history.where((l) => l.isPending).toList();
  List<MealHistoryItem> get reviewedLogs =>
      _history.where((l) => l.isReviewed).toList();

  Future<void> loadHistory() async {
    await execute(() async {
      _history = await _service.getMealHistory();
    });
  }

  Future<bool> sendLogForReview(String date) async {
    final result = await execute(() async {
      await _service.sendLogForReview(date);
      await loadHistory();
      _selectedLog = await _service.getLogByDate(date);
      return true; // ← explicitly return true
    });
    return result == true; // check for true not just not null
  }
}
