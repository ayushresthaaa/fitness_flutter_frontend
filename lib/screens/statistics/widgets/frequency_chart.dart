import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/progress/stats_model.dart';
import '../../../widgets/common.dart';

class FrequencyChart extends StatefulWidget {
  final List<WeeklyDay> weeklyData;
  final List<MonthlyData> monthlyData;

  const FrequencyChart({
    super.key,
    required this.weeklyData,
    required this.monthlyData,
  });

  @override
  State<FrequencyChart> createState() => _FrequencyChartState();
}

class _FrequencyChartState extends State<FrequencyChart> {
  bool _isWeekly = true;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SectionLabel('FREQUENCY'),
              Row(
                children: [
                  _ToggleChip(
                    label: 'Weekly',
                    selected: _isWeekly,
                    onTap: () => setState(() => _isWeekly = true),
                  ),
                  const SizedBox(width: 8),
                  _ToggleChip(
                    label: 'Monthly',
                    selected: !_isWeekly,
                    onTap: () => setState(() => _isWeekly = false),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Chart
          SizedBox(
            height: 140,
            child: _isWeekly ? _buildWeeklyChart() : _buildMonthlyChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    final data = widget.weeklyData;

    if (data.isEmpty) {
      return const Center(
        child: Text(
          'No data yet',
          style: TextStyle(fontSize: 13, color: kTextGrey),
        ),
      );
    }

    final maxY =
        data.map((d) => d.workouts.toDouble()).reduce((a, b) => a > b ? a : b) +
        1;

    return BarChart(
      BarChartData(
        maxY: maxY,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    data[index].day,
                    style: const TextStyle(fontSize: 11, color: kTextGrey),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(data.length, (i) {
          final hasWorkout = data[i].workouts > 0;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: hasWorkout ? data[i].workouts.toDouble() : 0.3,
                color: hasWorkout ? kPrimary : const Color(0xFFEEEEEE),
                width: 22,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildMonthlyChart() {
    final data = widget.monthlyData;

    if (data.isEmpty) {
      return const Center(
        child: Text(
          'No data yet',
          style: TextStyle(fontSize: 13, color: kTextGrey),
        ),
      );
    }

    final maxY =
        data.map((d) => d.workouts.toDouble()).reduce((a, b) => a > b ? a : b) +
        1;

    return BarChart(
      BarChartData(
        maxY: maxY,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    data[index].label.split(' ')[0],
                    style: const TextStyle(fontSize: 11, color: kTextGrey),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(data.length, (i) {
          final hasWorkout = data[i].workouts > 0;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: hasWorkout ? data[i].workouts.toDouble() : 0.3,
                color: hasWorkout ? kPrimary : const Color(0xFFEEEEEE),
                width: 28,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? kPrimary : kBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? kWhite : kTextGrey,
          ),
        ),
      ),
    );
  }
}
