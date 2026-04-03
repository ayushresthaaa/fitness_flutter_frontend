// lib/screens/meal/widgets/macro_row.dart

import 'package:flutter/material.dart';
import '../../../widgets/common.dart';
import '../../../models/meal/meal_log_model.dart';

class MacroRow extends StatelessWidget {
  final MealLog log;

  const MacroRow({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MacroCard(
            label: 'Protein',
            consumed: log.totals.protein.toInt(),
            goal: log.goals.protein.toInt(),
            progress: log.proteinProgress,
            color: kPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MacroCard(
            label: 'Carbs',
            consumed: log.totals.carbs.toInt(),
            goal: log.goals.carbs.toInt(),
            progress: log.carbsProgress,
            color: const Color(0xFFFB8C00),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MacroCard(
            label: 'Fat',
            consumed: log.totals.fat.toInt(),
            goal: log.goals.fat.toInt(),
            progress: log.fatProgress,
            color: const Color(0xFF8E24AA),
          ),
        ),
      ],
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String label;
  final int consumed;
  final int goal;
  final double progress;
  final Color color;

  const _MacroCard({
    required this.label,
    required this.consumed,
    required this.goal,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: kTextGrey,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${consumed}g',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: kTextDark,
            ),
          ),
          Text(
            '/ ${goal}g',
            style: const TextStyle(fontSize: 11, color: kTextGrey),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: kDivider,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
