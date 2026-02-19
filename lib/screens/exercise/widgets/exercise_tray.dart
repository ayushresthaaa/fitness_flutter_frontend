import 'package:flutter/material.dart';
import '../../../models/exercise/exercise_model.dart';

class SelectedExercisesTray extends StatelessWidget {
  final List<Exercise> selectedExercises;
  final VoidCallback onConfirm;

  const SelectedExercisesTray({
    super.key,
    required this.selectedExercises,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedExercises.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${selectedExercises.length} ${selectedExercises.length == 1 ? 'exercise' : 'exercises'} selected',
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Add to Workout',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
