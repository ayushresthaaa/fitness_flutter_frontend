import 'package:dio/dio.dart';
import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import '../../models/reminder/reminders_model.dart';
import '../notification/notification_schedular.dart';

class ReminderService {
  final Dio _dio = ApiClient().dio;

  Future<List<ReminderModel>> getReminders() async {
    final response = await _dio.get(ApiEndpoints.reminders);
    final List data = response.data['data'];
    final reminders = data.map((e) => ReminderModel.fromJson(e)).toList();
    await cancelAllReminders();
    for (final r in reminders) {
      await scheduleReminder(r);
    }
    return reminders;
  }

  Future<ReminderModel> upsertReminder({
    required String type,
    required int hour,
    required int minute,
    List<String> days = const [],
    int? intervalHours,
    bool enabled = true,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.reminders,
      data: {
        'type': type,
        'hour': hour,
        'minute': minute,
        'days': days,
        if (intervalHours != null) 'intervalHours': intervalHours,
        'enabled': enabled,
      },
    );
    final reminder = ReminderModel.fromJson(response.data['data']);
    await scheduleReminder(reminder);
    return reminder;
  }

  Future<ReminderModel> toggleReminder(String id, bool enabled) async {
    final response = await _dio.patch(
      ApiEndpoints.reminderToggle(id),
      data: {'enabled': enabled},
    );
    final reminder = ReminderModel.fromJson(response.data['data']);
    await scheduleReminder(reminder);
    return reminder;
  }

  Future<void> deleteReminder(String id) async {
    await _dio.delete(ApiEndpoints.reminderById(id));
    await cancelReminder(id);
  }
}
