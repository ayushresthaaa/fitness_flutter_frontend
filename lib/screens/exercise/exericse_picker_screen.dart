import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/exercise/exercise_model.dart';
import '../../providers/exercise/exercise_provider.dart';
import 'widgets/exercise_search_bar.dart';
import 'widgets/exercise_filter_chips.dart';
import 'widgets/exercise_list.dart';
import 'widgets/exercise_tray.dart';

class ExercisePickerScreen extends StatefulWidget {
  final Function(List<Exercise>) onExercisesSelected;

  const ExercisePickerScreen({super.key, required this.onExercisesSelected});

  @override
  State<ExercisePickerScreen> createState() => _ExercisePickerScreenState();
}

class _ExercisePickerScreenState extends State<ExercisePickerScreen> {
  final List<Exercise> _selected = [];
  String? _search;
  String? _selectedMuscle;
  String? _selectedLevel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ExerciseProvider>();
      provider.fetchExercises();
      provider.fetchMuscles();
    });
  }

  void _onSearchChanged(String value) {
    setState(() => _search = value.isEmpty ? null : value);
    _fetchWithFilters();
  }

  void _onMuscleChanged(String? value) {
    setState(() => _selectedMuscle = value);
    _fetchWithFilters();
  }

  void _onLevelChanged(String? value) {
    setState(() => _selectedLevel = value);
    _fetchWithFilters();
  }

  void _fetchWithFilters() {
    context.read<ExerciseProvider>().fetchExercises(
      search: _search,
      muscleGroup: _selectedMuscle,
      level: _selectedLevel,
    );
  }

  void _toggleExercise(Exercise exercise) {
    setState(() {
      final exists = _selected.any((e) => e.id == exercise.id);
      if (exists) {
        _selected.removeWhere((e) => e.id == exercise.id);
      } else {
        _selected.add(exercise);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final muscles = context.watch<ExerciseProvider>().muscles;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Exercises',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: ExerciseSearchBar(onChanged: _onSearchChanged),
          ),

          // Filters
          ExerciseFilterChips(
            label: 'Muscle Group',
            options: muscles,
            selected: _selectedMuscle,
            onSelected: _onMuscleChanged,
          ),
          const SizedBox(height: 8),
          ExerciseFilterChips(
            label: 'Level',
            options: const ['beginner', 'intermediate', 'expert'],
            selected: _selectedLevel,
            onSelected: _onLevelChanged,
          ),
          const SizedBox(height: 8),

          // List
          Expanded(
            child: ExerciseList(
              selectedExercises: _selected,
              search: _search,
              selectedMuscle: _selectedMuscle,
              selectedLevel: _selectedLevel,
              onExerciseTap: _toggleExercise,
              onExerciseAdd: _toggleExercise,
            ),
          ),

          // Bottom tray
          SelectedExercisesTray(
            selectedExercises: _selected,
            onConfirm: () {
              widget.onExercisesSelected(_selected);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
