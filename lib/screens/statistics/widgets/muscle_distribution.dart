import 'package:flutter/material.dart';
import '../../../models/progress/stats_model.dart';
import '../../../widgets/common.dart';

class MuscleDistributionWidget extends StatelessWidget {
  final List<MuscleDistribution> muscles;

  const MuscleDistributionWidget({super.key, required this.muscles});

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('MUSCLES WORKED'),
          const SizedBox(height: 12),

          if (muscles.isEmpty)
            const Text(
              'No data yet',
              style: TextStyle(fontSize: 13, color: kTextGrey),
            )
          else
            for (int i = 0; i < muscles.length; i++) ...[
              _MuscleRow(item: muscles[i], capitalize: _capitalize),
              if (i < muscles.length - 1) const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

class _MuscleRow extends StatelessWidget {
  final MuscleDistribution item;
  final String Function(String) capitalize;

  const _MuscleRow({required this.item, required this.capitalize});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Muscle name
        SizedBox(
          width: 100,
          child: Text(
            capitalize(item.muscle),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: kTextDark,
            ),
          ),
        ),

        // Progress bar
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: item.percentage / 100,
              backgroundColor: kBackground,
              color: kPrimary,
              minHeight: 8,
            ),
          ),
        ),

        // Percentage
        SizedBox(
          width: 40,
          child: Text(
            '${item.percentage}%',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: kTextGrey,
            ),
          ),
        ),
      ],
    );
  }
}
