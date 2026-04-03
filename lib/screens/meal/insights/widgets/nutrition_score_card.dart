// lib/screens/meal/widgets/nutrition_score_card.dart

import 'package:flutter/material.dart';
import '../../../../widgets/common.dart';
import '../../../../models/meal/meal_insights_model.dart';

class NutritionScoreCard extends StatelessWidget {
  final MealInsights insights;

  const NutritionScoreCard({super.key, required this.insights});

  Color get _scoreColor {
    if (insights.nutritionScore >= 80) return kGreen;
    if (insights.nutritionScore >= 60) return kPrimary;
    if (insights.nutritionScore >= 40) return const Color(0xFFFB8C00);
    return kRed;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kTextDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // label row
          Row(
            children: [
              const Text(
                'NUTRITION SCORE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: kTextGrey,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              // score label badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _scoreColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  insights.scoreLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _scoreColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // score number + summary side by side
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // big score number
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${insights.nutritionScore}',
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w800,
                      color: _scoreColor,
                      height: 1,
                    ),
                  ),
                  const Text(
                    'out of 100 · Today',
                    style: TextStyle(fontSize: 12, color: kTextGrey),
                  ),
                ],
              ),

              const SizedBox(width: 16),

              // summary text
              Expanded(
                child: Text(
                  insights.scoreSummary,
                  style: const TextStyle(
                    fontSize: 13,
                    color: kTextGrey,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
