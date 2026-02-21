import 'package:flutter/material.dart';
import '../../../models/exercise/workout_model.dart';
import 'set_row.dart';

class WorkoutExerciseCard extends StatelessWidget {
  final WorkoutExercise workoutExercise;
  final List<SetData> sets;
  final VoidCallback onAddSet;
  final VoidCallback onInfoTap;
  final Function(int index, SetData updated) onSetChanged;
  final Function(int index) onSetToggled;
  final Function(int index) onSetRemoved;
  final List<Map<String, dynamic>> lastPerformance;
  const WorkoutExerciseCard({
    super.key,
    required this.workoutExercise,
    required this.sets,
    required this.lastPerformance,
    required this.onAddSet,
    required this.onInfoTap,
    required this.onSetChanged,
    required this.onSetToggled,
    required this.onSetRemoved,
  });

  @override
  Widget build(BuildContext context) {
    final exercise = workoutExercise.exercise;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise?.name ?? 'Exercise',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF212121),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _meta(exercise),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onInfoTap,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.menu_book_outlined,
                      size: 15,
                      color: Color(0xFF1E88E5),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF5F5F5)),

          // Column labels
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: const [
                SizedBox(width: 24, child: _Label('SET')),
                SizedBox(width: 8),
                Expanded(child: _Label('KG')),
                SizedBox(width: 8),
                Expanded(child: _Label('REPS')),
                SizedBox(width: 8),
                SizedBox(width: 34),
                SizedBox(width: 4),
                SizedBox(width: 16),
              ],
            ),
          ),

          // Set rows
          // Set rows
          ...sets.asMap().entries.map(
            (e) => SetRow(
              setNumber: e.key + 1,
              data: e.value,
              lastWeightKg: lastPerformance.length > e.key
                  ? (lastPerformance[e.key]['weightKg'] as num?)?.toDouble()
                  : null,
              lastReps: lastPerformance.length > e.key
                  ? lastPerformance[e.key]['reps'] as int?
                  : null,
              onChanged: (updated) => onSetChanged(e.key, updated),
              onToggleDone: () => onSetToggled(e.key),
              onRemove: () => onSetRemoved(e.key),
            ),
          ),

          // Add set
          GestureDetector(
            onTap: onAddSet,
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 6, 12, 12),
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 15, color: Color(0xFF1E88E5)),
                  SizedBox(width: 4),
                  Text(
                    'Add Set',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E88E5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _meta(exercise) {
    if (exercise == null) return '';
    final parts = <String>[];
    if (exercise.category.isNotEmpty) {
      parts.add(
        exercise.category[0].toUpperCase() + exercise.category.substring(1),
      );
    }
    if (exercise.primaryMuscles.isNotEmpty) {
      parts.add(exercise.primaryMuscles.first);
    }
    return parts.join(' · ');
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF9E9E9E),
        letterSpacing: 0.4,
      ),
    );
  }
}
