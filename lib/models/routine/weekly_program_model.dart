import './routine_model.dart';

enum DayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;

  static DayOfWeek fromString(String value) {
    return DayOfWeek.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => DayOfWeek.monday,
    );
  }

  String get displayName {
    return name[0].toUpperCase() + name.substring(1);
  }

  String get shortName => displayName.substring(0, 3); // Mon, Tue...
}

class WeeklyProgramDay {
  final String id;
  final String programId;
  final DayOfWeek dayOfWeek;
  final String? routineId;
  final bool isRestDay;
  final Routine? routine;
  final DateTime createdAt;
  final DateTime updatedAt;

  WeeklyProgramDay({
    required this.id,
    required this.programId,
    required this.dayOfWeek,
    this.routineId,
    required this.isRestDay,
    this.routine,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WeeklyProgramDay.fromJson(Map<String, dynamic> json) {
    return WeeklyProgramDay(
      id: json['id'],
      programId: json['programId'],
      dayOfWeek: DayOfWeek.fromString(json['dayOfWeek']),
      routineId: json['routineId'],
      isRestDay: json['isRestDay'] ?? true,
      routine: json['routine'] != null
          ? Routine.fromJson(json['routine'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class WeeklyProgram {
  final String id;
  final int userId;
  final String name;
  final bool isActive;
  final List<WeeklyProgramDay> days;
  final DateTime createdAt;
  final DateTime updatedAt;

  WeeklyProgram({
    required this.id,
    required this.userId,
    required this.name,
    required this.isActive,
    required this.days,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WeeklyProgram.fromJson(Map<String, dynamic> json) {
    return WeeklyProgram(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      isActive: json['isActive'] ?? true,
      days: (json['days'] as List? ?? [])
          .map((d) => WeeklyProgramDay.fromJson(d))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
