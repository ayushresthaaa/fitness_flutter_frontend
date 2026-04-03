// lib/screens/meal/widgets/macro_hit_rate_card.dart

import 'package:flutter/material.dart';
import '../../../../../widgets/common.dart';
import '../../../../../models/meal/meal_insights_model.dart';

class MacroHitRateCard extends StatelessWidget {
  final GoalHitRates goalHitRates;

  const MacroHitRateCard({super.key, required this.goalHitRates});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Goal Hit Rates · Last 7 Days'),
          const SizedBox(height: 14),

          _MacroHitRow(
            label: 'Protein',
            icon: Icons.fitness_center_outlined,
            iconColor: kPrimary,
            percentage: goalHitRates.protein,
            barColor: kPrimary,
          ),
          const SizedBox(height: 14),

          _MacroHitRow(
            label: 'Carbs',
            icon: Icons.grain_outlined,
            iconColor: const Color(0xFFFB8C00),
            percentage: goalHitRates.carbs,
            barColor: const Color(0xFFFB8C00),
          ),
          const SizedBox(height: 14),

          _MacroHitRow(
            label: 'Fat',
            icon: Icons.opacity_outlined,
            iconColor: const Color(0xFF8E24AA),
            percentage: goalHitRates.fat,
            barColor: const Color(0xFF8E24AA),
          ),
          const SizedBox(height: 14),

          _MacroHitRow(
            label: 'Calories',
            icon: Icons.local_fire_department_outlined,
            iconColor: kGreen,
            percentage: goalHitRates.calories,
            barColor: kGreen,
          ),
        ],
      ),
    );
  }
}

class _MacroHitRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final int percentage;
  final Color barColor;

  const _MacroHitRow({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.percentage,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (percentage / 100).clamp(0.0, 1.0);

    return Column(
      children: [
        // label row — icon, name, percentage
        Row(
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: kTextDark,
                ),
              ),
            ),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: barColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: kDivider,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),

        const SizedBox(height: 6),

        // consumed / remaining / target labels
        Row(
          children: [
            Text(
              '${percentage}g',
              style: const TextStyle(fontSize: 11, color: kTextGrey),
            ),
            const Spacer(),
            Text(
              '${100 - percentage}g remaining',
              style: const TextStyle(fontSize: 11, color: kTextGrey),
            ),
          ],
        ),
      ],
    );
  }
}
