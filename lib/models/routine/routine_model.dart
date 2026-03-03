import '../exercise/exercise_model.dart';

class Routine {
  final String id;
  final int userId;
  final String name;
  final String? description;
  final bool isPublic;
  final List<RoutineExercise> exercises;
  final DateTime createdAt;
  final DateTime updatedAt;

  Routine({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.isPublic,
    required this.exercises,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      description: json['description'],
      isPublic: json['isPublic'] ?? false,
      exercises: (json['exercises'] as List? ?? [])
          .map((e) => RoutineExercise.fromJson(e))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'isPublic': isPublic,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class RoutineExercise {
  final String id;
  final String routineId;
  final String exerciseId;
  final int? sets;
  final int? reps;
  final double? weightKg;
  final int? restSec;
  final int order;
  final String? notes;
  final Exercise? exercise;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? supersetGroup;
  RoutineExercise({
    required this.id,
    required this.routineId,
    required this.exerciseId,
    this.sets,
    this.reps,
    this.weightKg,
    this.restSec,
    required this.order,
    this.notes,
    this.exercise,
    required this.createdAt,
    required this.updatedAt,
    this.supersetGroup,
  });

  factory RoutineExercise.fromJson(Map<String, dynamic> json) {
    return RoutineExercise(
      id: json['id'],
      routineId: json['routineId'],
      exerciseId: json['exerciseId'],
      sets: json['sets'],
      reps: json['reps'],
      weightKg: json['weightKg']?.toDouble(),
      restSec: json['restSec'],
      order: json['order'] ?? 0,
      notes: json['notes'],
      exercise: json['exercise'] != null
          ? Exercise.fromJson(json['exercise'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      supersetGroup: json['supersetGroup'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routineId': routineId,
      'exerciseId': exerciseId,
      'sets': sets,
      'reps': reps,
      'weightKg': weightKg,
      'restSec': restSec,
      'order': order,
      'notes': notes,
      'exercise': exercise?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'supersetGroup': supersetGroup,
    };
  }
}
