import 'package:flutter/material.dart';
import '../../../../models/exercise/exercise_model.dart';
import '../../../../widgets/common.dart';
import 'active_set_model.dart';
import 'exercise_set_card_v2.dart';

// Wraps two exercises in a superset group

class SupersetCardV2 extends StatelessWidget {
  final String label; // A B C
  final Exercise exerciseA;
  final List<ActiveSet> setsA;
  final List<Map<String, dynamic>> lastPerfA;
  final VoidCallback onAddSetA;
  final VoidCallback onAddWarmupSetA;
  final VoidCallback onRemoveExerciseA;
  final Function(int) onSetCompletedA;
  final Function(int) onSetRemovedA;
  final Function(int, ActiveSet) onSetChangedA;

  final Exercise exerciseB;
  final List<ActiveSet> setsB;
  final List<Map<String, dynamic>> lastPerfB;
  final VoidCallback onAddSetB;
  final VoidCallback onAddWarmupSetB;
  final VoidCallback onRemoveExerciseB;
  final Function(int) onSetCompletedB;
  final Function(int) onSetRemovedB;
  final Function(int, ActiveSet) onSetChangedB;

  final VoidCallback onUnpair; // long press to remove superset

  const SupersetCardV2({
    super.key,
    required this.label,
    required this.exerciseA,
    required this.setsA,
    required this.lastPerfA,
    required this.onAddSetA,
    required this.onAddWarmupSetA,
    required this.onRemoveExerciseA,
    required this.onSetCompletedA,
    required this.onSetRemovedA,
    required this.onSetChangedA,
    required this.exerciseB,
    required this.setsB,
    required this.lastPerfB,
    required this.onAddSetB,
    required this.onAddWarmupSetB,
    required this.onRemoveExerciseB,
    required this.onSetCompletedB,
    required this.onSetRemovedB,
    required this.onSetChangedB,
    required this.onUnpair,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: kPrimary, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Superset label + unpair button
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: kPrimaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Superset $label',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: kPrimary,
                    ),
                  ),
                ),
                const Spacer(),
                // Unpair button
                GestureDetector(
                  onTap: onUnpair,
                  child: const Text(
                    'Unpair',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9E9E9E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Divider between label and first exercise
          const Padding(
            padding: EdgeInsets.fromLTRB(14, 8, 14, 0),
            child: Divider(height: 1, color: Color(0xFFF0F0F0)),
          ),

          // Exercise A
          ExerciseSetCardV2(
            exercise: exerciseA,
            sets: setsA,
            lastPerformance: lastPerfA,
            onAddSet: onAddSetA,
            onAddWarmupSet: onAddWarmupSetA,
            onRemoveExercise: onRemoveExerciseA,
            onSetCompleted: onSetCompletedA,
            onSetRemoved: onSetRemovedA,
            onSetChanged: onSetChangedA,
            showBackground: false,
          ),

          // Divider between exercises
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Divider(height: 1, color: Color(0xFFF0F0F0)),
          ),

          // Exercise B
          ExerciseSetCardV2(
            exercise: exerciseB,
            sets: setsB,
            lastPerformance: lastPerfB,
            onAddSet: onAddSetB,
            onAddWarmupSet: onAddWarmupSetB,
            onRemoveExercise: onRemoveExerciseB,
            onSetCompleted: onSetCompletedB,
            onSetRemoved: onSetRemovedB,
            onSetChanged: onSetChangedB,
            showBackground: false,
          ),
        ],
      ),
    );
  }
}
