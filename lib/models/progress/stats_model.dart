// Overall stats — total workouts, volume, duration, sets
class OverallStats {
  final int totalWorkouts;
  final int totalVolumeKg;
  final int totalDurationMins;
  final int totalSets;

  OverallStats({
    required this.totalWorkouts,
    required this.totalVolumeKg,
    required this.totalDurationMins,
    required this.totalSets,
  });

  factory OverallStats.fromJson(Map<String, dynamic> json) {
    return OverallStats(
      totalWorkouts: json['totalWorkouts'] ?? 0,
      totalVolumeKg: json['totalVolumeKg'] ?? 0,
      totalDurationMins: json['totalDurationMins'] ?? 0,
      totalSets: json['totalSets'] ?? 0,
    );
  }

  // "h m" format
  String get formattedDuration {
    final h = totalDurationMins ~/ 60;
    final m = totalDurationMins % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  // "1.2k kg " format for large volumes
  String get formattedVolume {
    if (totalVolumeKg >= 1000) {
      return '${(totalVolumeKg / 1000).toStringAsFixed(1)}k kg';
    }
    return '${totalVolumeKg}kg';
  }
}

// One day in weekly stats
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

// One month in monthly stats
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
      month: json['month'] ?? 0,
      year: json['year'] ?? 0,
      workouts: json['workouts'] ?? 0,
    );
  }
}

// One muscle group in distribution
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
