import 'package:dio/dio.dart';
import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import '../../models/routine/weekly_program_model.dart';

class WeeklyProgramService {
  final Dio _dio = ApiClient().dio;

  // GET /api/weekly-program — auto-creates if doesn't exist
  Future<WeeklyProgram> getProgram() async {
    final response = await _dio.get(ApiEndpoints.weeklyProgram);
    return WeeklyProgram.fromJson(response.data['data']);
  }

  // GET /api/weekly-program/today
  Future<WeeklyProgramDay> getToday() async {
    final response = await _dio.get(ApiEndpoints.weeklyProgramToday);
    return WeeklyProgramDay.fromJson(response.data['data']);
  }

  // PATCH /api/weekly-program/days/:dayId
  // pass routineId: null to set as rest day
  Future<WeeklyProgramDay> assignRoutine(
    String dayId, {
    String? routineId,
  }) async {
    final response = await _dio.patch(
      ApiEndpoints.weeklyProgramDay(dayId),
      data: {'routineId': routineId},
    );
    return WeeklyProgramDay.fromJson(response.data['data']);
  }
}
