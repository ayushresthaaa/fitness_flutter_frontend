// lib/models/meal/nutrition_goal_model.dart

class NutritionGoal {
  final String id;
  final int userId;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double? fiber;

  NutritionGoal({
    required this.id,
    required this.userId,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber,
  });

  factory NutritionGoal.fromJson(Map<String, dynamic> json) {
    return NutritionGoal(
      id: json['id'],
      userId: json['userId'],
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      fiber: json['fiber'] != null ? (json['fiber'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
    };
  }
}
