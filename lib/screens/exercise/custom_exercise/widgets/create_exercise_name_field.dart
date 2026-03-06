import 'package:flutter/material.dart';
import '../../../../widgets/common.dart';

// Simple name input field for the create exercise form
class CreateExerciseNameField extends StatelessWidget {
  final TextEditingController controller;

  const CreateExerciseNameField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('EXERCISE NAME'),
        const SizedBox(height: 8),
        AppTextField(controller: controller, hint: 'e.g. Cable Curl'),
      ],
    );
  }
}
