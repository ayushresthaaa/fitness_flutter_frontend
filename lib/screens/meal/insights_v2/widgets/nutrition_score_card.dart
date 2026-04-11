import 'package:flutter/material.dart';
import '../../../../widgets/common.dart';
import '../../../../models/meal/meal_insights_model.dart';

class NutritionScoreCard extends StatelessWidget {
  final MealInsights insights;

  const NutritionScoreCard({super.key, required this.insights});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.sports_score, size: 20, color: kPrimary),
          const SizedBox(height: 10),
          Text(
            '${insights.nutritionScore}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: kTextDark,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Nutrition Score',
            style: TextStyle(fontSize: 12, color: kTextGrey),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: insights.nutritionScore / 100,
              minHeight: 4,
              backgroundColor: kDivider,
              valueColor: const AlwaysStoppedAnimation<Color>(kPrimary),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            insights.scoreLabel,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: kPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
