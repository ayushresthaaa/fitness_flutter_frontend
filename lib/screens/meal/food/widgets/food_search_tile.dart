// lib/screens/meal/widgets/food_search_tile.dart

import 'package:flutter/material.dart';
import '../../../../widgets/common.dart';
import '../../../../models/meal/food_model.dart';

class FoodSearchTile extends StatelessWidget {
  final Food food;
  final VoidCallback onTap;

  const FoodSearchTile({super.key, required this.food, required this.onTap});

  // map category to a material icon
  IconData _categoryIcon(String category) {
    switch (category) {
      case 'protein':
        return Icons.set_meal_outlined;
      case 'grain':
        return Icons.grain_outlined;
      case 'dairy':
        return Icons.egg_outlined;
      case 'fruit':
        return Icons.eco_outlined;
      case 'vegetable':
        return Icons.spa_outlined;
      case 'legume':
        return Icons.circle_outlined;
      case 'nepali':
        return Icons.restaurant_outlined;
      case 'snack':
        return Icons.cookie_outlined;
      case 'beverage':
        return Icons.local_cafe_outlined;
      default:
        return Icons.fastfood_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: kWhite,
          border: Border(bottom: BorderSide(color: kDivider, width: 1)),
        ),
        child: Row(
          children: [
            // category icon badge
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: kPrimaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _categoryIcon(food.category),
                color: kPrimary,
                size: 20,
              ),
            ),

            const SizedBox(width: 12),

            // name, serving info, macros
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // food name + optional badges
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          food.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: kTextDark,
                          ),
                        ),
                      ),
                      if (food.isNepali)
                        _SmallBadge(
                          label: 'Nepali',
                          backgroundColor: const Color(0xFFFFF3E0),
                          textColor: const Color(0xFFE65100),
                        ),
                      if (food.isCustom)
                        _SmallBadge(
                          label: 'Custom',
                          backgroundColor: kPrimaryLight,
                          textColor: kPrimary,
                        ),
                    ],
                  ),

                  const SizedBox(height: 3),

                  // serving size + calories per serving
                  Text(
                    '${food.servingLabel ?? '${food.servingSize.toInt()} ${food.servingUnit}'} · ${food.calories.toInt()} kcal',
                    style: const TextStyle(fontSize: 12, color: kTextGrey),
                  ),

                  const SizedBox(height: 2),

                  // quick macro summary
                  Text(
                    'P ${food.protein.toInt()}g · C ${food.carbs.toInt()}g · F ${food.fat.toInt()}g',
                    style: const TextStyle(fontSize: 11, color: kTextHint),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            const Icon(Icons.add_circle_outline, color: kPrimary, size: 22),
          ],
        ),
      ),
    );
  }
}

// small label badge used for "Nepali" and "Custom" tags
class _SmallBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _SmallBadge({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
