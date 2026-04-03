// lib/screens/meal/widgets/weekly_chart.dart

import 'package:flutter/material.dart';
import '../../../../../widgets/common.dart';
import '../../../../../models/meal/meal_insights_model.dart';

class WeeklyChart extends StatelessWidget {
  final List<WeeklyChartDay> days;

  const WeeklyChart({super.key, required this.days});

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
          const SectionLabel('Calories · Last 7 Days'),
          const SizedBox(height: 16),

          // bar chart
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: days.map((day) => _DayBar(day: day)).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // legend
          Row(
            children: [
              _LegendDot(color: kPrimary, label: 'Under goal'),
              const SizedBox(width: 16),
              _LegendDot(color: kRed, label: 'Over goal'),
              const SizedBox(width: 16),
              _LegendDot(color: kDivider, label: 'No log'),
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

  Color get _barColor {
    if (day.isEmpty) return kDivider;
    return day.underGoal ? kPrimary : kRed;
  }

  @override
  Widget build(BuildContext context) {
    // max chart height in pixels
    const double maxHeight = 100;
    final double barHeight = day.isEmpty
        ? 6
        : (day.heightRatio * maxHeight).clamp(6, maxHeight);

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // calorie label above bar — only shown on non-empty days
          if (!day.isEmpty)
            Text(
              '${day.consumed}',
              style: const TextStyle(fontSize: 9, color: kTextGrey),
            ),

          const SizedBox(height: 4),

          // the bar itself
          Container(
            height: barHeight,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: _barColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          const SizedBox(height: 6),

          // day label below bar
          Text(
            day.day,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: kTextGrey,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

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
