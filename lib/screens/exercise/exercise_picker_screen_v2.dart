import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/exercise/exercise_model.dart';
import '../../providers/exercise/exercise_provider.dart';
import '../../widgets/common.dart';
import 'widgets/exercise_search_bar_v2.dart';
import 'widgets/exercise_filter_chips_v2.dart';
import 'widgets/exercise_list_v2.dart';
import 'widgets/exercise_tray_v2.dart';

// Exercise picker screen
// Used when adding exercises to a workout or routine
// Pops itself and returns selected exercises via onExercisesSelected
class ExercisePickerScreenV2 extends StatefulWidget {
  final Function(List<Exercise>) onExercisesSelected;

  const ExercisePickerScreenV2({super.key, required this.onExercisesSelected});

  @override
  State<ExercisePickerScreenV2> createState() => _ExercisePickerScreenV2State();
}

class _ExercisePickerScreenV2State extends State<ExercisePickerScreenV2> {
  final List<Exercise> _selected = [];
  final ScrollController _scrollController = ScrollController();

  String? _search;
  String? _selectedMuscle;
  String? _selectedLevel;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Load exercises and muscle list when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<ExerciseProvider>();
      p.fetchExercises();
      p.fetchMuscles();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Load next page when user scrolls near the bottom
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ExerciseProvider>().loadMoreExercises(
        search: _search,
        muscleGroup: _selectedMuscle,
        level: _selectedLevel,
      );
    }
  }

  // Re-fetch with current filters applied
  void _applyFilters() {
    context.read<ExerciseProvider>().fetchExercises(
      search: _search,
      muscleGroup: _selectedMuscle,
      level: _selectedLevel,
    );
  }

  void _onSearchChanged(String value) {
    setState(() => _search = value.isEmpty ? null : value);
    _applyFilters();
  }

  void _onMuscleChanged(String? value) {
    setState(() => _selectedMuscle = value);
    _applyFilters();
  }

  void _onLevelChanged(String? value) {
    setState(() => _selectedLevel = value);
    _applyFilters();
  }

  // Add or remove exercise from selected list
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

  // Pass selected back to caller and close screen
  void _confirm() {
    widget.onExercisesSelected(_selected);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final muscles = context.watch<ExerciseProvider>().muscles;

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppTopBar(title: 'Add Exercises'),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: ExerciseSearchBarV2(onChanged: _onSearchChanged),
            ),

            const SizedBox(height: 10),
            // Muscle group filter chips
            ExerciseFilterChipsV2(
              options: muscles,
              selected: _selectedMuscle,
              onSelected: _onMuscleChanged,
            ),

            const SizedBox(
              height: 10,
            ), //this is a bit hacky but adds spacing between the two chip rows
            // Level filter chips
            ExerciseFilterChipsV2(
              options: const ['beginner', 'intermediate', 'expert'],
              selected: _selectedLevel,
              onSelected: _onLevelChanged,
            ),

            const SizedBox(height: 4),

            // Exercise list takes remaining space
            Expanded(
              child: ExerciseListV2(
                selected: _selected,
                scrollController: _scrollController,
                onTap: _toggleExercise,
              ),
            ),

            // Bottom tray only shows when something is selected
            if (_selected.isNotEmpty)
              ExerciseTrayV2(
                selected: _selected,
                onRemove: _toggleExercise,
                onConfirm: _confirm,
              ),
          ],
        ),
      ),
    );
  }
}
