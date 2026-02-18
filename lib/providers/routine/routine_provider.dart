import '../../models/routine/routine_model.dart';
import '../../services/routine/routine_service.dart';
import '../base/base_provider.dart';
import '../../models/exercise/workout_model.dart';

class RoutineProvider extends BaseProvider {
  final RoutineService _service = RoutineService();

  List<Routine> _routines = [];
  Routine? _selectedRoutine;

  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  int _total = 0;
  bool _hasMore = true;

  // Getters
  List<Routine> get routines => _routines;
  Routine? get selectedRoutine => _selectedRoutine;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get total => _total;
  bool get hasMore => _hasMore;

  // Create new routine
  Future<void> createRoutine({
    required String name,
    String? description,
    bool? isPublic,
  }) async {
    final result = await execute(
      () => _service.createRoutine(
        name: name,
        description: description,
        isPublic: isPublic,
      ),
    );

    if (result != null) {
      _routines.insert(0, result);
      _selectedRoutine = result;
      notifyListeners();
    }
  }

  // Fetch user's routines
  Future<void> fetchRoutines({
    int page = 1,
    int limit = 10,
    bool loadMore = false,
  }) async {
    final result = await execute(
      () => _service.getRoutines(page: page, limit: limit),
    );

    if (result != null) {
      final List<Routine> newRoutines = result['routines'];

      if (loadMore) {
        _routines.addAll(newRoutines);
      } else {
        _routines = newRoutines;
      }

      final pagination = result['pagination'];
      _currentPage = pagination['page'];
      _totalPages = pagination['totalPages'];
      _total = pagination['total'];
      _hasMore = _currentPage < _totalPages;

      notifyListeners();
    }
  }

  // Load more routines
  Future<void> loadMoreRoutines() async {
    if (!_hasMore || isLoading) return;
    await fetchRoutines(page: _currentPage + 1, loadMore: true);
  }

  // Fetch single routine by ID
  Future<void> fetchRoutineById(String id) async {
    final result = await execute(() => _service.getRoutineById(id));

    if (result != null) {
      _selectedRoutine = result;
      notifyListeners();
    }
  }

  // Update routine
  Future<void> updateRoutine(
    String id, {
    String? name,
    String? description,
    bool? isPublic,
  }) async {
    final result = await execute(
      () => _service.updateRoutine(
        id,
        name: name,
        description: description,
        isPublic: isPublic,
      ),
    );

    if (result != null) {
      _selectedRoutine = result;
      // Update in list
      final index = _routines.indexWhere((r) => r.id == id);
      if (index != -1) {
        _routines[index] = result;
      }
      notifyListeners();
    }
  }

  // Delete routine
  Future<void> deleteRoutine(String id) async {
    await execute(() => _service.deleteRoutine(id));

    if (!hasError) {
      _routines.removeWhere((r) => r.id == id);
      if (_selectedRoutine?.id == id) {
        _selectedRoutine = null;
      }
      notifyListeners();
    }
  }

  // Add exercise to routine
  Future<void> addExerciseToRoutine({
    required String exerciseId,
    int? sets,
    int? reps,
    double? weightKg,
    int? restSec,
    String? notes,
  }) async {
    if (_selectedRoutine == null) return;

    final result = await execute(
      () => _service.addExercise(
        _selectedRoutine!.id,
        exerciseId: exerciseId,
        sets: sets,
        reps: reps,
        weightKg: weightKg,
        restSec: restSec,
        notes: notes,
      ),
    );

    if (result != null) {
      // Refresh selected routine
      await fetchRoutineById(_selectedRoutine!.id);
    }
  }

  // Update exercise in routine
  Future<void> updateRoutineExercise(
    String exerciseId, {
    int? sets,
    int? reps,
    double? weightKg,
    int? restSec,
    String? notes,
  }) async {
    if (_selectedRoutine == null) return;

    final result = await execute(
      () => _service.updateExercise(
        _selectedRoutine!.id,
        exerciseId,
        sets: sets,
        reps: reps,
        weightKg: weightKg,
        restSec: restSec,
        notes: notes,
      ),
    );

    if (result != null) {
      // Refresh selected routine
      await fetchRoutineById(_selectedRoutine!.id);
    }
  }

  // Remove exercise from routine
  Future<void> removeExerciseFromRoutine(String exerciseId) async {
    if (_selectedRoutine == null) return;

    await execute(
      () => _service.removeExercise(_selectedRoutine!.id, exerciseId),
    );

    if (!hasError) {
      // Refresh selected routine
      await fetchRoutineById(_selectedRoutine!.id);
    }
  }

  // Start workout from routine (returns Workout)
  Future<Workout?> startWorkoutFromRoutine(String routineId) async {
    final result = await execute(
      () => _service.startWorkoutFromRoutine(routineId),
    );
    return result;
  }

  // Clear selected routine
  void clearSelectedRoutine() {
    _selectedRoutine = null;
    notifyListeners();
  }

  // Reset provider
  void reset() {
    _routines = [];
    _selectedRoutine = null;
    _currentPage = 1;
    _totalPages = 1;
    _total = 0;
    _hasMore = true;
    clearError();
    notifyListeners();
  }
}
