import 'package:flutter/material.dart';
import '../../../models/routine/routine_model.dart';
import '../../../models/routine/weekly_program_model.dart';
import '../../../widgets/common.dart';

// Bottom sheet to assign a routine to a day or set as rest
// Called from WeeklyProgramScreen when a DayPill is tapped
class RoutinePickerSheet extends StatelessWidget {
  final WeeklyProgramDay day;
  final List<Routine> routines;
  final void Function(String routineId) onRoutineSelected;
  final VoidCallback onSetRest;

  const RoutinePickerSheet({
    super.key,
    required this.day,
    required this.routines,
    required this.onRoutineSelected,
    required this.onSetRest,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        20,
        16,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            day.dayOfWeek.displayName,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: kTextDark,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pick a routine or set as rest',
            style: TextStyle(fontSize: 13, color: kTextGrey),
          ),
          const SizedBox(height: 16),

          // Routine list
          if (routines.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'No routines yet. Create one first.',
                  style: TextStyle(fontSize: 13, color: kTextGrey),
                ),
              ),
            ),

          ...routines.map((routine) {
            final isSelected = day.routineId == routine.id;
            return GestureDetector(
              onTap: () {
                Navigator.pop(context);
                onRoutineSelected(routine.id);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? kPrimaryLight : kWhite,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: isSelected ? kPrimary : kTextHint,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            routine.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? kPrimary : kTextDark,
                            ),
                          ),
                          if (routine.exercises.isNotEmpty)
                            Text(
                              '${routine.exercises.length} exercises',
                              style: const TextStyle(
                                fontSize: 12,
                                color: kTextGrey,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 8),

          // Set as rest
          DangerButton(
            text: 'Set as Rest Day',
            onTap: () {
              Navigator.pop(context);
              onSetRest();
            },
          ),
        ],
      ),
    );
  }
}
