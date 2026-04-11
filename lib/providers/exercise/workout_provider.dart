import '../../services/exercise/workout_service.dart';
import '../../models/exercise/workout_model.dart';
import '../base/base_provider.dart';
import '../../api/api_client.dart';

class WorkoutProvider extends BaseProvider {
  final WorkoutService _service = WorkoutService();
  final _dio = ApiClient().dio;
  List<Workout> _workouts = [];
  Workout? _currentWorkout; // Active workout being performed

  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  int _total = 0;
  bool _hasMore = true;

  // Getters
  List<Workout> get workouts => _workouts;
  Workout? get currentWorkout => _currentWorkout;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get total => _total;
  bool get hasMore => _hasMore;
  bool get hasActiveWorkout =>
      _currentWorkout != null && _currentWorkout!.endTime == null;

  final Map<String, List<Map<String, dynamic>>> _lastPerformance = {};

  Map<String, List<Map<String, dynamic>>> get lastPerformance =>
      _lastPerformance;
  // Start a new workout
  Future<void> startWorkout({String? title, String? notes}) async {
    final result = await execute(
      () => _service.createWorkout(title: title, notes: notes),
    );

    if (result != null) {
      _currentWorkout = result;
      notifyListeners();
    }
  }

  // Fetch user's workouts
  Future<void> fetchWorkouts({
    int page = 1,
    int limit = 10,
    bool loadMore = false,
  }) async {
    final result = await execute(
      () => _service.getWorkouts(page: page, limit: limit),
    );

    if (result != null) {
      final List<Workout> newWorkouts = result['workouts'];

      if (loadMore) {
        _workouts.addAll(newWorkouts);
      } else {
        _workouts = newWorkouts;
      }

      final pagination = result['pagination'];
      _currentPage = pagination['page'];
      _totalPages = pagination['totalPages'];
      _total = pagination['total'];
      _hasMore = _currentPage < _totalPages;

      notifyListeners();
    }
  }

  // Load more workouts
  Future<void> loadMoreWorkouts() async {
    if (!_hasMore || isLoading) return;
    await fetchWorkouts(page: _currentPage + 1, loadMore: true);
  }

  // Fetch single workout by ID
  Future<void> fetchWorkoutById(String id) async {
    final result = await execute(() => _service.getWorkoutById(id));

    if (result != null) {
      _currentWorkout = result;
      notifyListeners();
    }
  }

  // Finish current workout
  Future<void> finishWorkout({String? title, String? notes}) async {
    if (_currentWorkout == null) return;

    final result = await execute(
      () => _service.finishWorkout(
        _currentWorkout!.id,
        title: title,
        notes: notes,
      ),
    );

    if (result != null) {
      _currentWorkout = result;
      // Add to workouts list
      _workouts.insert(0, result);
      notifyListeners();
    }
  }

  // Delete workout
  Future<void> deleteWorkout(String id) async {
    await execute(() => _service.deleteWorkout(id));

    if (!hasError) {
      _workouts.removeWhere((w) => w.id == id);
      if (_currentWorkout?.id == id) {
        _currentWorkout = null;
      }
      notifyListeners();
    }
  } // Add exercise to current workout

  Future<void> addExerciseToWorkout({
    required String exerciseId,
    int? sets,
    int? reps,
    double? weightKg,
    int? durationSec,
    String? notes,
    int? supersetGroup,
  }) async {
    if (_currentWorkout == null) return;

    final result = await execute(
      () => _service.addExercise(
        _currentWorkout!.id,
        exerciseId: exerciseId,
        sets: sets,
        reps: reps,
        weightKg: weightKg,
        durationSec: durationSec,
        notes: notes,
        supersetGroup: supersetGroup,
      ),
    );

    if (result != null) {
      // Refresh current workout to get updated exercises
      await fetchWorkoutById(_currentWorkout!.id);
    }
  }

