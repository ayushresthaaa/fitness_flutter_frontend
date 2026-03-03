import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/routine/routine_model.dart';
import '../../providers/routine/routine_provider.dart';
import '../../screens/exercise/exercise_picker_screen_v2.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/common.dart';
import 'widgets/routine_exercise_card.dart';
import 'widgets/routine_hero_card.dart';
import 'widgets/routine_superset_card.dart';
import '../../screens/workout/active_workout_screen_v2.dart';

// View and edit a routine
// Hero card at top with start button
// Exercise list below for editing
// All changes save to backend immediately
class RoutineDetailScreen extends StatefulWidget {
  const RoutineDetailScreen({super.key});

  @override
  State<RoutineDetailScreen> createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends State<RoutineDetailScreen> {
  int _nextSupersetGroup = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final routine = context.read<RoutineProvider>().selectedRoutine;
      if (routine == null) return;
      final maxGroup = routine.exercises
          .map((e) => e.supersetGroup ?? 0)
          .fold(0, (a, b) => a > b ? a : b);
      setState(() => _nextSupersetGroup = maxGroup + 1);
    });
  }

  Future<void> _addExercise() async {
    final provider = context.read<RoutineProvider>();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExercisePickerScreenV2(
          onExercisesSelected: (exercises) async {
            for (final exercise in exercises) {
              await provider.addExerciseToRoutine(exerciseId: exercise.id);
            }
          },
        ),
      ),
    );
  }

  Future<void> _removeExercise(String routineExerciseId) async {
    final confirmed = await AppDialog.show<bool>(
      context: context,
      title: 'Remove Exercise?',
      message: 'This exercise will be removed from the routine.',
      actions: [
        const AppDialogAction(label: 'Cancel', value: false, color: kPrimary),
        const AppDialogAction(label: 'Remove', value: true, color: kRed),
      ],
    );
    if (confirmed != true) return;
    await context.read<RoutineProvider>().removeExerciseFromRoutine(
      routineExerciseId,
    );
  }

  Future<void> _deleteRoutine(String routineId) async {
    final confirmed = await AppDialog.show<bool>(
      context: context,
      title: 'Delete Routine?',
      message: 'This routine will be permanently deleted.',
      actions: [
        const AppDialogAction(label: 'Cancel', value: false, color: kPrimary),
        const AppDialogAction(label: 'Delete', value: true, color: kRed),
      ],
    );
    if (confirmed != true) return;
    await context.read<RoutineProvider>().deleteRoutine(routineId);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _editRoutine(Routine routine) async {
    final nameController = TextEditingController(text: routine.name);
    final descController = TextEditingController(
      text: routine.description ?? '',
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          20,
          16,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Routine',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 16),
            const SectionLabel('NAME'),
            const SizedBox(height: 8),
            AppTextField(controller: nameController, hint: 'e.g. Push Day'),
            const SizedBox(height: 12),
            const SectionLabel('DESCRIPTION (optional)'),
            const SizedBox(height: 8),
            AppTextField(
              controller: descController,
              hint: 'e.g. Chest, shoulders and triceps',
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              text: 'Save Changes',
              onTap: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(ctx);
                await context.read<RoutineProvider>().updateRoutine(
                  routine.id,
                  name: name,
                  description: descController.text.trim().isEmpty
                      ? null
                      : descController.text.trim(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pairAsSuperset(String exerciseIdA, String exerciseIdB) async {
    final provider = context.read<RoutineProvider>();
    await provider.updateRoutineExercise(
      exerciseIdA,
      supersetGroup: _nextSupersetGroup,
    );
    await provider.updateRoutineExercise(
      exerciseIdB,
      supersetGroup: _nextSupersetGroup,
    );
    setState(() => _nextSupersetGroup++);
  }

  Future<void> _unpair(List<RoutineExercise> groupExercises) async {
    final provider = context.read<RoutineProvider>();
    for (final ex in groupExercises) {
      await provider.updateRoutineExercise(ex.id, supersetGroup: 0);
    }
  }

  void _showPairPicker(String routineExerciseId, List<RoutineExercise> others) {
    if (others.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No other exercises available to pair'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Pair with...',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
          for (final ex in others)
            ListTile(
              title: Text(ex.exercise?.name ?? 'Exercise'),
              onTap: () {
                Navigator.pop(context);
                _pairAsSuperset(routineExerciseId, ex.id);
              },
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
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
          ),
        ),
      );
    }
  }

  List<Widget> _buildExerciseList(List<RoutineExercise> exercises) {
    final List<Widget> items = [];
    final Set<String> rendered = {};

    final Map<int, List<RoutineExercise>> supersetMap = {};
    for (final ex in exercises) {
      if (ex.supersetGroup != null && ex.supersetGroup! > 0) {
        supersetMap.putIfAbsent(ex.supersetGroup!, () => []).add(ex);
      }
    }

    final groupLabels = <int, String>{};
    int labelIndex = 0;
    for (final group in supersetMap.keys) {
      groupLabels[group] = String.fromCharCode(65 + labelIndex++);
    }

    for (final ex in exercises) {
      if (rendered.contains(ex.id)) continue;

      final group = ex.supersetGroup;

      if (group != null && group > 0 && supersetMap[group]!.length >= 2) {
        final paired = supersetMap[group]!;
        for (final p in paired) rendered.add(p.id);

        items.add(
          RoutineSupsetCard(
            label: groupLabels[group] ?? 'A',
            exerciseA: paired[0],
            exerciseB: paired[1],
            onRemoveA: () => _removeExercise(paired[0].id),
            onRemoveB: () => _removeExercise(paired[1].id),
            onUnpair: () => _unpair(paired),
          ),
        );
      } else {
        rendered.add(ex.id);

        final unpaired = exercises
            .where(
              (e) =>
                  e.id != ex.id &&
                  (e.supersetGroup == null || e.supersetGroup == 0),
            )
            .toList();

        items.add(
          RoutineExerciseCard(
            routineExercise: ex,
            onRemove: () => _removeExercise(ex.id),
            onLongPress: () => _showPairPicker(ex.id, unpaired),
          ),
        );
      }

      items.add(const SizedBox(height: 10));
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoutineProvider>(
      builder: (context, provider, _) {
        final routine = provider.selectedRoutine;

        if (routine == null) {
          return const Scaffold(
            backgroundColor: kBackground,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: kBackground,
          appBar: AppTopBar(
            title: routine.name,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => _editRoutine(routine),
                  child: const Icon(
                    Icons.edit_outlined,
                    color: kTextGrey,
                    size: 22,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => _deleteRoutine(routine.id),
                  child: const Icon(
                    Icons.delete_outline,
                    color: kRed,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Hero card with start button
                      RoutineHeroCard(
                        routine: routine,
                        onStart: () => _startWorkout(routine.id),
                      ),

                      const SizedBox(height: 20),

                      SectionLabel('EXERCISES (${routine.exercises.length})'),
                      const SizedBox(height: 12),

                      if (routine.exercises.isEmpty)
                        const EmptyState(
                          icon: Icons.fitness_center,
                          title: 'No exercises yet',
                          subtitle: 'Tap Add Exercise to get started',
                        ),

                      if (routine.exercises.isNotEmpty)
                        ..._buildExerciseList(routine.exercises),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: AddButton(text: 'Add Exercise', onTap: _addExercise),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
