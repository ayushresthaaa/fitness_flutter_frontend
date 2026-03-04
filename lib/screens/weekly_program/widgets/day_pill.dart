import 'package:flutter/material.dart';
import '../../../models/routine/weekly_program_model.dart';
import '../../../widgets/common.dart';

// Single day tile in the 7-day grid
// Highlighted if it's today
class DayPill extends StatelessWidget {
  final WeeklyProgramDay day;
  final bool isToday;
  final VoidCallback onTap;

  const DayPill({
    super.key,
    required this.day,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRest = day.isRestDay || day.routine == null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isToday ? kPrimary : kWhite,
          borderRadius: BorderRadius.circular(12),
          border: isToday ? null : Border.all(color: kDivider, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Day name
            Text(
              day.dayOfWeek.shortName.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isToday ? Colors.white70 : kTextGrey,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            // Icon
            Icon(
              isRest ? Icons.hotel_rounded : Icons.fitness_center_rounded,
              size: 20,
              color: isToday
                  ? kWhite
                  : isRest
                  ? kTextHint
                  : kPrimary,
            ),
            const SizedBox(height: 8),
            // Routine name or Rest
            Text(
              isRest ? 'Rest' : day.routine!.name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isToday ? kWhite : kTextDark,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
