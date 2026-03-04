import 'package:flutter/material.dart';
import '../../../widgets/common.dart';

// Calendar widget for history screen
// Shows dots on days with workouts
// Highlights today and selected day
// Left/right arrows to navigate months
class HistoryCalendar extends StatelessWidget {
  final String currentMonth;
  final Set<String> workoutDates;
  final DateTime selectedDay;
  final void Function(DateTime) onDaySelected;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const HistoryCalendar({
    super.key,
    required this.currentMonth,
    required this.workoutDates,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  DateTime get _firstDayOfMonth {
    final parts = currentMonth.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]), 1);
  }

  String get _monthLabel {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final parts = currentMonth.split('-');
    return '${months[int.parse(parts[1]) - 1]} ${parts[0]}';
  }

  String _dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  bool _isToday(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }

  bool _isSelected(DateTime dt) {
    return dt.year == selectedDay.year &&
        dt.month == selectedDay.month &&
        dt.day == selectedDay.day;
  }

  bool _hasWorkout(DateTime dt) => workoutDates.contains(_dateKey(dt));

  bool _isCurrentMonth(DateTime dt) {
    final parts = currentMonth.split('-');
    return dt.month == int.parse(parts[1]) && dt.year == int.parse(parts[0]);
  }

  List<DateTime?> _buildCalendarDays() {
    final first = _firstDayOfMonth;
    // Monday = 0, Sunday = 6
    final startOffset = (first.weekday - 1) % 7;
    final daysInMonth = DateUtils.getDaysInMonth(first.year, first.month);

    final days = <DateTime?>[];

    // Empty cells before first day
    for (int i = 0; i < startOffset; i++) {
      days.add(null);
    }

    // Actual days
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(first.year, first.month, i));
    }

    return days;
  }

  @override
  Widget build(BuildContext context) {
    final days = _buildCalendarDays();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Month navigation
          Row(
            children: [
              GestureDetector(
                onTap: onPreviousMonth,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: kBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: kTextDark,
                    size: 20,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  _monthLabel,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: kTextDark,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onNextMonth,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: kBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: kTextDark,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Day headers — Mon Tue Wed Thu Fri Sat Sun
          Row(
            children: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
                .map(
                  (d) => Expanded(
                    child: Text(
                      d,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: kTextGrey,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 8),

          // Calendar grid
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            children: days.map((day) {
              if (day == null) return const SizedBox();

              final isToday = _isToday(day);
              final isSelected = _isSelected(day);
              final hasWorkout = _hasWorkout(day);
              final inMonth = _isCurrentMonth(day);

              return GestureDetector(
                onTap: () => onDaySelected(day),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Day number
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? kPrimary
                            : isToday
                            ? kPrimaryLight
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isToday || isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? kWhite
                                : isToday
                                ? kPrimary
                                : inMonth
                                ? kTextDark
                                : kTextHint,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 3),

                    // Workout dot
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: hasWorkout
                            ? isSelected
                                  ? kWhite
                                  : kPrimary
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
