// lib/models/meal/meal_insights_model.dart

// ─────────────────────────────────────────
// WEEKLY CHART DAY
// ─────────────────────────────────────────

class WeeklyChartDay {
  final String day; // "Mon"
  final String date; // "2026-04-01"
  final int consumed;
  final int goal;
  final bool underGoal;
  final bool isEmpty;

  WeeklyChartDay({
    required this.day,
    required this.date,
    required this.consumed,
    required this.goal,
    required this.underGoal,
    required this.isEmpty,
  });

  factory WeeklyChartDay.fromJson(Map<String, dynamic> json) {
    return WeeklyChartDay(
      day: json['day'],
      date: json['date'],
      consumed: (json['consumed'] as num?)?.toInt() ?? 0,
      goal: (json['goal'] as num?)?.toInt() ?? 2000,
      underGoal: json['underGoal'] ?? true,
      isEmpty: json['isEmpty'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'date': date,
      'consumed': consumed,
      'goal': goal,
      'underGoal': underGoal,
      'isEmpty': isEmpty,
    };
  }

  // bar height ratio — capped at 1.5x so chart does not break on over-eating days
  double get heightRatio => goal > 0 ? (consumed / goal).clamp(0.0, 1.5) : 0;
}

// ─────────────────────────────────────────
// GOAL HIT RATES
// ─────────────────────────────────────────

class GoalHitRates {
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  GoalHitRates({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory GoalHitRates.fromJson(Map<String, dynamic> json) {
    return GoalHitRates(
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      protein: (json['protein'] as num?)?.toInt() ?? 0,
      carbs: (json['carbs'] as num?)?.toInt() ?? 0,
      fat: (json['fat'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }
}

// ─────────────────────────────────────────
// WEEKLY AVERAGES
// ─────────────────────────────────────────

class WeeklyAverages {
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  WeeklyAverages({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory WeeklyAverages.fromJson(Map<String, dynamic> json) {
    return WeeklyAverages(
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      protein: (json['protein'] as num?)?.toInt() ?? 0,
      carbs: (json['carbs'] as num?)?.toInt() ?? 0,
      fat: (json['fat'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }
}

// ─────────────────────────────────────────
// MEAL INSIGHTS
// ─────────────────────────────────────────

class MealInsights {
  final int nutritionScore;
  final int loggingStreak;
  final GoalHitRates goalHitRates;
  final WeeklyAverages weeklyAverages;
  final List<WeeklyChartDay> weeklyCalorieChart;

  MealInsights({
    required this.nutritionScore,
    required this.loggingStreak,
    required this.goalHitRates,
    required this.weeklyAverages,
    required this.weeklyCalorieChart,
  });

  factory MealInsights.fromJson(Map<String, dynamic> json) {
    return MealInsights(
      nutritionScore: (json['nutritionScore'] as num?)?.toInt() ?? 0,
      loggingStreak: (json['loggingStreak'] as num?)?.toInt() ?? 0,
      goalHitRates: GoalHitRates.fromJson(json['goalHitRates']),
      weeklyAverages: WeeklyAverages.fromJson(json['weeklyAverages']),
      weeklyCalorieChart: (json['weeklyCalorieChart'] as List? ?? [])
          .map((e) => WeeklyChartDay.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nutritionScore': nutritionScore,
      'loggingStreak': loggingStreak,
      'goalHitRates': goalHitRates.toJson(),
      'weeklyAverages': weeklyAverages.toJson(),
      'weeklyCalorieChart': weeklyCalorieChart.map((e) => e.toJson()).toList(),
    };
  }

  String get scoreLabel {
    if (nutritionScore >= 80) return 'Excellent';
    if (nutritionScore >= 60) return 'Good';
    if (nutritionScore >= 40) return 'Fair';
    return 'Needs work';
  }

  // emoji-free label icon name for the score — used in the score card
  String get scoreSummary {
    if (nutritionScore >= 80) return 'You\'re crushing it!';
    if (nutritionScore >= 60)
      return 'Protein slightly below target, everything else on track.';
    if (nutritionScore >= 40)
      return 'Room to improve — focus on hitting your macros.';
    return 'Start logging consistently to build your score.';
  }
}

// ─────────────────────────────────────────
// MEAL HISTORY ITEM
// ─────────────────────────────────────────

class MealHistoryItem {
  final DateTime date;
  final double calorieGoal;
  final double caloriesConsumed;
  final double proteinGoal;
  final double proteinConsumed;
  final double carbsGoal;
  final double carbsConsumed;
  final double fatGoal;
  final double fatConsumed;
  final bool goalHit;

  MealHistoryItem({
    required this.date,
    required this.calorieGoal,
    required this.caloriesConsumed,
    required this.proteinGoal,
    required this.proteinConsumed,
    required this.carbsGoal,
    required this.carbsConsumed,
    required this.fatGoal,
    required this.fatConsumed,
    required this.goalHit,
  });

  factory MealHistoryItem.fromJson(Map<String, dynamic> json) {
    final goals = json['goals'] as Map<String, dynamic>;
    final totals = json['totals'] as Map<String, dynamic>;
    return MealHistoryItem(
      date: DateTime.parse(json['date']).toLocal(),
      calorieGoal: (goals['calories'] as num).toDouble(),
      caloriesConsumed: (totals['calories'] as num).toDouble(),
      proteinGoal: (goals['protein'] as num).toDouble(),
      proteinConsumed: (totals['protein'] as num).toDouble(),
      carbsGoal: (goals['carbs'] as num).toDouble(),
      carbsConsumed: (totals['carbs'] as num).toDouble(),
      fatGoal: (goals['fat'] as num).toDouble(),
      fatConsumed: (totals['fat'] as num).toDouble(),
      goalHit: json['goalHit'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'goals': {
        'calories': calorieGoal,
        'protein': proteinGoal,
        'carbs': carbsGoal,
        'fat': fatGoal,
      },
      'totals': {
        'calories': caloriesConsumed,
        'protein': proteinConsumed,
        'carbs': carbsConsumed,
        'fat': fatConsumed,
      },
      'goalHit': goalHit,
    };
  }

  double get calorieProgress =>
      calorieGoal > 0 ? (caloriesConsumed / calorieGoal).clamp(0.0, 1.0) : 0;
}
