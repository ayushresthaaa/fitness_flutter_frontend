import 'package:flutter/material.dart';
import '../../services/exercise/workout_service.dart';
import '../../models/exercise/workout_model.dart';
import '../base/base_provider.dart';

class WorkoutProvider extends BaseProvider {
  final WorkoutService _service = WorkoutService();

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
}
