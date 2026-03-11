import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/routine/routine_model.dart';
import '../../providers/routine/routine_provider.dart';
import '../../screens/exercise/exercise_picker_screen_v2.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/common.dart';
import 'widgets/routine_hero_card.dart';
import 'widgets/routine_exercise_list.dart';
import '../../screens/workout/active_workout_screen_v2.dart';


class RoutineDetailScreen extends StatefulWidget {
  const RoutineDetailScreen({super.key});

  @override
  State<RoutineDetailScreen> createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends State<RoutineDetailScreen> {


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
                final String name = nameController.text.trim();
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


  Future<void> _sendForReview(String routineId) async {
    final confirmed = await AppDialog.show<bool>(
      context: context,
      title: 'Send for Review?',
      message: 'Your trainer will be notified to review this routine.',
      actions: [
        const AppDialogAction(label: 'Cancel', value: false, color: kPrimary),
        const AppDialogAction(label: 'Send', value: true, color: kPrimary),
      ],
    );
    if (confirmed != true) return;
    await context.read<RoutineProvider>().sendRoutineForReview(routineId);
  }


  Future<void> _startWorkout(String routineId) async {
    final provider = context.read<RoutineProvider>();
    await provider.fetchRoutineById(routineId);

    final Routine? routine = provider.selectedRoutine;
    if (routine == null) return;

    final List<Map<String, dynamic>> prefilled = [];
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
                .map((e) => {
                      'exerciseId': e.exerciseId,
                      'name': e.exercise?.name ?? '',
                    })
                .toList(),
          ),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<RoutineProvider>(
      builder: (context, provider, _) {
        final Routine? routine = provider.selectedRoutine;

        // Show loading if routine not loaded yet
        if (routine == null) {
          return const Scaffold(
            backgroundColor: kBackground,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final bool isReadOnly = routine.createdByTrainer;

    
        final bool canSendForReview =
            isReadOnly == false && routine.reviewStatus != 'pending';

        return Scaffold(
          backgroundColor: kBackground,
          appBar: AppTopBar(
            title: routine.name,
            actions: [
              // Edit and delete only available for user-created routines
              if (isReadOnly == false) ...[
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
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Scrollable content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Hero card with start workout button
                      RoutineHeroCard(
                        routine: routine,
                        onStart: () => _startWorkout(routine.id),
                      ),

                      // Trainer notes banner - only shown if trainer left a note
                      if (routine.trainerNotes != null &&
                          routine.trainerNotes!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: kPrimaryLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    routine.trainerNotes!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: kPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 20),

                      SectionLabel(
                        'EXERCISES (${routine.exercises.length})',
                      ),
                      const SizedBox(height: 12),

                      // Exercise list - handles superset grouping internally
                      RoutineExerciseList(
                        exercises: routine.exercises,
                        isReadOnly: isReadOnly,
                      ),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),

                // Bottom buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                   
                      if (isReadOnly == false)
                        AddButton(
                          text: 'Add Exercise',
                          onTap: _addExercise,
                        ),

                      // Send for review button
                      if (canSendForReview) ...[
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () => _sendForReview(routine.id),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: kWhite,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: kPrimary),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.rate_review_outlined,
                                  size: 16,
                                  color: kPrimary,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Send for Review',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: kPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}