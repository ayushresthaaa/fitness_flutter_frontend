// import 'dart:convert';
import '../../models/reminder/reminders_model.dart';
import '../../services/reminder/reminder_service.dart';
import '../../storage/local_storage.dart';
import '../base/base_provider.dart';

class ReminderProvider extends BaseProvider {
  final ReminderService _service = ReminderService();
  final LocalStorageService _storage = LocalStorageService();

  static const _key = 'cached_reminders';

  List<ReminderModel> _reminders = [];
  List<ReminderModel> get reminders => _reminders;

  ReminderModel? getByType(String type) {
    try {
      return _reminders.firstWhere((r) => r.type == type);
    } catch (_) {
      return null;
    }
  }

  // saves current list to local storage
  Future<void> _saveLocally() async {
    await _storage.setJsonList(
      _key,
      _reminders.map((r) => r.toJson()).toList(),
    );
  }

  // Fetch load cache first, then sync backend
  Future<void> fetchReminders() async {
    // load local cache instantly so screen isn't blank
    final cached = await _storage.getJsonList(_key);
    if (cached.isNotEmpty) {
      _reminders = cached.map((e) => ReminderModel.fromJson(e)).toList();
      notifyListeners();
    }

    // then hit backend and refresh
    final result = await execute(() => _service.getReminders());
    if (result != null) {
      _reminders = result;
      await _saveLocally();
      notifyListeners();
    }
  }

  Future<void> upsertReminder({
    required String type,
    required int hour,
    required int minute,
    List<String> days = const [],
    int? intervalHours,
    bool enabled = true,
  }) async {
    final result = await execute(
      () => _service.upsertReminder(
        type: type,
        hour: hour,
        minute: minute,
        days: days,
        intervalHours: intervalHours,
        enabled: enabled,
      ),
    );

    if (result != null) {
      final index = _reminders.indexWhere((r) => r.type == result.type);
      if (index != -1) {
        _reminders[index] = result;
      } else {
        _reminders.add(result);
      }
      await _saveLocally();
      notifyListeners();
    }
  }

  Future<void> toggleReminder(String id, bool enabled) async {
    final result = await execute(() => _service.toggleReminder(id, enabled));

    if (result != null) {
      final index = _reminders.indexWhere((r) => r.id == id);
      if (index != -1) {
        _reminders[index] = result;
        await _saveLocally();
        notifyListeners();
      }
    }
  }

  Future<void> deleteReminder(String id) async {
    await execute(() => _service.deleteReminder(id));
    _reminders.removeWhere((r) => r.id == id);
    await _saveLocally();
    notifyListeners();
  }

  Future<void> reset() async {
    _reminders = [];
    await _storage.remove(_key); // clear cache on logout
    clearError();
    notifyListeners();
  }
}
