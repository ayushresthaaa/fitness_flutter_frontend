import 'package:flutter/material.dart';
import '../../../../widgets/common.dart';

class CreateExerciseDropdowns extends StatelessWidget {
  final String? selectedLevel;
  final String? selectedCategory;
  final String? selectedForce;
  final String? selectedMechanic;
  final String? selectedEquipment;

  final ValueChanged<String?> onLevelChanged;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onForceChanged;
  final ValueChanged<String?> onMechanicChanged;
  final ValueChanged<String?> onEquipmentChanged;

  const CreateExerciseDropdowns({
    super.key,
    required this.selectedLevel,
    required this.selectedCategory,
    required this.selectedForce,
    required this.selectedMechanic,
    required this.selectedEquipment,
    required this.onLevelChanged,
    required this.onCategoryChanged,
    required this.onForceChanged,
    required this.onMechanicChanged,
    required this.onEquipmentChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Level and Category side by side
        Row(
          children: [
            Expanded(
              child: _DropdownField(
                label: 'LEVEL',
                hint: 'Select level',
                value: selectedLevel,
                options: const ['beginner', 'intermediate', 'expert'],
                onChanged: onLevelChanged,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DropdownField(
                label: 'CATEGORY',
                hint: 'Select category',
                value: selectedCategory,
                options: const [
                  'cardio',
                  'olympic_weightlifting',
                  'plyometrics',
                  'powerlifting',
                  'strength',
                  'stretching',
                  'strongman',
                ],
                onChanged: onCategoryChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: _DropdownField(
                label: 'FORCE (OPTIONAL)',
                hint: 'Select force',
                value: selectedForce,
                options: const ['pull', 'push', 'static'],
                onChanged: onForceChanged,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DropdownField(
                label: 'MECHANIC (OPTIONAL)',
                hint: 'Select mechanic',
                value: selectedMechanic,
                options: const ['compound', 'isolation'],
                onChanged: onMechanicChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Equipment full width
        _DropdownField(
          label: 'EQUIPMENT (OPTIONAL)',
          hint: 'Select equipment',
          value: selectedEquipment,
          options: const [
            'body_only',
            'machine',
            'other',
            'foam_roll',
            'kettlebells',
            'dumbbell',
            'cable',
            'barbell',
            'bands',
            'medicine_ball',
            'exercise_ball',
            'e_z_curl_bar',
          ],
          onChanged: onEquipmentChanged,
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.hint,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(
                hint,
                style: const TextStyle(color: kTextGrey, fontSize: 14),
              ),
              isExpanded: true,
              items: options.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(
                    option.replaceAll('_', ' '),
                    style: const TextStyle(fontSize: 14, color: kTextDark),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