  // Update exercise in current workout
  Future<void> updateWorkoutExercise(
    String exerciseId, {
    int? sets,
    int? reps,
    double? weightKg,
    int? durationSec,
    String? notes,
  }) async {
    if (_currentWorkout == null) return;

    final result = await execute(
      () => _service.updateExercise(
        _currentWorkout!.id,
        exerciseId,
        sets: sets,
        reps: reps,
        weightKg: weightKg,
        durationSec: durationSec,
        notes: notes,
      ),
    );

    if (result != null) {
      // Refresh current workout
      await fetchWorkoutById(_currentWorkout!.id);
    }
  }

  Future<void> updateWorkoutStartTime(
    String workoutId,
    DateTime startTime,
  ) async {
    try {
      print('Updating startTime to: ${startTime.toUtc().toIso8601String()}');
      final res = await _dio.patch(
        '/workouts/$workoutId/start-time',
        data: {'startTime': startTime.toUtc().toIso8601String()},
      );
      print('Response: ${res.data}');
    } catch (e) {
      print('Error updating startTime: $e');
    }
  }

  // Remove exercise from current workout
  Future<void> removeExerciseFromWorkout(String exerciseId) async {
    if (_currentWorkout == null) return;

    await execute(
      () => _service.removeExercise(_currentWorkout!.id, exerciseId),
    );

    if (!hasError) {
      // Refresh current workout
      await fetchWorkoutById(_currentWorkout!.id);
    }
  }

  // Clear current workout
  void clearCurrentWorkout() {
    _currentWorkout = null;
    notifyListeners();
  }

  // Reset provider
  void reset() {
    _workouts = [];
    _currentWorkout = null;
    _currentPage = 1;
    _totalPages = 1;
    _total = 0;
    _hasMore = true;
    clearError();
    notifyListeners();
  }

  // Save all sets when finishing workout
  Future<void> saveSets(List<Map<String, dynamic>> exerciseSets) async {
    if (_currentWorkout == null) return;
    await execute(() => _service.saveSets(_currentWorkout!.id, exerciseSets));
  }

  // fetch last performance for all exercises in current workout
  Future<void> fetchLastPerformances() async {
    final workout = _currentWorkout;
    if (workout == null) {
      print('NO CURRENT WORKOUT');
      return;
    }

    for (final we in workout.exercises) {
      print('Fetching for exerciseId: ${we.exerciseId}');
      final result = await execute(
        () => _service.getLastPerformance(we.exerciseId),
      );
      print('Got result: $result');
      if (result != null) {
        final sets = List<Map<String, dynamic>>.from(result['lastSets'] ?? []);
        print('Sets parsed: $sets');
        _lastPerformance[we.exerciseId] = sets;
      }
    }
    print('Final lastPerformance map: $_lastPerformance');
    notifyListeners();
  }

  void setCurrentWorkout(Workout workout) {
    _currentWorkout = workout;
    notifyListeners();
  }

  Future<void> fetchAllWorkouts() async {
    _workouts = [];
    int page = 1;
    bool hasMore = true;

    while (hasMore) {
      final result = await execute(
        () => _service.getWorkouts(page: page, limit: 50),
      );
      if (result == null) break;

      final workoutsPage = (result['workouts'] as List)
          .map((w) => Workout.fromJson(w))
          .toList();

      _workouts.addAll(workoutsPage);

      final pagination = result['pagination'];
      hasMore = pagination['page'] < pagination['totalPages'];
      page++;
    }

    print('Total workouts fetched: ${_workouts.length}');
    notifyListeners();
  }

  Future<void> updateWorkout(String id, {String? title, String? notes}) async {
    await execute(() => _service.updateWorkout(id, title: title, notes: notes));
  }

  // Fetch last performance for a single exercise by id
  Future<List<Map<String, dynamic>>?> getLastPerformanceFor(
    String exerciseId,
  ) async {
    final result = await execute(() => _service.getLastPerformance(exerciseId));
    print('Raw result for $exerciseId: $result');
    if (result == null) return null;
    return List<Map<String, dynamic>>.from(result['lastSets'] ?? []);
  }
}
