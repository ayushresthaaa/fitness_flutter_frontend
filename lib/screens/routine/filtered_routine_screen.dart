import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/routine/routine_model.dart';
import '../../providers/routine/routine_provider.dart';
import '../../providers/auth/auth_provider.dart';
import '../../widgets/common.dart';
import 'create_routine_screen.dart';
import 'routine_detail_screenV2.dart';
import 'widgets/routine_card.dart';
import '../workout/active_workout_screen_v2.dart';

class FilteredRoutineScreen extends StatelessWidget {
  final String filter;
  final VoidCallback? onWorkoutComplete;

  const FilteredRoutineScreen({
    super.key,
    required this.filter,
    this.onWorkoutComplete,
  });

  String _getTitle() {
    if (filter == 'mine') return 'My Routines';
    if (filter == 'trainer') return 'From Trainer';
    if (filter == 'reviewed') return 'Reviewed by Trainer';
    if (filter == 'ai') return 'AI Generated';
    return 'Routines';
  }

  String _getEmptyTitle() {
    if (filter == 'mine') return 'No routines yet';
    if (filter == 'trainer') return 'No trainer routines yet';
    if (filter == 'reviewed') return 'No reviewed routines yet';
    if (filter == 'ai') return 'No AI routines yet';
    return 'No routines found';
  }

  String _getEmptySubtitle() {
    if (filter == 'mine') return 'Tap + to create your first routine';
    if (filter == 'trainer')
      return 'Your trainer has not assigned any routines yet';
    if (filter == 'reviewed')
      return 'Send a routine for review to get feedback from your trainer';
    if (filter == 'ai') return 'Generate a routine from your profile';
    return '';
  }

  List<Routine> _getFilteredRoutines(List<Routine> allRoutines) {
    if (filter == 'mine') {
      return allRoutines
          .where((r) => r.createdByTrainer == false && r.isAIGenerated == false)
          .toList();
    } else if (filter == 'trainer') {
      return allRoutines.where((r) => r.createdByTrainer == true).toList();
    } else if (filter == 'reviewed') {
      return allRoutines.where((r) => r.reviewStatus == 'reviewed').toList();
    } else if (filter == 'ai') {
      return allRoutines.where((r) => r.isAIGenerated == true).toList();
    }
    return allRoutines;
  }

  void _createRoutine(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateRoutineScreen()),
    );
    if (context.mounted) {
      context.read<RoutineProvider>().fetchRoutines();
    }
  }

  Future<void> _startWorkout(BuildContext context, String routineId) async {
    final provider = context.read<RoutineProvider>();
    await provider.fetchRoutineById(routineId);

    final routine = provider.selectedRoutine;
    if (routine == null) return;

    final List<Map<String, dynamic>> prefilled = [];
    for (final re in routine.exercises) {
      if (re.exercise == null) continue;
      final String localId =
          '${re.exerciseId}_${DateTime.now().millisecondsSinceEpoch}';
      prefilled.add({
        'localId': localId,
        'exercise': re.exercise!,
        'supersetGroup': re.supersetGroup,
        'sets': re.sets,
      });
    }

    if (context.mounted) {
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
            onWorkoutComplete: onWorkoutComplete,
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
        title: _getTitle(),
        actions: [
          // Show + button for mine filter
          if (filter == 'mine')
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () => _createRoutine(context),
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

          // Show generate button in app bar for ai filter
          if (filter == 'ai')
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _GenerateButton(),
            ),
        ],
      ),
      body: Consumer<RoutineProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.routines.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<Routine> filteredRoutines = _getFilteredRoutines(
            provider.routines,
          );

          // Show AI empty state with generate button
          if (filteredRoutines.isEmpty) {
            if (filter == 'ai') {
              return const _AIEmptyState();
            }
            return EmptyState(
              icon: Icons.list_alt_rounded,
              title: _getEmptyTitle(),
              subtitle: _getEmptySubtitle(),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filteredRoutines.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, index) {
              final Routine routine = filteredRoutines[index];

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
                  if (context.mounted) {
                    context.read<RoutineProvider>().fetchRoutines();
                  }
                },
                onStart: () => _startWorkout(context, routine.id),
              );
            },
          );
        },
      ),
    );
  }
}

// Generate button shown in the app bar when routines already exist
class _GenerateButton extends StatefulWidget {
  const _GenerateButton();

  @override
  State<_GenerateButton> createState() => _GenerateButtonState();
}

class _GenerateButtonState extends State<_GenerateButton> {
  bool _isGenerating = false;

  Future<void> _generate() async {
    final authProvider = context.read<AuthProvider>();
    final routineProvider = context.read<RoutineProvider>();

    if (authProvider.user?.plan != 'pro') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upgrade to Pro to generate AI routines')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    final success = await routineProvider.generateRoutine();

    if (mounted) {
      setState(() {
        _isGenerating = false;
      });

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              routineProvider.error ?? 'Failed to generate routine',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isGenerating ? null : _generate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: kPrimary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: _isGenerating
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(color: kWhite, strokeWidth: 2),
              )
            : const Row(
                children: [
                  Icon(Icons.auto_awesome, color: kWhite, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Generate',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kWhite,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// Empty state shown when no AI routines exist yet
class _AIEmptyState extends StatefulWidget {
  const _AIEmptyState();

  @override
  State<_AIEmptyState> createState() => _AIEmptyStateState();
}

class _AIEmptyStateState extends State<_AIEmptyState> {
  bool _isGenerating = false;

  Future<void> _generate() async {
    final authProvider = context.read<AuthProvider>();
    final routineProvider = context.read<RoutineProvider>();

    if (authProvider.user?.plan != 'pro') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upgrade to Pro to generate AI routines')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    final success = await routineProvider.generateRoutine();

    if (mounted) {
      setState(() {
        _isGenerating = false;
      });

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              routineProvider.error ?? 'Failed to generate routine',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, size: 48, color: kTextHint),
            const SizedBox(height: 12),
            const Text(
              'No AI routines yet',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: kTextGrey,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Generate a personalized routine based on your fitness profile',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: kTextHint),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Generate Routine',
              isLoading: _isGenerating,
              onTap: _isGenerating ? null : _generate,
            ),
          ],
        ),
      ),
    );
  }
}
