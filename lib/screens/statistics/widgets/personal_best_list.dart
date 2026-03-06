import 'package:flutter/material.dart';
import '../../../models/progress/progress_model.dart';
import '../../../widgets/common.dart';
import '../../progress/exercise_detail_screen.dart';

class PersonalBestsList extends StatelessWidget {
  final List<PersonalBest> personalBests;

  const PersonalBestsList({super.key, required this.personalBests});

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}';
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
          const SectionLabel('PERSONAL BESTS'),
          const SizedBox(height: 12),

          if (personalBests.isEmpty)
            const Text(
              'No personal bests yet',
              style: TextStyle(fontSize: 13, color: kTextGrey),
            )
          else
            for (int i = 0; i < personalBests.length; i++) ...[
              _PRRow(pr: personalBests[i], formatDate: _formatDate),
              if (i < personalBests.length - 1)
                const Divider(height: 20, color: kDivider),
            ],
        ],
      ),
    );
  }
}

class _PRRow extends StatelessWidget {
  final PersonalBest pr;
  final String Function(DateTime) formatDate;

  const _PRRow({required this.pr, required this.formatDate});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ExerciseDetailScreen(
              exerciseId: pr.exerciseId,
              exerciseName: pr.exerciseName,
            ),
          ),
        );
      },
      child: Row(
        children: [
          // Exercise name
          Expanded(
            child: Text(
              pr.exerciseName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: kTextDark,
              ),
            ),
          ),

          // Weight
          Text(
            '${pr.maxWeightKg}kg',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: kPrimary,
            ),
          ),

          const SizedBox(width: 10),

          // Date
          Text(
            formatDate(pr.achievedAt),
            style: const TextStyle(fontSize: 12, color: kTextGrey),
          ),

          const SizedBox(width: 8),

          // Arrow
          const Icon(Icons.chevron_right, size: 18, color: kTextGrey),
        ],
      ),
    );
  }
}
