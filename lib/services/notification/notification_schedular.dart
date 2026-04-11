import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../../models/reminder/reminders_model.dart';

final _plugin = FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  tz_data.initializeTimeZones();
  await _plugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );
}

Future<void> scheduleReminder(ReminderModel reminder) async {
  await cancelReminder(reminder.id);
  if (!reminder.enabled) return;

  const details = NotificationDetails(
    android: AndroidNotificationDetails(
      'reminders_channel',
      'Reminders',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  if (reminder.type == 'water') {
    await _plugin.periodicallyShowWithDuration(
      _notifId(reminder.id, 0),
      _title(reminder.type),
      _body(reminder.type),
      Duration(hours: reminder.intervalHours ?? 2),
      details,
    );
    return;
  }

  final days = reminder.days.isEmpty ? _allDays : reminder.days;
  for (int i = 0; i < days.length; i++) {
    final weekday = _dayToInt(days[i]);
    if (weekday == null) continue;

    await _plugin.zonedSchedule(
      _notifId(reminder.id, i),
      _title(reminder.type),
      _body(reminder.type),
      _nextWeekday(weekday, reminder.hour, reminder.minute),
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime, // add this
      androidScheduleMode: AndroidScheduleMode.inexact,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }
}

Future<void> cancelReminder(String id) async {
  for (int i = 0; i < 7; i++) {
    await _plugin.cancel(_notifId(id, i));
  }
}

Future<void> cancelAllReminders() async => await _plugin.cancelAll();

// ── helpers ────────────────────────────────────────────────

int _notifId(String id, int index) => (id.hashCode.abs() % 100000) * 10 + index;

tz.TZDateTime _nextWeekday(int weekday, int hour, int minute) {
  final now = tz.TZDateTime.now(tz.local);
  var t = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
  while (t.weekday != weekday || t.isBefore(now)) {
    t = t.add(const Duration(days: 1));
  }
  return t;
}

int? _dayToInt(String day) => {
  'monday': 1,
  'tuesday': 2,
  'wednesday': 3,
  'thursday': 4,
  'friday': 5,
  'saturday': 6,
  'sunday': 7,
}[day.toLowerCase()];

const _allDays = [
  'monday',
  'tuesday',
  'wednesday',
  'thursday',
  'friday',
  'saturday',
  'sunday',
];

String _title(String type) => switch (type) {
  'workout' => 'Time to train!',
  'water' => 'Drink water!',
  'breakfast' => 'Breakfast time',
  'lunch' => 'Lunch time',
  'dinner' => 'Dinner time',
  'snack' => 'Snack time',
  _ => 'Reminder',
};

String _body(String type) => switch (type) {
  'workout' => 'Your workout is scheduled for today.',
  'water' => 'Stay hydrated!',
  'breakfast' => 'Start your day with a good meal.',
  'lunch' => 'Time for your midday meal.',
  'dinner' => 'Time for dinner.',
  'snack' => 'Grab a healthy snack.',
  _ => '',
};
