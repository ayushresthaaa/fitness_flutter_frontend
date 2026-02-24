import 'package:flutter/material.dart';
import '../../../models/exercise/exercise_model.dart';
import '../../../widgets/common.dart';

// Bottom tray that appears when exercises are selected
// Shows selected exercise pills and confirm button
class ExerciseTrayV2 extends StatelessWidget {
  final List<Exercise> selected;
  final ValueChanged<Exercise> onRemove;
  final VoidCallback onConfirm;

  const ExerciseTrayV2({
    super.key,
    required this.selected,
    required this.onRemove,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: const BoxDecoration(
        color: kWhite,
        border: Border(top: BorderSide(color: kDivider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Scrollable row of selected exercise pills
          SizedBox(
            height: 30,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: selected.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) => _Pill(
                label: selected[i].name,
                onRemove: () => onRemove(selected[i]),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Confirm button — shows count of selected exercises
          PrimaryButton(
            text:
                'Add ${selected.length} Exercise${selected.length > 1 ? 's' : ''}',
            onTap: onConfirm,
          ),
        ],
      ),
    );
  }
}

// Single pill showing exercise name with a remove button
class _Pill extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _Pill({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: kPrimaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: kPrimary,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 13, color: kPrimary),
          ),
        ],
      ),
    );
  }
}
