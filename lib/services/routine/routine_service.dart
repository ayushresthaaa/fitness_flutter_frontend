import 'package:dio/dio.dart';
import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import '../../models/routine/routine_model.dart';
import '../../models/exercise/workout_model.dart';

class RoutineService {
  final Dio _dio = ApiClient().dio;

  // POST /api/routines
  Future<Routine> createRoutine({
    required String name,
    String? description,
    bool? isPublic,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.routines,
      data: {
        'name': name,
        if (description != null) 'description': description,
        if (isPublic != null) 'isPublic': isPublic,
      },
    );
    return Routine.fromJson(response.data['data']);
  }

  // GET /api/routines
  Future<Map<String, dynamic>> getRoutines({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.routines,
      queryParameters: {'page': page, 'limit': limit},
    );

    final data = response.data['data'];
    return {
      'routines': (data['routines'] as List)
          .map((r) => Routine.fromJson(r))
          .toList(),
      'pagination': data['pagination'],
      'hasPendingAIRoutine': data['hasPendingAIRoutine'] ?? false,
    };
  }

  // GET /api/routines/:id
  Future<Routine> getRoutineById(String id) async {
    final response = await _dio.get(ApiEndpoints.routineById(id));
    return Routine.fromJson(response.data['data']);
  }

  // PUT /api/routines/:id
  Future<Routine> updateRoutine(
    String id, {
    String? name,
    String? description,
    bool? isPublic,
  }) async {
    final response = await _dio.put(
      ApiEndpoints.routineById(id),
      data: {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (isPublic != null) 'isPublic': isPublic,
      },
    );
    return Routine.fromJson(response.data['data']);
  }

  // DELETE /api/routines/:id
  Future<void> deleteRoutine(String id) async {
    await _dio.delete(ApiEndpoints.routineById(id));
  }

  // POST /api/routines/:id/exercises
  Future<RoutineExercise> addExercise(
    String routineId, {
    required String exerciseId,
    int? sets,
    int? reps,
    double? weightKg,
    int? restSec,
    String? notes,
    int? supersetGroup,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.routineExercises(routineId),
      data: {
        'exerciseId': exerciseId,
        if (sets != null) 'sets': sets,
        if (reps != null) 'reps': reps,
        if (weightKg != null) 'weightKg': weightKg,
        if (restSec != null) 'restSec': restSec,
        if (notes != null) 'notes': notes,
        if (supersetGroup != null) 'supersetGroup': supersetGroup,
      },
    );
    return RoutineExercise.fromJson(response.data['data']);
  }

  // PUT /api/routines/:id/exercises/:exerciseId
  Future<RoutineExercise> updateExercise(
    String routineId,
    String exerciseId, {
    int? sets,
    int? reps,
    double? weightKg,
    int? restSec,
    String? notes,
    int? supersetGroup,
  }) async {
    final response = await _dio.put(
      ApiEndpoints.routineExerciseById(routineId, exerciseId),
      data: {
        if (sets != null) 'sets': sets,
        if (reps != null) 'reps': reps,
        if (weightKg != null) 'weightKg': weightKg,
        if (restSec != null) 'restSec': restSec,
        if (notes != null) 'notes': notes,
        if (supersetGroup != null) 'supersetGroup': supersetGroup,
      },
    );
    return RoutineExercise.fromJson(response.data['data']);
  }

  // DELETE /api/routines/:id/exercises/:exerciseId
  Future<void> removeExercise(String routineId, String exerciseId) async {
    await _dio.delete(ApiEndpoints.routineExerciseById(routineId, exerciseId));
  }

  // POST /api/routines/:id/start
  Future<Workout> startWorkoutFromRoutine(String routineId) async {
    final response = await _dio.post(ApiEndpoints.startRoutine(routineId));
    return Workout.fromJson(response.data['data']);
  }

  // POST /api/routines/:id/send-for-review
  Future<void> sendRoutineForReview(String routineId) async {
    await _dio.post(ApiEndpoints.sendRoutineForReview(routineId));
  }

  // POST /api/routines/generate — requires pro plan
  Future<void> generateRoutine() async {
    await _dio.post(ApiEndpoints.generateRoutine);
  }
}
