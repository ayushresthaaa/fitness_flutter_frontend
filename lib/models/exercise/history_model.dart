import 'exercise_model.dart';

class WorkoutHistory {
  final String id;
  final int userId;
  final String? title;
  final String? notes;
  final DateTime startTime;
  final DateTime? endTime;
  final int? durationMin;
  final int totalVolume;
  final List<String> musclesWorked;
  final List<WorkoutHistoryExercise> exercises;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkoutHistory({
    required this.id,
    required this.userId,
    this.title,
    this.notes,
    required this.startTime,
    this.endTime,
    this.durationMin,
    required this.totalVolume,
    required this.musclesWorked,
    required this.exercises,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WorkoutHistory.fromJson(Map<String, dynamic> json) {
    return WorkoutHistory(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      notes: json['notes'],
      startTime: DateTime.parse(json['startTime']).toLocal(),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime']).toLocal()
          : null,
      durationMin: json['durationMin'],
      totalVolume: json['totalVolume'] ?? 0,
      musclesWorked: List<String>.from(json['musclesWorked'] ?? []),
      exercises: (json['exercises'] as List? ?? [])
          .map((e) => WorkoutHistoryExercise.fromJson(e))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt']).toLocal(),
    );
  }
}

class WorkoutHistoryExercise {
  final String id;
  final String workoutId;
  final String exerciseId;
  final int? sets;
  final int? reps;
  final double? weightKg;
  final int? durationSec;
  final int order;
  final String? notes;
  final int? supersetGroup;
  final WorkoutHistoryExerciseInfo? exercise;
  final List<WorkoutHistorySet> workoutSets;

  WorkoutHistoryExercise({
    required this.id,
    required this.workoutId,
    required this.exerciseId,
    this.sets,
    this.reps,
    this.weightKg,
    this.durationSec,
    required this.order,
    this.notes,
    this.supersetGroup,
    this.exercise,
    required this.workoutSets,
  });

  factory WorkoutHistoryExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutHistoryExercise(
      id: json['id'],
      workoutId: json['workoutId'],
      exerciseId: json['exerciseId'],
      sets: json['sets'],
      reps: json['reps'],
      weightKg: json['weightKg']?.toDouble(),
      durationSec: json['durationSec'],
      order: json['order'] ?? 0,
      notes: json['notes'],
      supersetGroup: json['supersetGroup'],
      exercise: json['exercise'] != null
          ? WorkoutHistoryExerciseInfo.fromJson(json['exercise'])
          : null,
      workoutSets: (json['workoutSets'] as List? ?? [])
          .map((s) => WorkoutHistorySet.fromJson(s))
          .toList(),
    );
  }
}

// Lighter exercise info — only what history needs
class WorkoutHistoryExerciseInfo {
  final String id;
  final String name;
  final String category;
  final List<String> primaryMuscles;

  WorkoutHistoryExerciseInfo({
    required this.id,
    required this.name,
    required this.category,
    required this.primaryMuscles,
  });

  factory WorkoutHistoryExerciseInfo.fromJson(Map<String, dynamic> json) {
    return WorkoutHistoryExerciseInfo(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      primaryMuscles: List<String>.from(json['primaryMuscles'] ?? []),
    );
  }

  bool get isCardio => category == 'cardio';
}

class WorkoutHistorySet {
  final String id;
  final String workoutExerciseId;
  final int setNumber;
  final double? weightKg;
  final int? reps;
  final int? durationSec;
  final double? distanceMeters;
  final int? rpe;
  final bool isWarmup;
  final bool isPR;
  final bool isCompleted;

  WorkoutHistorySet({
    required this.id,
    required this.workoutExerciseId,
    required this.setNumber,
    this.weightKg,
    this.reps,
    this.durationSec,
    this.distanceMeters,
    this.rpe,
    required this.isWarmup,
    required this.isPR,
    required this.isCompleted,
  });

  factory WorkoutHistorySet.fromJson(Map<String, dynamic> json) {
    return WorkoutHistorySet(
      id: json['id'],
      workoutExerciseId: json['workoutExerciseId'],
      setNumber: json['setNumber'],
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      reps: json['reps'],
      durationSec: json['durationSec'],
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble(),
      rpe: json['rpe'],
      isWarmup: json['isWarmup'] ?? false,
      isPR: json['isPR'] ?? false,
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

class MonthlyStats {
  final String month;
  final int workoutCount;
  final int totalVolumeKg;
  final int totalDurationMin;

  MonthlyStats({
    required this.month,
    required this.workoutCount,
    required this.totalVolumeKg,
    required this.totalDurationMin,
  });

  factory MonthlyStats.fromJson(Map<String, dynamic> json) {
    return MonthlyStats(
      month: json['month'],
      workoutCount: json['workoutCount'] ?? 0,
      totalVolumeKg: json['totalVolumeKg'] ?? 0,
      totalDurationMin: json['totalDurationMin'] ?? 0,
    );
  }

  // "2h 10m" format
  String get formattedDuration {
    final h = totalDurationMin ~/ 60;
    final m = totalDurationMin % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }
}

class StreakData {
  final int streak;
  final int longestStreak;

  StreakData({required this.streak, required this.longestStreak});

  factory StreakData.fromJson(Map<String, dynamic> json) {
    return StreakData(
      streak: json['streak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
    );
  }
}
