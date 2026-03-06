import 'package:flutter/material.dart';
import '../../../../widgets/common.dart';

class CreateExerciseInstructions extends StatelessWidget {
  final TextEditingController controller;
  final List<String> instructions;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const CreateExerciseInstructions({
    super.key,
    required this.controller,
    required this.instructions,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('INSTRUCTIONS'),
        const SizedBox(height: 8),

        // Existing steps
        for (int i = 0; i < instructions.length; i++)
          _InstructionRow(index: i, text: instructions[i], onRemove: onRemove),

        const SizedBox(height: 8),

        // Add new step row
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: controller,
                hint: 'Add a step...',
                maxLines: 2,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: kPrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add, color: kWhite),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Single instruction row with step number and remove button
class _InstructionRow extends StatelessWidget {
  final int index;
  final String text;
  final ValueChanged<int> onRemove;

  const _InstructionRow({
    required this.index,
    required this.text,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Step number circle
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: kPrimaryLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: kPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: kTextDark),
            ),
          ),
          GestureDetector(
            onTap: () => onRemove(index),
            child: const Icon(Icons.close, size: 18, color: kTextGrey),
          ),
        ],
      ),
    );
  }
}
