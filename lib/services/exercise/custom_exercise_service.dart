import 'dart:convert';
import 'package:dio/dio.dart';
import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import '../../models/exercise/custom_exercise_model.dart';

// Service for custom exercise API calls only
// No logic here — just API calls
class CustomExerciseService {
  final Dio _dio = ApiClient().dio;

  // GET /api/exercises/custom
  Future<List<CustomExercise>> getCustomExercises() async {
    final response = await _dio.get(ApiEndpoints.customExercises);
    final List data = response.data['data'];
    return data.map((e) => CustomExercise.fromJson(e)).toList();
  }

  // GET /api/exercises/custom/:id
  Future<CustomExercise> getCustomExerciseById(String id) async {
    final response = await _dio.get(ApiEndpoints.customExerciseById(id));
    return CustomExercise.fromJson(response.data['data']);
  }

  // POST /api/exercises/custom
  // Sends multipart form data — images are optional
  Future<CustomExercise> createCustomExercise({
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
    final Map<String, dynamic> fields = {
      'name': name,
      'level': level,
      'category': category,
      'primaryMuscles': jsonEncode(primaryMuscles),
      'secondaryMuscles': jsonEncode(secondaryMuscles),
      'instructions': jsonEncode(instructions),
    };

    if (force != null) fields['force'] = force;
    if (mechanic != null) fields['mechanic'] = mechanic;
    if (equipment != null) fields['equipment'] = equipment;

    // Attach image files if any were picked
    if (imagePaths.isNotEmpty) {
      final imageFiles = <MultipartFile>[];
      for (final path in imagePaths) {
        final file = await MultipartFile.fromFile(
          path,
          filename: path.split('/').last,
        );
        imageFiles.add(file);
      }
      fields['images'] = imageFiles;
    }

    final formData = FormData.fromMap(fields);
    final response = await _dio.post(
      ApiEndpoints.customExercises,
      data: formData,
    );

    return CustomExercise.fromJson(response.data['data']);
  }

  // DELETE /api/exercises/custom/:id
  Future<void> deleteCustomExercise(String id) async {
    await _dio.delete(ApiEndpoints.customExerciseById(id));
  }

  // PATCH /api/exercises/custom/:id
  Future<CustomExercise> updateCustomExercise({
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
    final Map<String, dynamic> fields = {
      'name': name,
      'level': level,
      'category': category,
      'primaryMuscles': jsonEncode(primaryMuscles),
      'secondaryMuscles': jsonEncode(secondaryMuscles),
      'instructions': jsonEncode(instructions),
    };

    if (force != null) fields['force'] = force;
    if (mechanic != null) fields['mechanic'] = mechanic;
    if (equipment != null) fields['equipment'] = equipment;

    // Only attach images if user picked new ones
    if (imagePaths.isNotEmpty) {
      final imageFiles = <MultipartFile>[];
      for (final path in imagePaths) {
        final file = await MultipartFile.fromFile(
          path,
          filename: path.split('/').last,
        );
        imageFiles.add(file);
      }
      fields['images'] = imageFiles;
    }

    final formData = FormData.fromMap(fields);
    final response = await _dio.patch(
      ApiEndpoints.customExerciseById(id),
      data: formData,
    );

    return CustomExercise.fromJson(response.data['data']);
  }
}
