import 'package:flutter/material.dart';
import '../../../models/exercise/history_model.dart';
import '../../../widgets/common.dart';

// Monthly summary bar
// Shows workout count, total volume, total duration
class MonthlyStatsBar extends StatelessWidget {
  final MonthlyStats stats;

  const MonthlyStatsBar({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _StatTile(
            value: '${stats.workoutCount}',
            label: 'Workouts',
            icon: Icons.fitness_center_rounded,
            color: kTextDark,
          ),
          _Divider(),
          _StatTile(
            value: '${stats.totalVolumeKg}kg',
            label: 'Volume',
            icon: Icons.monitor_weight_outlined,
            color: kTextDark,
          ),
          _Divider(),
          _StatTile(
            value: stats.formattedDuration,
            label: 'Duration',
            icon: Icons.timer_outlined,
            color: kTextDark,
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: kDivider,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: kTextGrey)),
        ],
      ),
    );
  }
}
