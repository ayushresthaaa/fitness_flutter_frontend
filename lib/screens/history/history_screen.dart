import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/exercise/history_provider.dart';
import '../../providers/exercise/workout_provider.dart';
import '../../widgets/common.dart';
import '../../widgets/app_dialog.dart';
import 'widgets/history_calendar.dart';
import 'widgets/monthly_stats_bar.dart';
import 'widgets/streak_banner.dart';
import 'widgets/workout_history_card.dart';
import 'widgets/workout_detail_screen.dart';
import '../../providers/routine/routine_provider.dart';
import '../../screens/workout/active_workout_screen_v2.dart';
import '../../models/exercise/history_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().fetchAll();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Edit
  Future<void> _editWorkout(WorkoutHistory workout) async {
    final titleController = TextEditingController(text: workout.title ?? '');
    final notesController = TextEditingController(text: workout.notes ?? '');
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Workout',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 16),
            const SectionLabel('TITLE'),
            const SizedBox(height: 8),
            AppTextField(controller: titleController, hint: 'Workout title'),
            const SizedBox(height: 12),
            const SectionLabel('NOTES'),
            const SizedBox(height: 8),
            AppTextField(
              controller: notesController,
              hint: 'Notes',
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: 'Save',
              onTap: () async {
                Navigator.pop(ctx);
                await context.read<WorkoutProvider>().updateWorkout(
                  workout.id,
                  title: titleController.text.trim(),
                  notes: notesController.text.trim(),
                );
                if (mounted) context.read<HistoryProvider>().fetchAll();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Copy
  void _copyWorkout(WorkoutHistory workout) {
    final prefilled = workout.exercises
        .map(
          (ex) => {
            'localId':
                '${ex.exerciseId}_${DateTime.now().millisecondsSinceEpoch}',
            'exercise': ex.exercise,
            'supersetGroup': ex.supersetGroup,
            'sets': ex.sets ?? 3,
          },
        )
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActiveWorkoutScreenV2(
          workoutTitle: workout.title,
          prefilledExercises: prefilled,
        ),
      ),
    );
  }

  // Save as Routine
  Future<void> _saveAsRoutine(WorkoutHistory workout) async {
    final nameController = TextEditingController(text: workout.title ?? '');
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Save as Routine',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 16),
            const SectionLabel('ROUTINE NAME'),
            const SizedBox(height: 8),
            AppTextField(controller: nameController, hint: 'e.g. Push Day'),
            const SizedBox(height: 16),
            PrimaryButton(
              text: 'Save Routine',
              onTap: () async {
                Navigator.pop(ctx);
                final routineProvider = context.read<RoutineProvider>();
                await routineProvider.createRoutine(
                  name: nameController.text.trim(),
                );
                final routine = routineProvider.routines.first;
                for (final ex in workout.exercises) {
                  await routineProvider.addExerciseToRoutine(
                    exerciseId: ex.exerciseId,
                  );
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Routine saved!'),
                      backgroundColor: kGreen,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Delete
  Future<void> _deleteWorkout(String workoutId) async {
    final confirmed = await AppDialog.show<bool>(
      context: context,
      title: 'Delete Workout?',
      message: 'This workout will be permanently deleted.',
      actions: [
        const AppDialogAction(label: 'Cancel', value: false, color: kPrimary),
        const AppDialogAction(label: 'Delete', value: true, color: kRed),
      ],
    );
    if (confirmed != true) return;
    await context.read<WorkoutProvider>().deleteWorkout(workoutId);
    if (mounted) context.read<HistoryProvider>().fetchAll();
  }

  void _openDetail(context, workout) async {
    final deleted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => WorkoutDetailScreen(workout: workout)),
    );
    if (deleted == true && mounted) {
      await _deleteWorkout(workout.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: kBackground,
          appBar: AppTopBar(
            title: 'History',
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => provider.setSearching(!provider.isSearching),
                  child: Icon(
                    provider.isSearching ? Icons.close : Icons.search,
                    color: kTextDark,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: provider.isSearching
                ? _buildSearch(provider)
                : _buildCalendarView(provider),
          ),
        );
      },
    );
  }

  // ── Search view ──────────────────────────────────
  Widget _buildSearch(HistoryProvider provider) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(fontSize: 14, color: kTextDark),
              decoration: const InputDecoration(
                hintText: 'Search workouts...',
                hintStyle: TextStyle(fontSize: 14, color: kTextGrey),
                prefixIcon: Icon(Icons.search, color: kTextGrey, size: 20),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
              onChanged: (q) => provider.search(q),
            ),
          ),
        ),
        Expanded(
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.searchResults.isEmpty
              ? EmptyState(
                  icon: Icons.search_off_rounded,
                  title: _searchController.text.isEmpty
                      ? 'Start typing to search'
                      : 'No workouts found',
                  subtitle: _searchController.text.isEmpty
                      ? 'Search by workout name'
                      : 'Try a different search term',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: provider.searchResults.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final workout = provider.searchResults[i];
                    return WorkoutHistoryCard(
                      workout: workout,
                      onTap: () => _openDetail(context, workout),
                      onEdit: () => _editWorkout(workout),
                      onCopy: () => _copyWorkout(workout),
                      onSaveAsRoutine: () => _saveAsRoutine(workout),
                      onDelete: () => _deleteWorkout(workout.id),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCalendarView(HistoryProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Streak banner
        if (provider.streak != null) ...[
          StreakBanner(streak: provider.streak!),
          const SizedBox(height: 12),
        ],

        // Calendar
        HistoryCalendar(
          currentMonth: provider.currentMonth,
          workoutDates: provider.workoutDates,
          selectedDay: provider.selectedDay,
          onDaySelected: provider.selectDay,
          onPreviousMonth: provider.previousMonth,
          onNextMonth: provider.nextMonth,
        ),

        const SizedBox(height: 12),

        // Monthly stats
        if (provider.monthlyStats != null) ...[
          MonthlyStatsBar(stats: provider.monthlyStats!),
          const SizedBox(height: 20),
        ],

        // Selected day workouts
        if (provider.isLoading)
          const Center(child: CircularProgressIndicator())
        else ...[
          SectionLabel(_selectedDayLabel(provider.selectedDay)),
          const SizedBox(height: 12),

          if (provider.selectedDayWorkouts.isEmpty)
            const EmptyState(
              icon: Icons.event_available_rounded,
              title: 'No workout',
              subtitle: 'Rest day or no data for this day',
            )
          else
            ...provider.selectedDayWorkouts.map(
              (workout) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: WorkoutHistoryCard(
                  workout: workout,
                  onTap: () => _openDetail(context, workout),
                  onEdit: () => _editWorkout(workout),
                  onCopy: () => _copyWorkout(workout),
                  onSaveAsRoutine: () => _saveAsRoutine(workout),
                  onDelete: () => _deleteWorkout(workout.id),
                ),
              ),
            ),
        ],
      ],
    );
  }

  String _selectedDayLabel(DateTime day) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return '${days[day.weekday - 1]}, ${months[day.month - 1]} ${day.day}';
  }
}
