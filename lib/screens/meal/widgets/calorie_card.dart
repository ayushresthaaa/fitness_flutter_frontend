// lib/screens/meal/widgets/calorie_card.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../widgets/common.dart';
import '../../../models/meal/meal_log_model.dart';

class CalorieCard extends StatelessWidget {
  final MealLog log;
  final int burned;

  const CalorieCard({
    super.key,
    required this.log,
    this.burned = 0,
  });

  @override
  Widget build(BuildContext context) {
    final consumed = log.totals.calories.toInt();
    final goal = log.goals.calories.toInt();
    final adjustedGoal = goal + burned;
    final remaining = adjustedGoal - consumed;
    final isOver = consumed > adjustedGoal;
    final progress = adjustedGoal > 0
        ? (consumed / adjustedGoal).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(100, 100),
                  painter: _RingPainter(
                    progress: progress,
                    color: isOver ? kRed : kPrimary,
                    backgroundColor: kDivider,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isOver ? '+${consumed - adjustedGoal}' : '$remaining',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isOver ? kRed : kTextDark,
                      ),
                    ),
                    Text(
                      isOver ? 'over' : 'kcal left',
                      style: const TextStyle(fontSize: 10, color: kTextGrey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatRow(
                  label: 'Eaten',
                  value: '$consumed kcal',
                  valueColor: kTextDark,
                ),
                const SizedBox(height: 8),
                _StatRow(
                  label: 'Goal',
                  value: '$goal kcal',
                  valueColor: kTextGrey,
                ),
                if (burned > 0) ...[
                  const SizedBox(height: 8),
                  _StatRow(
                    label: 'Burned',
                    value: '+$burned kcal',
                    valueColor: const Color(0xFFFF9800),
                  ),
                ],
                const SizedBox(height: 8),
                _StatRow(
                  label: 'Remaining',
                  value: isOver
                      ? '${(consumed - adjustedGoal).abs()} kcal over'
                      : '$remaining kcal',
                  valueColor: isOver ? kRed : kGreen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _StatRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: kTextGrey)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

// draws the circular ring
class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 8;
    const strokeWidth = 10.0;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // background ring
    canvas.drawCircle(center, radius, backgroundPaint);

    // progress arc — starts from top (-90 degrees)
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
