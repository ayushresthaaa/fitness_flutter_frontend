import '../../models/exercise/custom_exercise_model.dart';
import '../../services/exercise/custom_exercise_service.dart';
import '../base/base_provider.dart';

// Manages custom exercise state
// Handles fetch, create, delete
class CustomExerciseProvider extends BaseProvider {
  final CustomExerciseService _service = CustomExerciseService();

  List<CustomExercise> _exercises = [];

  List<CustomExercise> get exercises => _exercises;

  // Load all custom exercises for the logged in user
  Future<void> fetchCustomExercises() async {
    final result = await execute(() => _service.getCustomExercises());
    if (result != null) {
      _exercises = result;
      notifyListeners();
    }
  }

  // Create a new custom exercise and prepend it to the list
  Future<CustomExercise?> createCustomExercise({
    required String name,
    required String level,
    required String category,
    String? force,
    String? mechanic,
    String? equipment,
    required List<String> primaryMuscles,
    required List<String> secondaryMuscles,
    required List<String> instructions,
    required List<String> imagePaths,
  }) async {
    final result = await execute(
      () => _service.createCustomExercise(
        name: name,
        level: level,
        category: category,
        force: force,
        mechanic: mechanic,
        equipment: equipment,
        primaryMuscles: primaryMuscles,
        secondaryMuscles: secondaryMuscles,
        instructions: instructions,
        imagePaths: imagePaths,
      ),
    );

    if (result != null) {
      _exercises.insert(0, result);
      notifyListeners();
    }

    return result;
  }

  // Delete a custom exercise by id and remove it from the list
  // DELETE
  Future<bool> deleteCustomExercise(String id) async {
    try {
      await _service.deleteCustomExercise(id);
      _exercises.removeWhere((e) => e.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Update an existing custom exercise and replace it in the list
  Future<CustomExercise?> updateCustomExercise({
    required String id,
    required String name,
    required String level,
    required String category,
    String? force,
    String? mechanic,
    String? equipment,
    required List<String> primaryMuscles,
    required List<String> secondaryMuscles,
    required List<String> instructions,
    required List<String> imagePaths,
  }) async {
    final result = await execute(
      () => _service.updateCustomExercise(
        id: id,
        name: name,
        level: level,
        category: category,
        force: force,
        mechanic: mechanic,
        equipment: equipment,
        primaryMuscles: primaryMuscles,
        secondaryMuscles: secondaryMuscles,
        instructions: instructions,
        imagePaths: imagePaths,
      ),
    );

    if (result != null) {
      // Find and replace the updated exercise in the list
      final index = _exercises.indexWhere((e) => e.id == id);
      if (index != -1) {
        _exercises[index] = result;
      }
      notifyListeners();
    }

    return result;
  }

  void reset() {
    _exercises = [];
    clearError();
    notifyListeners();
  }
}
