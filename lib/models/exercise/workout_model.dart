import 'exercise_model.dart';

class Workout {
  final String id;
  final int userId;
  final String? title;
  final String? notes;
  final DateTime startTime;
  final DateTime? endTime;
  final List<WorkoutExercise> exercises;
  final DateTime createdAt;
  final DateTime updatedAt;

  Workout({
    required this.id,
    required this.userId,
    this.title,
    this.notes,
    required this.startTime,
    this.endTime,
    required this.exercises,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      notes: json['notes'],
      startTime: DateTime.parse(json['startTime']).toLocal(),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime']).toLocal()
          : null,
      exercises: (json['exercises'] as List? ?? [])
          .map((e) => WorkoutExercise.fromJson(e))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt']).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'notes': notes,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class WorkoutExercise {
  final String id;
  final String workoutId;
  final String exerciseId;
  final int? sets;
  final int? reps;
  final double? weightKg;
  final int? durationSec;
  final int order;
  final String? notes;
  final Exercise? exercise;
  final List<WorkoutSet> workoutSets; // ← ADDED
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkoutExercise({
    required this.id,
    required this.workoutId,
    required this.exerciseId,
    this.sets,
    this.reps,
    this.weightKg,
    this.durationSec,
    required this.order,
    this.notes,
    this.exercise,
    this.workoutSets = const [], // ← ADDED
    required this.createdAt,
    required this.updatedAt,
  });

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      id: json['id'],
      workoutId: json['workoutId'],
      exerciseId: json['exerciseId'],
      sets: json['sets'],
      reps: json['reps'],
      weightKg: json['weightKg']?.toDouble(),
      durationSec: json['durationSec'],
      order: json['order'] ?? 0,
      notes: json['notes'],
      exercise: json['exercise'] != null
          ? Exercise.fromJson(json['exercise'])
          : null,
      workoutSets:
          (json['workoutSets'] as List? ?? []) // ← ADDED
              .map((s) => WorkoutSet.fromJson(s))
              .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workoutId': workoutId,
      'exerciseId': exerciseId,
      'sets': sets,
      'reps': reps,
      'weightKg': weightKg,
      'durationSec': durationSec,
      'order': order,
      'notes': notes,
      'exercise': exercise?.toJson(),
      'workoutSets': workoutSets.map((s) => s.toJson()).toList(), // ← ADDED
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// ← ADDED
class WorkoutSet {
  final String id;
  final String workoutExerciseId;
  final int setNumber;
  final double? weightKg;
  final int? reps;
  final bool isCompleted;

  WorkoutSet({
    required this.id,
    required this.workoutExerciseId,
    required this.setNumber,
    this.weightKg,
    this.reps,
    this.isCompleted = false,
  });

  factory WorkoutSet.fromJson(Map<String, dynamic> json) {
    return WorkoutSet(
      id: json['id'],
      workoutExerciseId: json['workoutExerciseId'],
      setNumber: json['setNumber'],
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      reps: json['reps'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workoutExerciseId': workoutExerciseId,
      'setNumber': setNumber,
      'weightKg': weightKg,
      'reps': reps,
      'isCompleted': isCompleted,
    };
  }
}
