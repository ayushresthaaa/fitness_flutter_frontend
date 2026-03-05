import 'package:dio/dio.dart';
import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import '../../models/progress/progress_model.dart';

class ProgressService {
  final Dio _dio = ApiClient().dio;

  // GET /api/progress/personal-bests
  Future<List<PersonalBest>> getPersonalBests() async {
    final response = await _dio.get(ApiEndpoints.personalBests);
    final data = response.data['data'] as List;
    return data.map((e) => PersonalBest.fromJson(e)).toList();
  }

  // GET /api/progress/exercise/:id
  Future<ExerciseProgressData> getExerciseProgress(String exerciseId) async {
    final response = await _dio.get(ApiEndpoints.exerciseProgress(exerciseId));
    return ExerciseProgressData.fromJson(response.data['data']);
  }
}
