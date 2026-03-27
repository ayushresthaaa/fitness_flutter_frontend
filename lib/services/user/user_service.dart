import 'package:dio/dio.dart';
import '../../models/user/user.dart';
import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';

class UserService {
  final Dio _dio = ApiClient().dio;

  // Complete onboarding
  Future<UserProfile> completeOnboarding({
    required UserProfile profile,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.onboarding,
      data: profile.toJson(),
    );
    return UserProfile.fromJson(response.data['data']);
  }

  // Get current user profile
  Future<User> getUserProfile() async {
    final response = await _dio.post(ApiEndpoints.me);
    return User.fromJson(response.data['data']);
  }

  // PATCH /users/me — update name and/or email
  Future<User> updateAccount({String? name, String? email}) async {
    final response = await _dio.patch(
      ApiEndpoints.updateAccount,
      data: {
        if (name != null) 'name': name,
        if (email != null) 'email': email,
      },
    );
    return User.fromJson(response.data['data']);
  }

  // PUT /users/me/profile — update fitness profile
  Future<UserProfile> updateFitnessProfile({
    double? heightCm,
    double? currentWeightKg,
    String? fitnessGoal,
    String? activityLevel,
    String? equipmentAccess,
    String? gender,
    DateTime? dateOfBirth,
  }) async {
    final response = await _dio.put(
      ApiEndpoints.updateProfile,
      data: {
        if (heightCm != null) 'heightCm': heightCm,
        if (currentWeightKg != null) 'currentWeightKg': currentWeightKg,
        if (fitnessGoal != null) 'fitnessGoal': fitnessGoal,
        if (activityLevel != null) 'activityLevel': activityLevel,
        if (equipmentAccess != null) 'equipmentAccess': equipmentAccess,
        if (gender != null) 'gender': gender,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth.toIso8601String(),
      },
    );
    return UserProfile.fromJson(response.data['data']);
  }

  // PATCH /users/me/password — change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _dio.patch(
      ApiEndpoints.changePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }
}