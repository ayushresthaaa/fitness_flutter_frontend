import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../providers/exercise/custom_exercise_provider.dart';
import '../../../widgets/common.dart';
import 'widgets/create_exercise_name_field.dart';
import 'widgets/create_exercise_dropdowns.dart';
import 'widgets/create_exercise_muscle_chips.dart';
import 'widgets/create_exercise_instructions.dart';
import 'widgets/create_exercise_image_picker.dart';
import '../../../models/exercise/custom_exercise_model.dart';

class CreateCustomExerciseScreen extends StatefulWidget {
  final CustomExercise? exercise;
  const CreateCustomExerciseScreen({super.key, this.exercise});

  @override
  State<CreateCustomExerciseScreen> createState() =>
      _CreateCustomExerciseScreenState();
}

class _CreateCustomExerciseScreenState
    extends State<CreateCustomExerciseScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _instructionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? _selectedLevel;
  String? _selectedCategory;
  String? _selectedForce;
  String? _selectedMechanic;
  String? _selectedEquipment;

  final List<String> _primaryMuscles = [];
  final List<String> _secondaryMuscles = [];
  final List<String> _instructions = [];
  final List<String> _imagePaths = [];
  @override
  void initState() {
    super.initState();

    // If editing, prefill all fields with existing values
    if (widget.exercise != null) {
      final e = widget.exercise!;
      _nameController.text = e.name;
      _selectedLevel = e.level;
      _selectedCategory = e.category;
      _selectedForce = e.force;
      _selectedMechanic = e.mechanic;
      _selectedEquipment = e.equipment;
      _primaryMuscles.addAll(e.primaryMuscles);
      _secondaryMuscles.addAll(e.secondaryMuscles);
      _instructions.addAll(e.instructions);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _instructionController.dispose();
    super.dispose();
  }

  void _togglePrimaryMuscle(String muscle) {
    setState(() {
      if (_primaryMuscles.contains(muscle)) {
        _primaryMuscles.remove(muscle);
      } else {
        _primaryMuscles.add(muscle);
      }
    });
  }

  void _toggleSecondaryMuscle(String muscle) {
    setState(() {
      if (_secondaryMuscles.contains(muscle)) {
        _secondaryMuscles.remove(muscle);
      } else {
        _secondaryMuscles.add(muscle);
      }
    });
  }

  void _addInstruction() {
    final text = _instructionController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _instructions.add(text);
      _instructionController.clear();
    });
  }

  void _removeInstruction(int index) {
    setState(() {
      _instructions.removeAt(index);
    });
  }

  Future<void> _pickImages() async {
    if (_imagePaths.length >= 5) {
      _showMessage('Maximum 5 images allowed');
      return;
    }

    final List<XFile> picked = await _picker.pickMultiImage();
    if (picked.isEmpty) return;

    final int remaining = 5 - _imagePaths.length;
    setState(() {
      for (int i = 0; i < picked.length && i < remaining; i++) {
        _imagePaths.add(picked[i].path);
      }
    });
  }

  void _removeImage(int index) {
    setState(() {
      _imagePaths.removeAt(index);
    });
  }

  bool _validate() {
    if (_nameController.text.trim().isEmpty) {
      _showMessage('Exercise name is required');
      return false;
    }
    if (_selectedLevel == null) {
      _showMessage('Level is required');
      return false;
    }
    if (_selectedCategory == null) {
      _showMessage('Category is required');
      return false;
    }
    if (_primaryMuscles.isEmpty) {
      _showMessage('Select at least one primary muscle');
      return false;
    }
    if (_instructions.isEmpty) {
      _showMessage('Add at least one instruction');
      return false;
    }
    return true;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    if (!_validate()) return;

    final provider = context.read<CustomExerciseProvider>();

    if (widget.exercise != null) {
      final result = await provider.updateCustomExercise(
        id: widget.exercise!.id,
        name: _nameController.text.trim(),
        level: _selectedLevel!,
        category: _selectedCategory!,
        force: _selectedForce,
        mechanic: _selectedMechanic,
        equipment: _selectedEquipment,
        primaryMuscles: _primaryMuscles,
        secondaryMuscles: _secondaryMuscles,
        instructions: _instructions,
        imagePaths: _imagePaths,
      );

      if (result != null) {
        Navigator.pop(context, result);
      } else {
        _showMessage(provider.error ?? 'Failed to update exercise');
      }
    } else {
      final result = await provider.createCustomExercise(
        name: _nameController.text.trim(),
        level: _selectedLevel!,
        category: _selectedCategory!,
        force: _selectedForce,
        mechanic: _selectedMechanic,
        equipment: _selectedEquipment,
        primaryMuscles: _primaryMuscles,
        secondaryMuscles: _secondaryMuscles,
        instructions: _instructions,
        imagePaths: _imagePaths,
      );

      if (result != null) {
        Navigator.pop(context, result);
      } else {
        _showMessage(provider.error ?? 'Failed to create exercise');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomExerciseProvider>();

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppTopBar(
        title: widget.exercise != null ? 'Edit Exercise' : 'Create Exercise',
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CreateExerciseNameField(controller: _nameController),
          const SizedBox(height: 20),

          CreateExerciseDropdowns(
            selectedLevel: _selectedLevel,
            selectedCategory: _selectedCategory,
            selectedForce: _selectedForce,
            selectedMechanic: _selectedMechanic,
            selectedEquipment: _selectedEquipment,
            onLevelChanged: (value) => setState(() => _selectedLevel = value),
            onCategoryChanged: (value) =>
                setState(() => _selectedCategory = value),
            onForceChanged: (value) => setState(() => _selectedForce = value),
            onMechanicChanged: (value) =>
                setState(() => _selectedMechanic = value),
            onEquipmentChanged: (value) =>
                setState(() => _selectedEquipment = value),
          ),
          const SizedBox(height: 20),

          CreateExerciseMuscleChips(
            label: 'PRIMARY MUSCLES',
            selected: _primaryMuscles,
            onTap: _togglePrimaryMuscle,
          ),
          const SizedBox(height: 20),

          CreateExerciseMuscleChips(
            label: 'SECONDARY MUSCLES (OPTIONAL)',
            selected: _secondaryMuscles,
            onTap: _toggleSecondaryMuscle,
          ),
          const SizedBox(height: 20),

          CreateExerciseInstructions(
            controller: _instructionController,
            instructions: _instructions,
            onAdd: _addInstruction,
            onRemove: _removeInstruction,
          ),
          const SizedBox(height: 20),

          CreateExerciseImagePicker(
            imagePaths: _imagePaths,
            onPick: _pickImages,
            onRemove: _removeImage,
          ),
          const SizedBox(height: 32),

          PrimaryButton(
            text: widget.exercise != null ? 'Save Changes' : 'Create Exercise',
            onTap: _submit,
            isLoading: provider.isLoading,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
