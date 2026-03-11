import 'package:flutter/material.dart';
import '../../../models/routine/routine_model.dart';
import '../../../widgets/common.dart';
import 'routine_exercise_card.dart';

// Wraps two paired exercises in a superset group
class RoutineSupsetCard extends StatelessWidget {
  final String label;
  final RoutineExercise exerciseA;
  final RoutineExercise exerciseB;
  final VoidCallback onRemoveA;
  final VoidCallback onRemoveB;
  final VoidCallback? onUnpair;

  const RoutineSupsetCard({
    super.key,
    required this.label,
    required this.exerciseA,
    required this.exerciseB,
    required this.onRemoveA,
    required this.onRemoveB,
    this.onUnpair,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: kPrimary, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Superset label, unpair button (hidden in readonly mode)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Row(
              children: [
                // Superset label chip
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

                
                if (onUnpair != null)
                  GestureDetector(
                    onTap: onUnpair,
                    child: const Text(
                      'Unpair',
                      style: TextStyle(
                        fontSize: 12,
                        color: kTextGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(14, 8, 14, 0),
            child: Divider(height: 1, color: kDivider),
          ),

          // Exercise A
          RoutineExerciseCard(
            routineExercise: exerciseA,
            onRemove: onRemoveA,
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Divider(height: 1, color: kDivider),
          ),

          // Exercise B
          RoutineExerciseCard(
            routineExercise: exerciseB,
            onRemove: onRemoveB,
          ),
        ],
      ),
    );
  }
}