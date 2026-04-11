import 'package:flutter/material.dart';
import '../../../../widgets/common.dart';
import '../../../../models/meal/meal_insights_model.dart';

class MacroHitRateCard extends StatelessWidget {
  final GoalHitRates goalHitRates;

  const MacroHitRateCard({super.key, required this.goalHitRates});

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
          const SectionLabel('Goal Hit Rates · Last 7 Days'),
          const SizedBox(height: 14),
          _HitRow(
            label: 'Calories',
            percentage: goalHitRates.calories,
            color: kGreen,
          ),
          const SizedBox(height: 12),
          _HitRow(
            label: 'Protein',
            percentage: goalHitRates.protein,
            color: kPrimary,
          ),
          const SizedBox(height: 12),
          _HitRow(
            label: 'Carbs',
            percentage: goalHitRates.carbs,
            color: const Color(0xFFFB8C00),
          ),
          const SizedBox(height: 12),
          _HitRow(
            label: 'Fat',
            percentage: goalHitRates.fat,
            color: const Color(0xFF8E24AA),
          ),
        ],
      ),
    );
  }
}

class _HitRow extends StatelessWidget {
  final String label;
  final int percentage;
  final Color color;

  const _HitRow({
    required this.label,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: kTextDark,
              ),
            ),
            const Spacer(),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (percentage / 100).clamp(0.0, 1.0),
            minHeight: 5,
            backgroundColor: kDivider,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}