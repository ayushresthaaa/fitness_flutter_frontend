import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/routine/weekly_program_model.dart';
import '../../providers/routine/weekly_program_provider.dart';
import '../../providers/routine/routine_provider.dart';
import '../../screens/workout/active_workout_screen_v2.dart';
import '../../widgets/common.dart';
import 'widgets/day_pill.dart';
import 'widgets/routine_picker_sheet.dart';
import 'widgets/today_program_card.dart';

// Weekly program screen
// Shows 7-day grid, today's workout card
// Tap a day to assign a routine or set as rest
class WeeklyProgramScreen extends StatefulWidget {
  const WeeklyProgramScreen({super.key});

  @override
  State<WeeklyProgramScreen> createState() => _WeeklyProgramScreenState();
}

class _WeeklyProgramScreenState extends State<WeeklyProgramScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeeklyProgramProvider>().fetchProgram();
      context.read<WeeklyProgramProvider>().fetchToday();
      context.read<RoutineProvider>().fetchRoutines();
    });
  }

  DayOfWeek get _todayDayOfWeek {
    final weekday = DateTime.now().weekday; // 1=Mon, 7=Sun
    return DayOfWeek.values[weekday - 1];
  }

  void _showDayPicker(WeeklyProgramDay day) {
    final routines = context.read<RoutineProvider>().routines;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => RoutinePickerSheet(
        day: day,
        routines: routines,
        onRoutineSelected: (routineId) async {
          await context.read<WeeklyProgramProvider>().assignRoutine(
            day.id,
            routineId,
          );
        },
        onSetRest: () async {
          await context.read<WeeklyProgramProvider>().setRestDay(day.id);
        },
      ),
    );
  }

  Future<void> _startWorkout(WeeklyProgramDay today) async {
    final routine = today.routine;
    if (routine == null) return;

    final prefilled = <Map<String, dynamic>>[];
    for (final re in routine.exercises) {
      if (re.exercise == null) continue;
      prefilled.add({
        'localId': '${re.exerciseId}_${DateTime.now().millisecondsSinceEpoch}',
        'exercise': re.exercise!,
        'supersetGroup': re.supersetGroup,
        'sets': re.sets,
      });
    }

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ActiveWorkoutScreenV2(
            workoutTitle: routine.name,
            prefilledExercises: prefilled,
            routineId: routine.id,
            originalExercises: routine.exercises
                .map(
                  (e) => {
                    'exerciseId': e.exerciseId,
                    'name': e.exercise?.name ?? '',
                  },
                )
                .toList(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppTopBar(title: 'My Program'),
      body: Consumer<WeeklyProgramProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.program == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.program == null) {
            return const EmptyState(
              icon: Icons.calendar_today_rounded,
              title: 'No program yet',
              subtitle: 'Pull to refresh to create your program',
            );
          }

          final program = provider.program!;
          final today = provider.today;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Today card
              if (today != null) ...[
                TodayProgramCard(
                  today: today,
                  onStart: today.routine != null
                      ? () => _startWorkout(today)
                      : null,
                ),
                const SizedBox(height: 24),
              ],

              // Week grid label
              const SectionLabel('THIS WEEK'),
              const SizedBox(height: 12),

              // 7-day horizontal scroll grid
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: program.days.map((day) {
                    final isToday = day.dayOfWeek == _todayDayOfWeek;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: DayPill(
                        day: day,
                        isToday: isToday,
                        onTap: () => _showDayPicker(day),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // Week summary
              const SectionLabel('WEEK SUMMARY'),
              const SizedBox(height: 12),
              _WeekSummary(days: program.days),
            ],
          );
        },
      ),
    );
  }
}

// Simple summary — how many workout days vs rest days
class _WeekSummary extends StatelessWidget {
  final List<WeeklyProgramDay> days;

  const _WeekSummary({required this.days});

  @override
  Widget build(BuildContext context) {
    final workoutDays = days
        .where((d) => !d.isRestDay && d.routine != null)
        .length;
    final restDays = 7 - workoutDays;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryTile(
              value: '$workoutDays',
              label: 'Workout Days',
              color: kPrimary,
              icon: Icons.fitness_center_rounded,
            ),
          ),
          Container(width: 1, height: 40, color: kDivider),
          Expanded(
            child: _SummaryTile(
              value: '$restDays',
              label: 'Rest Days',
              color: kTextGrey,
              icon: Icons.hotel_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  const _SummaryTile({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: kTextGrey)),
      ],
    );
  }
}
