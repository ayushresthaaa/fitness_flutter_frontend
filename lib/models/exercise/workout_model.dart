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
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      exercises: (json['exercises'] as List? ?? [])
          .map((e) => WorkoutExercise.fromJson(e))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
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
  final Exercise? exercise; // populated by backend with 'include'
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
