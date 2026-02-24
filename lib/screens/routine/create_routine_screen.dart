import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/routine/routine_model.dart';
import '../../models/exercise/exercise_model.dart';
import '../../providers/routine/routine_provider.dart';
import '../exercise/exericse_picker_screen.dart';

class CreateRoutineScreen extends StatefulWidget {
  final Routine? routine;

  const CreateRoutineScreen({super.key, this.routine});

  @override
  State<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  final List<Exercise> _exercises = [];

  // track which existing routine exercise ids to remove on save
  final List<String> _removedIds = [];

  bool get _isEditMode => widget.routine != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _nameController.text = widget.routine!.name;
      _descController.text = widget.routine!.description ?? '';

      for (final re in widget.routine!.exercises) {
        if (re.exercise != null) _exercises.add(re.exercise!);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a routine name.')),
      );
      return;
    }

    final provider = context.read<RoutineProvider>();

    if (_isEditMode) {
      // update name/description
      await provider.updateRoutine(
        widget.routine!.id,
        name: name,
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
      );

      // remove exercises that were deleted
      for (final id in _removedIds) {
        await provider.removeExerciseFromRoutine(id);
      }

      final existingExerciseIds = widget.routine!.exercises
          .where((re) => !_removedIds.contains(re.id))
          .map((re) => re.exerciseId)
          .toSet();

      for (final ex in _exercises) {
        if (!existingExerciseIds.contains(ex.id)) {
          await provider.addExerciseToRoutine(exerciseId: ex.id);
        }
      }
    } else {
      // create routine
      await provider.createRoutine(
        name: name,
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
      );

      // add exercises
      for (final ex in _exercises) {
        await provider.addExerciseToRoutine(exerciseId: ex.id);
      }
    }

    if (mounted) Navigator.pop(context);
  }

  void _removeExercise(int index) {
    setState(() {
      if (_isEditMode) {
        // track the routine exercise id for removal
        final routineExercises = widget.routine!.exercises
            .where((re) => re.exercise?.id == _exercises[index].id)
            .toList();
        if (routineExercises.isNotEmpty) {
          _removedIds.add(routineExercises.first.id);
        }
      }
      _exercises.removeAt(index);
    });
  }

  void _addExercises(List<Exercise> exercises) {
    setState(() {
      for (final ex in exercises) {
        // avoid duplicates
        if (!_exercises.any((e) => e.id == ex.id)) {
          _exercises.add(ex);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF212121)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditMode ? 'Edit Routine' : 'Create Routine',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF212121),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              'Save',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E88E5),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Name field
          _buildTextField(controller: _nameController, hint: 'Routine name'),
          const SizedBox(height: 8),

          // Description field
          _buildTextField(
            controller: _descController,
            hint: 'Description (optional)',
          ),
          const SizedBox(height: 20),

          // Exercises label
          if (_exercises.isNotEmpty) ...[
            Text(
              'EXERCISES (${_exercises.length})',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF9E9E9E),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),

            // Exercise list
            ..._exercises.asMap().entries.map((entry) {
              final index = entry.key;
              final exercise = entry.value;

              final parts = <String>[];
              if (exercise.category.isNotEmpty) {
                parts.add(
                  exercise.category[0].toUpperCase() +
                      exercise.category.substring(1),
                );
              }
              if (exercise.primaryMuscles.isNotEmpty) {
                parts.add(exercise.primaryMuscles.first);
              }
              final meta = parts.join(', ');

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF212121),
                              ),
                            ),
                            if (meta.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                meta,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF9E9E9E),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _removeExercise(index),
                        child: const Icon(
                          Icons.close,
                          size: 18,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 4),
          ],

          // Add Exercise button
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ExercisePickerScreen(
                  onExercisesSelected: (exercises) {
                    // Navigator.pop(context); removing the pop so no double pop
                    _addExercises(exercises);
                  },
                ),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBDBDBD), width: 1.5),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Color(0xFF1E88E5), size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Add Exercise',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E88E5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14, color: Color(0xFF212121)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
