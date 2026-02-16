import 'package:dio/dio.dart';
import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import '../../models/exercise/exercise_model.dart';

class ExerciseService {
  final Dio _dio = ApiClient().dio;

  //get /api/exercises
  Future<List<Exercise>> getExercises({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.exercises,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null) 'search': search,
        if (category != null) 'category': category,
      },
    );
    final List data = response.data['exercises'];
    return data.map((e) => Exercise.fromJson(e)).toList();
  }

  // GET /api/exercises/:id
  Future<Exercise> getExerciseById(String id) async {
    final response = await _dio.get(ApiEndpoints.exerciseById(id));
    return Exercise.fromJson(response.data);
  }

  // GET /api/exercises/muscle/:muscleGroup
  Future<List<Exercise>> getExercisesByMuscle(String muscleGroup) async {
    final response = await _dio.get(ApiEndpoints.exerciseByMuscle(muscleGroup));
    final List data = response.data['exercises'];
    return data.map((e) => Exercise.fromJson(e)).toList();
  }

  // GET /api/exercises/meta/muscles (no auth)
  Future<List<String>> getMuscles() async {
    final response = await _dio.get(ApiEndpoints.exerciseMuscles);
    return List<String>.from(response.data);
  }

  // GET /api/exercises/meta/categories (no auth)
  Future<List<String>> getCategories() async {
    final response = await _dio.get(ApiEndpoints.exerciseCategories);
    return List<String>.from(response.data);
  }
}
