// lib/screens/meal/insights/widgets/weekly_chart.dart

import 'package:flutter/material.dart';
import '../../../../widgets/common.dart';
import '../../../../models/meal/meal_insights_model.dart';

class WeeklyChart extends StatelessWidget {
  final List<WeeklyChartDay> days;

  const WeeklyChart({super.key, required this.days});

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
          const SectionLabel('Calories · Last 7 Days'),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: days.map((day) => _DayBar(day: day)).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Legend(color: kPrimary, label: 'Under goal'),
              const SizedBox(width: 14),
              _Legend(color: kRed, label: 'Over goal'),
              const SizedBox(width: 14),
              _Legend(color: kDivider, label: 'No log'),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayBar extends StatelessWidget {
  final WeeklyChartDay day;

  const _DayBar({required this.day});

  Color get _color {
    if (day.isEmpty) return kDivider;
    return day.underGoal ? kPrimary : kRed;
  }

  @override
  Widget build(BuildContext context) {
    const double maxHeight = 80;
    final double barHeight = day.isEmpty
        ? 4
        : (day.heightRatio * maxHeight).clamp(4, maxHeight);

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (!day.isEmpty)
            Text(
              '${day.consumed}',
              style: const TextStyle(fontSize: 8, color: kTextGrey),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 3),
          Container(
            height: barHeight,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: _color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 6),
          Text(day.day, style: const TextStyle(fontSize: 11, color: kTextGrey)),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: kTextGrey)),
      ],
    );
  }
}
