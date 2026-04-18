// lib/models/meal/meal_log_model.dart

import 'food_model.dart';

// ─────────────────────────────────────────
// MACRO TOTALS
// ─────────────────────────────────────────

class MacroTotals {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  const MacroTotals({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory MacroTotals.fromJson(Map<String, dynamic> json) {
    return MacroTotals(
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
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

  factory MacroTotals.zero() {
    return const MacroTotals(calories: 0, protein: 0, carbs: 0, fat: 0);
  }
}

// ─────────────────────────────────────────
// HYDRATION
// ─────────────────────────────────────────

class Hydration {
  final int consumed;
  final int goal;
  final int remaining;
  final int percentage;

  Hydration({
    required this.consumed,
    required this.goal,
    required this.remaining,
    required this.percentage,
  });

  factory Hydration.fromJson(Map<String, dynamic> json) {
    return Hydration(
      consumed: (json['consumed'] as num?)?.toInt() ?? 0,
      goal: (json['goal'] as num?)?.toInt() ?? 2500,
      remaining: (json['remaining'] as num?)?.toInt() ?? 2500,
      percentage: (json['percentage'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'consumed': consumed,
      'goal': goal,
      'remaining': remaining,
      'percentage': percentage,
    };
  }

  factory Hydration.defaults() {
    return Hydration(consumed: 0, goal: 2500, remaining: 2500, percentage: 0);
  }

  double get progress => goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0;
}

// ─────────────────────────────────────────
// MEAL ITEM
// ─────────────────────────────────────────

class MealItem {
  final String id;
  final String mealSlotId;
  final String foodId;
  final Food food;
  final double quantity;
  final String unit;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  MealItem({
    required this.id,
    required this.mealSlotId,
    required this.foodId,
    required this.food,
    required this.quantity,
    required this.unit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory MealItem.fromJson(Map<String, dynamic> json) {
    return MealItem(
      id: json['id'],
      mealSlotId: json['mealSlotId'],
      foodId: json['foodId'],
      food: Food.fromJson(json['food']),
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'],
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mealSlotId': mealSlotId,
      'foodId': foodId,
      'food': food.toJson(),
      'quantity': quantity,
      'unit': unit,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }
}

// ─────────────────────────────────────────
// MEAL SLOT
// ─────────────────────────────────────────

class MealSlot {
  final String id;
  final String type;
  final String? time;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final List<MealItem> items;

  MealSlot({
    required this.id,
    required this.type,
    this.time,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.items,
  });

  factory MealSlot.fromJson(Map<String, dynamic> json) {
    return MealSlot(
      id: json['id'],
      type: json['type'],
      time: json['time'],
      totalCalories: (json['totalCalories'] as num?)?.toDouble() ?? 0,
      totalProtein: (json['totalProtein'] as num?)?.toDouble() ?? 0,
      totalCarbs: (json['totalCarbs'] as num?)?.toDouble() ?? 0,
      totalFat: (json['totalFat'] as num?)?.toDouble() ?? 0,
      items: (json['items'] as List? ?? [])
          .map((e) => MealItem.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'time': time,
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }

  bool get isEmpty => items.isEmpty;

  String get displayName {
    const names = {
      'breakfast': 'Breakfast',
      'lunch': 'Lunch',
      'dinner': 'Dinner',
      'snack': 'Snack',
    };
    return names[type] ?? type[0].toUpperCase() + type.substring(1);
  }
}

// ─────────────────────────────────────────
// MEAL LOG
// ─────────────────────────────────────────

class MealLog {
  final String id;
  final DateTime date;
  final String? reviewStatus;
  final String? trainerNotes;
  final String? proteinFeedback;
  final String? caloriesFeedback;
  final String? overallFeedback;
  final MacroTotals goals;
  final MacroTotals totals;
  final MacroTotals remaining;
  final List<MealSlot> slots;
  final Hydration hydration;

  MealLog({
    required this.id,
    required this.date,
    this.reviewStatus,
    this.trainerNotes,
    this.proteinFeedback,
    this.caloriesFeedback,
    this.overallFeedback,
    required this.goals,
    required this.totals,
    required this.remaining,
    required this.slots,
    required this.hydration,
  });

  factory MealLog.fromJson(Map<String, dynamic> json) {
    return MealLog(
      id: json['id'],
      date: DateTime.parse(json['date']).toLocal(),
      reviewStatus: json['reviewStatus'],
      trainerNotes: json['trainerNotes'],
      proteinFeedback: json['proteinFeedback'],
      caloriesFeedback: json['caloriesFeedback'],
      overallFeedback: json['overallFeedback'],
      goals: MacroTotals.fromJson(json['goals']),
      totals: MacroTotals.fromJson(json['totals']),
      remaining: MacroTotals.fromJson(json['remaining']),
      slots: (json['slots'] as List? ?? [])
          .map((e) => MealSlot.fromJson(e))
          .toList(),
      hydration: json['hydration'] != null
          ? Hydration.fromJson(json['hydration'])
          : Hydration.defaults(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'reviewStatus': reviewStatus,
      'trainerNotes': trainerNotes,
      'proteinFeedback': proteinFeedback,
      'caloriesFeedback': caloriesFeedback,
      'overallFeedback': overallFeedback,
      'goals': goals.toJson(),
      'totals': totals.toJson(),
      'remaining': remaining.toJson(),
      'slots': slots.map((e) => e.toJson()).toList(),
      'hydration': hydration.toJson(),
    };
  }

  double get calorieProgress => goals.calories > 0
      ? (totals.calories / goals.calories).clamp(0.0, 1.0)
      : 0;
  double get proteinProgress =>
      goals.protein > 0 ? (totals.protein / goals.protein).clamp(0.0, 1.0) : 0;
  double get carbsProgress =>
      goals.carbs > 0 ? (totals.carbs / goals.carbs).clamp(0.0, 1.0) : 0;
  double get fatProgress =>
      goals.fat > 0 ? (totals.fat / goals.fat).clamp(0.0, 1.0) : 0;

  bool get isOverCalorieGoal => totals.calories > goals.calories;
  double get caloriesRemaining => goals.calories - totals.calories;

  MealSlot? get breakfast =>
      slots.where((s) => s.type == 'breakfast').firstOrNull;
  MealSlot? get lunch => slots.where((s) => s.type == 'lunch').firstOrNull;
  MealSlot? get dinner => slots.where((s) => s.type == 'dinner').firstOrNull;
  MealSlot? get snack => slots.where((s) => s.type == 'snack').firstOrNull;
}

// ─────────────────────────────────────────
// MEAL HISTORY ITEM
// ─────────────────────────────────────────

class MealHistoryItem {
  final String id;
  final DateTime date;
  final String? reviewStatus;
  final String? trainerNotes;
  final String? proteinFeedback;
  final String? caloriesFeedback;
  final String? overallFeedback;
  final MacroTotals goals;
  final MacroTotals totals;
  final bool goalHit;

  MealHistoryItem({
    required this.id,
    required this.date,
    this.reviewStatus,
    this.trainerNotes,
    this.proteinFeedback,
    this.caloriesFeedback,
    this.overallFeedback,
    required this.goals,
    required this.totals,
    required this.goalHit,
  });

  factory MealHistoryItem.fromJson(Map<String, dynamic> json) {
    return MealHistoryItem(
      id: json['id'],
      date: DateTime.parse(json['date']).toLocal(),
      reviewStatus: json['reviewStatus'],
      trainerNotes: json['trainerNotes'],
      proteinFeedback: json['proteinFeedback'],
      caloriesFeedback: json['caloriesFeedback'],
      overallFeedback: json['overallFeedback'],
      goals: MacroTotals.fromJson(json['goals']),
      totals: MacroTotals.fromJson(json['totals']),
      goalHit: json['goalHit'] ?? false,
    );
  }

  bool get isPending => reviewStatus == 'pending';
  bool get isReviewed => reviewStatus == 'reviewed';
  bool get notSent => reviewStatus == null;
  bool get isOverCalorieGoal => totals.calories > goals.calories;

  String get dateLabel {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }
}
