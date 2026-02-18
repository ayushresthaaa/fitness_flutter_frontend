import '../exercise/exercise_model.dart';
import '../exercise/workout_model.dart';

// Overall Stats
class OverallStats {
  final int totalWorkouts;
  final int totalDurationMins;
  final int avgDurationMins;
  final int totalExercisesLogged;
  final int totalSets;

  OverallStats({
    required this.totalWorkouts,
    required this.totalDurationMins,
    required this.avgDurationMins,
    required this.totalExercisesLogged,
    required this.totalSets,
  });

  factory OverallStats.fromJson(Map<String, dynamic> json) {
    return OverallStats(
      totalWorkouts: json['totalWorkouts'] ?? 0,
      totalDurationMins: json['totalDurationMins'] ?? 0,
      avgDurationMins: json['avgDurationMins'] ?? 0,
      totalExercisesLogged: json['totalExercisesLogged'] ?? 0,
      totalSets: json['totalSets'] ?? 0,
    );
  }
}

// Streak
class Streak {
  final int currentStreak;
  final int longestStreak;

  Streak({required this.currentStreak, required this.longestStreak});

  factory Streak.fromJson(Map<String, dynamic> json) {
    return Streak(
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
    );
  }
}

// Weekly Stats
class WeeklyDay {
  final String date;
  final String day;
  final int workouts;
  final int durationMins;

  WeeklyDay({
    required this.date,
    required this.day,
    required this.workouts,
    required this.durationMins,
  });

  factory WeeklyDay.fromJson(Map<String, dynamic> json) {
    return WeeklyDay(
      date: json['date'],
      day: json['day'],
      workouts: json['workouts'] ?? 0,
      durationMins: json['durationMins'] ?? 0,
    );
  }
}

// Monthly Stats
class MonthlyData {
  final String label;
  final int month;
  final int year;
  final int workouts;

  MonthlyData({
    required this.label,
    required this.month,
    required this.year,
    required this.workouts,
  });

  factory MonthlyData.fromJson(Map<String, dynamic> json) {
    return MonthlyData(
      label: json['label'],
      month: json['month'],
      year: json['year'],
      workouts: json['workouts'] ?? 0,
    );
  }
}

// Muscle Distribution
class MuscleDistribution {
  final String muscle;
  final int count;
  final int percentage;

  MuscleDistribution({
    required this.muscle,
    required this.count,
    required this.percentage,
  });

  factory MuscleDistribution.fromJson(Map<String, dynamic> json) {
    return MuscleDistribution(
      muscle: json['muscle'],
      count: json['count'] ?? 0,
      percentage: json['percentage'] ?? 0,
    );
  }
}

// Personal Best
class PersonalBest {
  final Exercise exercise;
  final double maxWeightKg;
  final int? reps;
  final int? sets;
  final DateTime achievedAt;

  PersonalBest({
    required this.exercise,
    required this.maxWeightKg,
    this.reps,
    this.sets,
    required this.achievedAt,
  });

  factory PersonalBest.fromJson(Map<String, dynamic> json) {
    return PersonalBest(
      exercise: Exercise.fromJson(json['exercise']),
      maxWeightKg: json['maxWeightKg'].toDouble(),
      reps: json['reps'],
      sets: json['sets'],
      achievedAt: DateTime.parse(json['achievedAt']),
    );
  }
}

// Exercise Progress Point
class ProgressPoint {
  final DateTime date;
  final int? sets;
  final int? reps;
  final double? weightKg;
  final int? durationSec;
  final double? volume;

  ProgressPoint({
    required this.date,
    this.sets,
    this.reps,
    this.weightKg,
    this.durationSec,
    this.volume,
  });

  factory ProgressPoint.fromJson(Map<String, dynamic> json) {
    return ProgressPoint(
      date: DateTime.parse(json['date']),
      sets: json['sets'],
      reps: json['reps'],
      weightKg: json['weightKg']?.toDouble(),
      durationSec: json['durationSec'],
      volume: json['volume']?.toDouble(),
    );
  }
}

// Exercise Progress (full)
class ExerciseProgressData {
  final Map<String, dynamic> exercise;
  final List<ProgressPoint> history;

  ExerciseProgressData({required this.exercise, required this.history});

  factory ExerciseProgressData.fromJson(Map<String, dynamic> json) {
    return ExerciseProgressData(
      exercise: json['exercise'],
      history: (json['history'] as List)
          .map((p) => ProgressPoint.fromJson(p))
          .toList(),
    );
  }
}

// Workout History Item (with duration)
class WorkoutHistoryItem {
  final String id;
  final int userId;
  final String? title;
  final String? notes;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationMins;
  final List<WorkoutExercise> exercises;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkoutHistoryItem({
    required this.id,
    required this.userId,
    this.title,
    this.notes,
    required this.startTime,
    this.endTime,
    required this.durationMins,
    required this.exercises,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WorkoutHistoryItem.fromJson(Map<String, dynamic> json) {
    return WorkoutHistoryItem(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      notes: json['notes'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      durationMins: json['durationMins'] ?? 0,
      exercises: (json['exercises'] as List? ?? [])
          .map((e) => WorkoutExercise.fromJson(e))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
