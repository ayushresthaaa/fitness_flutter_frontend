import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/routine/routine_provider.dart';
import '../../widgets/common.dart';
import 'create_routine_screen.dart';
import 'routine_detail_screen.dart';
import 'widgets/routine_card.dart';
import '../../screens/workout/active_workout_screen_v2.dart';

// Shows all user routines
// Tap card to open detail screen
// Start button to begin workout immediately from routine
// Plus button to create new routine
class RoutineListScreen extends StatefulWidget {
  const RoutineListScreen({super.key});

  @override
  State<RoutineListScreen> createState() => _RoutineListScreenState();
}

class _RoutineListScreenState extends State<RoutineListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoutineProvider>().fetchRoutines();
    });
  }

  void _createRoutine() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateRoutineScreen()),
    );
    // Refresh list when coming back
    if (mounted) {
      context.read<RoutineProvider>().fetchRoutines();
    }
  }

  Future<void> _startWorkout(String routineId) async {
    final provider = context.read<RoutineProvider>();
    await provider.fetchRoutineById(routineId);
    final routine = provider.selectedRoutine;
    if (routine == null) return;

    final prefilled = <Map<String, dynamic>>[];
    for (final re in routine.exercises) {
      if (re.exercise == null) continue;
      final localId =
          '${re.exerciseId}_${DateTime.now().millisecondsSinceEpoch}';
      prefilled.add({
        'localId': localId,
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
            routineId: routine.id, // add
            originalExercises: routine.exercises
                .map(
                  (e) => {
                    'exerciseId': e.exerciseId,
                    'name': e.exercise?.name ?? '',
                  },
                )
                .toList(), // add
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppTopBar(
        title: 'Routines',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: _createRoutine,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: kPrimary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add, color: kWhite, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<RoutineProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.routines.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.routines.isEmpty) {
            return const EmptyState(
              icon: Icons.list_alt_rounded,
              title: 'No routines yet',
              subtitle: 'Tap + to create your first routine',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.routines.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final routine = provider.routines[i];
              return RoutineCard(
                routine: routine,
                onTap: () async {
                  provider.fetchRoutineById(routine.id);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RoutineDetailScreen(),
                    ),
                  );
                  // Refresh list when coming back
                  if (mounted) {
                    context.read<RoutineProvider>().fetchRoutines();
                  }
                },
                onStart: () => _startWorkout(routine.id),
              );
            },
          );
        },
      ),
    );
  }
}
