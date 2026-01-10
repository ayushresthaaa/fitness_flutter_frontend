import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../models/user/user.dart';

class UserService {
  final String baseUrl =
      dotenv.env['API_BASE_URL'] ?? 'http://192.168.1.82:4000/api';

  // Complete onboarding using UserProfile object
  Future<UserProfile> completeOnboarding({
    required String token,
    required UserProfile profile,
  }) async {
    final url = Uri.parse('$baseUrl/users/me/onboarding');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(profile.toJson()), // send full profile as JSON
    );

    late final Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      throw Exception('Invalid server response');
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        body['success'] == true) {
      return UserProfile.fromJson(body['data']);
    } else {
      throw Exception(body['message'] ?? 'Onboarding failed');
    }
  }

  // Get current user profile
  Future<User> getUserProfile(String token) async {
    final url = Uri.parse('$baseUrl/auth/me');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    late final Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      throw Exception('Invalid server response');
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        body['success'] == true) {
      return User.fromJson(body['data']);
    } else {
      throw Exception(body['message'] ?? 'Failed to fetch user profile');
    }
  }
}
