import 'package:dio/dio.dart';
import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import '../../models/exercise/exercise_model.dart';

class ExerciseService {
  final Dio _dio = ApiClient().dio;

  // GET /api/exercises (with filters and pagination)
  Future<Map<String, dynamic>> getExercises({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
    String? level,
    String? equipment,
    String? muscleGroup,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.exercises,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null) 'search': search,
        if (category != null) 'category': category,
        if (level != null) 'level': level,
        if (equipment != null) 'equipment': equipment,
        if (muscleGroup != null) 'muscleGroup': muscleGroup,
      },
    );

    final data = response.data['data'];
    return {
      'exercises': (data['exercises'] as List)
          .map((e) => Exercise.fromJson(e))
          .toList(),
      'pagination': data['pagination'],
    };
  }

  // GET /api/exercises/:id
  Future<Exercise> getExerciseById(String id) async {
    final response = await _dio.get(ApiEndpoints.exerciseById(id));
    return Exercise.fromJson(response.data['data']);
  }

  // GET /api/exercises/muscle/:muscleGroup
  Future<List<Exercise>> getExercisesByMuscle(String muscleGroup) async {
    final response = await _dio.get(ApiEndpoints.exerciseByMuscle(muscleGroup));
    final List data = response.data['data'];
    return data.map((e) => Exercise.fromJson(e)).toList();
  }

  // GET /api/exercises/meta/muscles (no auth)
  Future<List<String>> getMuscles() async {
    final response = await _dio.get(ApiEndpoints.exerciseMuscles);
    return List<String>.from(response.data['data']);
  }

  // GET /api/exercises/meta/categories (no auth)
  Future<List<String>> getCategories() async {
    final response = await _dio.get(ApiEndpoints.exerciseCategories);
    return List<String>.from(response.data['data']);
  }
}
