// lib/screens/user/trainer_request/widgets/current_trainer_card.dart

import 'package:flutter/material.dart';
import '../../../widgets/common.dart';
import '../trainer_profile_screen.dart';

class CurrentTrainerCard extends StatelessWidget {
  final Map<String, dynamic>? trainer;

  const CurrentTrainerCard({super.key, this.trainer});

  @override
  Widget build(BuildContext context) {
    if (trainer == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const EmptyState(
          icon: Icons.person_outline,
          title: 'No trainer assigned',
          subtitle: 'Contact support to get a trainer',
        ),
      );
    }

    final name = trainer!['name'] ?? 'Trainer';
    final initials = name
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TrainerProfileScreen(trainer: trainer!),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: kPrimaryLight,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: kPrimary,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: kTextDark,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: kTextHint,
                        size: 18,
                      ),
                    ],
                  ),
                  if (trainer!['specialization'] != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      trainer!['specialization'],
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: kPrimary,
                      ),
                    ),
                  ],
                  if (trainer!['bio'] != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      trainer!['bio'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: kTextGrey,
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
