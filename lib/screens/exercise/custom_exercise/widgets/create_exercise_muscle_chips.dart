import 'package:flutter/material.dart';
import '../../../../widgets/common.dart';

class CreateExerciseMuscleChips extends StatelessWidget {
  final String label;
  final List<String> selected;
  final ValueChanged<String> onTap;

  const CreateExerciseMuscleChips({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  static const List<String> muscles = [
    'abdominals',
    'abductors',
    'adductors',
    'biceps',
    'calves',
    'chest',
    'forearms',
    'glutes',
    'hamstrings',
    'lats',
    'lower_back',
    'middle_back',
    'neck',
    'quadriceps',
    'shoulders',
    'traps',
    'triceps',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: muscles.map((muscle) {
            final isSelected = selected.contains(muscle);
            return GestureDetector(
              onTap: () => onTap(muscle),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? kPrimary : kWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? kPrimary : kTextHint),
                ),
                child: Text(
                  muscle.replaceAll('_', ' '),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? kWhite : kTextDark,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
