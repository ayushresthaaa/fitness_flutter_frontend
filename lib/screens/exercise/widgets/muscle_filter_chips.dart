import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/exercise/exercise_provider.dart';

class MuscleFilterChips extends StatelessWidget {
  final String? selectedMuscle;
  final Function(String?) onMuscleSelected;

  const MuscleFilterChips({
    required this.selectedMuscle,
    required this.onMuscleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ExerciseProvider>(
      builder: (context, provider, child) {
        if (provider.muscles.isEmpty) {
          return SizedBox.shrink();
        }

        return Container(
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildChip(
                'All',
                selectedMuscle == null,
                () => onMuscleSelected(null),
              ),
              ...provider.muscles.map((muscle) {
                return _buildChip(
                  _formatMuscle(muscle),
                  selectedMuscle == muscle,
                  () => onMuscleSelected(muscle),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.grey[200],
        selectedColor: Colors.blue[100],
        labelStyle: TextStyle(
          color: isSelected ? Colors.blue[700] : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  String _formatMuscle(String muscle) {
    return muscle[0].toUpperCase() + muscle.substring(1).replaceAll('_', ' ');
  }
}
