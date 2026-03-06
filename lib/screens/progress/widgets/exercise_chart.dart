import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../widgets/common.dart';

enum ChartType { weight, oneRM, volume }

class ExerciseChart extends StatefulWidget {
  final List<Map<String, dynamic>> weightData;
  final List<Map<String, dynamic>> oneRMData;
  final List<Map<String, dynamic>> volumeData;
  final bool isCardio;

  const ExerciseChart({
    super.key,
    required this.weightData,
    required this.oneRMData,
    required this.volumeData,
    this.isCardio = false,
  });

  @override
  State<ExerciseChart> createState() => _ExerciseChartState();
}

class _ExerciseChartState extends State<ExerciseChart> {
  ChartType _selected = ChartType.weight;

  List<Map<String, dynamic>> get _activeData {
    if (_selected == ChartType.weight) return widget.weightData;
    if (_selected == ChartType.oneRM) return widget.oneRMData;
    return widget.volumeData;
  }

  String _formatValue(double value) {
    if (widget.isCardio) {
      if (_selected == ChartType.weight) {
        return '${(value / 60).toStringAsFixed(1)} min';
      }
      if (_selected == ChartType.oneRM) {
        return '${(value / 1000).toStringAsFixed(2)} km';
      }
      return '${value.toStringAsFixed(0)} m';
    }
    if (_selected == ChartType.volume) {
      if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k kg';
      return '${value.toStringAsFixed(0)} kg';
    }
    return '${value.toStringAsFixed(1)} kg';
  }

  String _formatDate(DateTime date) {
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
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final data = _activeData;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toggle chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _Chip(
                  label: widget.isCardio ? 'Duration' : 'Heaviest',
                  selected: _selected == ChartType.weight,
                  onTap: () => setState(() => _selected = ChartType.weight),
                ),
                const SizedBox(width: 8),
                if (!widget.isCardio) ...[
                  _Chip(
                    label: 'Est. 1RM',
                    selected: _selected == ChartType.oneRM,
                    onTap: () => setState(() => _selected = ChartType.oneRM),
                  ),
                  const SizedBox(width: 8),
                ] else ...[
                  _Chip(
                    label: 'Distance',
                    selected: _selected == ChartType.oneRM,
                    onTap: () => setState(() => _selected = ChartType.oneRM),
                  ),
                  const SizedBox(width: 8),
                ],
                _Chip(
                  label: 'Volume',
                  selected: _selected == ChartType.volume,
                  onTap: () => setState(() => _selected = ChartType.volume),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Latest value + date
          if (data.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatValue(data.last['value'] as double),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    _formatDate(data.last['date'] as DateTime),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: kPrimary,
                    ),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 12),

          // Empty state
          if (data.isEmpty)
            const SizedBox(
              height: 120,
              child: Center(
                child: Text(
                  'No data yet',
                  style: TextStyle(fontSize: 13, color: kTextGrey),
                ),
              ),
            )
          else
            SizedBox(
              height: 140,
              child: LineChart(
                LineChartData(
                  minY:
                      data
                          .map((d) => d['value'] as double)
                          .reduce((a, b) => a < b ? a : b) *
                      0.85,
                  maxY:
                      data
                          .map((d) => d['value'] as double)
                          .reduce((a, b) => a > b ? a : b) *
                      1.15,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (value, meta) {
                          if (value == meta.min || value == meta.max) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            value.toStringAsFixed(0),
                            style: const TextStyle(
                              fontSize: 10,
                              color: kTextGrey,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(data.length, (i) {
                        return FlSpot(i.toDouble(), data[i]['value'] as double);
                      }),
                      isCurved: true,
                      curveSmoothness: 0.3,
                      color: kPrimary,
                      barWidth: 2.5,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                          radius: 3,
                          color: kWhite,
                          strokeWidth: 2,
                          strokeColor: kPrimary,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            kPrimary.withOpacity(0.15),
                            kPrimary.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final index = spot.x.toInt();
                          String dateLabel = '';
                          if (index >= 0 && index < data.length) {
                            dateLabel = _formatDate(
                              data[index]['date'] as DateTime,
                            );
                          }
                          return LineTooltipItem(
                            '$dateLabel\n${_formatValue(spot.y)}',
                            const TextStyle(
                              color: kWhite,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
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
