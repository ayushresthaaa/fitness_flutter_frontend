class ReminderModel {
  final String id;
  final int userId;
  final String type; // workout | water | breakfast | lunch | dinner | snack
  final int hour;
  final int minute;
  final List<String> days; // empty = daily
  final int? intervalHours; // water only
  final bool enabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReminderModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.hour,
    required this.minute,
    required this.days,
    this.intervalHours,
    required this.enabled,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'],
      userId: json['userId'],
      type: json['type'],
      hour: json['hour'],
      minute: json['minute'],
      days: List<String>.from(json['days'] ?? []),
      intervalHours: json['intervalHours'],
      enabled: json['enabled'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'hour': hour,
      'minute': minute,
      'days': days,
      if (intervalHours != null) 'intervalHours': intervalHours,
      'enabled': enabled,
    };
  }

  // helper for display "07:30 AM"
  String get formattedTime {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = minute.toString().padLeft(2, '0');
    final period = hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  // helper for days display  "Mon, Wed, Fri" or "Daily"
  String get formattedDays {
    if (days.isEmpty) return 'Daily';
    return days.map((d) => d.substring(0, 3).capitalize()).join(', ');
  }

  ReminderModel copyWith({
    String? type,
    int? hour,
    int? minute,
    List<String>? days,
    int? intervalHours,
    bool? enabled,
  }) {
    return ReminderModel(
      id: id,
      userId: userId,
      type: type ?? this.type,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      days: days ?? this.days,
      intervalHours: intervalHours ?? this.intervalHours,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension StringCapitalize on String {
  String capitalize() => isEmpty ? this : this[0].toUpperCase() + substring(1);
}
