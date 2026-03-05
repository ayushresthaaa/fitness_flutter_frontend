// Personal Best — used in PR list screen
class PersonalBest {
  final String exerciseId;
  final String exerciseName;
  final String category;
  final double maxWeightKg;
  final int? reps;
  final int? sets;
  final DateTime achievedAt;

  PersonalBest({
    required this.exerciseId,
    required this.exerciseName,
    required this.category,
    required this.maxWeightKg,
    this.reps,
    this.sets,
    required this.achievedAt,
  });

  factory PersonalBest.fromJson(Map<String, dynamic> json) {
    final exercise = json['exercise'] as Map<String, dynamic>;
    return PersonalBest(
      exerciseId: exercise['id'],
      exerciseName: exercise['name'],
      category: exercise['category'] ?? 'strength',
      maxWeightKg: (json['maxWeightKg'] as num).toDouble(),
      reps: json['reps'],
      sets: json['sets'],
      achievedAt: DateTime.parse(json['achievedAt']).toLocal(),
    );
  }

  bool get isCardio => category == 'cardio';
}

// Progress Set — individual set within a session
class ProgressSet {
  final String id;
  final int setNumber;
  final double? weightKg;
  final int? reps;
  final int? durationSec;
  final double? distanceMeters;
  final int? rpe;
  final bool isWarmup;
  final bool isCompleted;
  final bool isPR;

  ProgressSet({
    required this.id,
    required this.setNumber,
    this.weightKg,
    this.reps,
    this.durationSec,
    this.distanceMeters,
    this.rpe,
    required this.isWarmup,
    required this.isCompleted,
    required this.isPR,
  });

  factory ProgressSet.fromJson(Map<String, dynamic> json) {
    return ProgressSet(
      id: json['id'],
      setNumber: json['setNumber'] ?? 0,
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      reps: json['reps'],
      durationSec: json['durationSec'],
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble(),
      rpe: json['rpe'],
      isWarmup: json['isWarmup'] ?? false,
      isCompleted: json['isCompleted'] ?? false,
      isPR: json['isPR'] ?? false,
    );
  }
}

// Progress Point — one session entry in exercise history
class ProgressPoint {
  final DateTime date;
  final String workoutId;
  final String? workoutTitle;
  final List<ProgressSet> sets;
  final double? maxWeightKg;
  final double volume;

  ProgressPoint({
    required this.date,
    required this.workoutId,
    this.workoutTitle,
    required this.sets,
    this.maxWeightKg,
    required this.volume,
  });

  factory ProgressPoint.fromJson(Map<String, dynamic> json) {
    return ProgressPoint(
      date: DateTime.parse(json['date']).toLocal(),
      workoutId: json['workoutId'],
      workoutTitle: json['workoutTitle'],
      sets: (json['sets'] as List? ?? [])
          .map((s) => ProgressSet.fromJson(s))
          .toList(),
      maxWeightKg: (json['maxWeightKg'] as num?)?.toDouble(),
      volume: (json['volume'] as num?)?.toDouble() ?? 0,
    );
  }
}

// Exercise Progress Data — full data for exercise detail screen
class ExerciseProgressData {
  final String exerciseId;
  final String exerciseName;
  final String category;
  final List<String> primaryMuscles;
  final List<ProgressPoint> history;

  ExerciseProgressData({
    required this.exerciseId,
    required this.exerciseName,
    required this.category,
    required this.primaryMuscles,
    required this.history,
  });

  factory ExerciseProgressData.fromJson(Map<String, dynamic> json) {
    final ex = json['exercise'] as Map<String, dynamic>;
    return ExerciseProgressData(
      exerciseId: ex['id'],
      exerciseName: ex['name'],
      category: ex['category'] ?? 'strength',
      primaryMuscles: List<String>.from(ex['primaryMuscles'] ?? []),
      history: (json['history'] as List? ?? [])
          .map((p) => ProgressPoint.fromJson(p))
          .toList(),
    );
  }

  bool get isCardio => category == 'cardio';
}
