import 'package:dio/dio.dart';
import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import '../../models/exercise/workout_model.dart';

class WorkoutService {
  final Dio _dio = ApiClient().dio;

  // POST /api/workouts
  Future<Workout> createWorkout({String? title, String? notes}) async {
    final response = await _dio.post(
      ApiEndpoints.workouts,
      data: {
        if (title != null) 'title': title,
        if (notes != null) 'notes': notes,
      },
    );
    return Workout.fromJson(response.data['data']);
  }

  // GET /api/workouts
  Future<Map<String, dynamic>> getWorkouts({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.workouts,
      queryParameters: {'page': page, 'limit': limit},
    );

    final data = response.data['data'];
    return {
      'workouts': (data['workouts'] as List)
          .map((w) => Workout.fromJson(w))
          .toList(),
      'pagination': data['pagination'],
    };
  }

  // GET /api/workouts/:id
  Future<Workout> getWorkoutById(String id) async {
    final response = await _dio.get(ApiEndpoints.workoutById(id));
    return Workout.fromJson(response.data['data']);
  }

  // PUT /api/workouts/:id/finish
  Future<Workout> finishWorkout(
    String id, {
    String? title,
    String? notes,
  }) async {
    final response = await _dio.put(
      ApiEndpoints.finishWorkout(id),
      data: {
        if (title != null) 'title': title,
        if (notes != null) 'notes': notes,
      },
    );
    return Workout.fromJson(response.data['data']);
  }

  // DELETE /api/workouts/:id
  Future<void> deleteWorkout(String id) async {
    await _dio.delete(ApiEndpoints.workoutById(id));
  }

  // POST /api/workouts/:id/exercises
  Future<WorkoutExercise> addExercise(
    String workoutId, {
    required String exerciseId,
    int? sets,
    int? reps,
    double? weightKg,
    int? durationSec,
    String? notes,
    int? supersetGroup,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.workoutExercises(workoutId),
      data: {
        'exerciseId': exerciseId,
        if (sets != null) 'sets': sets,
        if (reps != null) 'reps': reps,
        if (weightKg != null) 'weightKg': weightKg,
        if (durationSec != null) 'durationSec': durationSec,
        if (notes != null) 'notes': notes,
        if (supersetGroup != null) 'supersetGroup': supersetGroup,
      },
    );
    return WorkoutExercise.fromJson(response.data['data']);
  }

  // PUT /api/workouts/:id/exercises/:exerciseId
  Future<WorkoutExercise> updateExercise(
    String workoutId,
    String exerciseId, {
    int? sets,
    int? reps,
    double? weightKg,
    int? durationSec,
    String? notes,
  }) async {
    final response = await _dio.put(
      ApiEndpoints.workoutExerciseById(workoutId, exerciseId),
      data: {
        if (sets != null) 'sets': sets,
        if (reps != null) 'reps': reps,
        if (weightKg != null) 'weightKg': weightKg,
        if (durationSec != null) 'durationSec': durationSec,
        if (notes != null) 'notes': notes,
      },
    );
    return WorkoutExercise.fromJson(response.data['data']);
  }

  // DELETE /api/workouts/:id/exercises/:exerciseId
  Future<void> removeExercise(String workoutId, String exerciseId) async {
    await _dio.delete(ApiEndpoints.workoutExerciseById(workoutId, exerciseId));
  }

  // POST /api/workouts/:id/sets
  Future<void> saveSets(
    String workoutId,
    List<Map<String, dynamic>> exerciseSets,
  ) async {
    await _dio.post(
      '${ApiEndpoints.workouts}/$workoutId/sets',
      data: {'exerciseSets': exerciseSets},
    );
  }

  // GET /api/workouts/exercises/:exerciseId/last
  Future<Map<String, dynamic>?> getLastPerformance(String exerciseId) async {
    final response = await _dio.get(
      '${ApiEndpoints.workouts}/exercises/$exerciseId/last',
    );
    return response.data['data'];
  }

  // PATCH /api/workouts/:id
  Future<void> updateWorkout(String id, {String? title, String? notes}) async {
    await _dio.patch(
      ApiEndpoints.workoutById(id),
      data: {
        if (title != null) 'title': title,
        if (notes != null) 'notes': notes,
      },
    );
  }
}
