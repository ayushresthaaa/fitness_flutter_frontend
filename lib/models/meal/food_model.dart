// lib/models/meal/food_model.dart

class Food {
  final String id;
  final String name;
  final String category;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double? fiber;
  final double servingSize;
  final String servingUnit;
  final String? servingLabel;
  final bool isNepali;
  final bool isCustom;
  final int? createdBy;
  final String? imageUrl;

  Food({
    required this.id,
    required this.name,
    required this.category,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber,
    required this.servingSize,
    required this.servingUnit,
    this.servingLabel,
    required this.isNepali,
    required this.isCustom,
    this.createdBy,
    this.imageUrl,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      fiber: json['fiber'] != null ? (json['fiber'] as num).toDouble() : null,
      servingSize: (json['servingSize'] as num).toDouble(),
      servingUnit: json['servingUnit'],
      servingLabel: json['servingLabel'],
      isNepali: json['isNepali'] ?? false,
      isCustom: json['isCustom'] ?? false,
      createdBy: json['createdBy'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'servingSize': servingSize,
      'servingUnit': servingUnit,
      'servingLabel': servingLabel,
      'isNepali': isNepali,
      'isCustom': isCustom,
      'createdBy': createdBy,
      'imageUrl': imageUrl,
    };
  }

  // macros scaled to given quantity (grams/ml)
  double caloriesFor(double quantity) =>
      double.parse((calories * quantity / 100).toStringAsFixed(1));
  double proteinFor(double quantity) =>
      double.parse((protein * quantity / 100).toStringAsFixed(1));
  double carbsFor(double quantity) =>
      double.parse((carbs * quantity / 100).toStringAsFixed(1));
  double fatFor(double quantity) =>
      double.parse((fat * quantity / 100).toStringAsFixed(1));

  String get categoryLabel {
    const labels = {
      'protein': 'Protein',
      'grain': 'Grain',
      'dairy': 'Dairy',
      'fruit': 'Fruit',
      'vegetable': 'Vegetable',
      'legume': 'Legume',
      'nepali': 'Nepali',
      'snack': 'Snack',
      'beverage': 'Beverage',
    };
    return labels[category] ?? category;
  }
}
