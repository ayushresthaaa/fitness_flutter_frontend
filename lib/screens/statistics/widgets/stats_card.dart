import 'package:flutter/material.dart';
import '../../../models/progress/stats_model.dart';
import '../../../widgets/common.dart';

class StatsCards extends StatelessWidget {
  final OverallStats stats;
  final int currentStreak;

  const StatsCards({
    super.key,
    required this.stats,
    required this.currentStreak,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Workouts',
                value: '${stats.totalWorkouts}',
                icon: Icons.fitness_center_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Volume',
                value: stats.formattedVolume,
                icon: Icons.monitor_weight_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Time',
                value: stats.formattedDuration,
                icon: Icons.timer_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Streak',
                value: '$currentStreak days',
                icon: Icons.local_fire_department_rounded,
                iconColor: const Color(0xFFFF9800),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
  });

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
          Icon(icon, size: 20, color: iconColor ?? kPrimary),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: kTextDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: kTextGrey)),
        ],
      ),
    );
  }
}
