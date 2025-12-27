import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/user/user.dart';

class AuthService {
  final String baseUrl =
      dotenv.env['API_BASE_URL'] ?? 'http://192.168.1.82:4000/api';
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId:
        '525081444214-1sftbuulbj64u7bq48vvl3ishbq3dvrd.apps.googleusercontent.com', // Add this back
  );
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  //login with email and password
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');

    //posting to the login url
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final body = jsonDecode(response.body); //decoding what we get

    if (response.statusCode == 200 && body['success'] == true) {
      final user = User.fromJson(body['data']['user']);
      final token = body['data']['token'];

      await _secureStorage.write(key: 'jwt_token', value: token);

      return {'user': user, 'token': token};
    } else {
      throw Exception(body['message'] ?? 'Login failed');
    }
  }

  //register new user
  Future<User> register(String email, String password, String? name) async {
    final url = Uri.parse('$baseUrl/auth/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
      }), //currently didnt use tojson method
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 201 && body['success'] == true) {
      return User.fromJson(body['data']);
    } else {
      throw Exception(body['message'] ?? 'Registration failed');
    }
  }

  // Google Sign-In login
  // Google Sign-In login
  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      print('🔵 Starting Google Sign-In...');

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      print('🔵 Google user: ${googleUser?.email}');

      if (googleUser == null) {
        throw Exception('Google sign-in aborted');
      }

      print('🔵 Getting authentication...');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final idToken = googleAuth.idToken;
      print('🔵 ID Token received: ${idToken?.substring(0, 20)}...');

      if (idToken == null) {
        throw Exception('Google ID token missing');
      }

      print('🔵 Sending token to backend: $baseUrl/auth/google/mobile');
      final url = Uri.parse('$baseUrl/auth/google/mobile');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      print('🔵 Backend response status: ${response.statusCode}');
      print('🔵 Backend response body: ${response.body}');

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        final user = User.fromJson(body['data']['user']);
        final token = body['data']['token'];

        await _secureStorage.write(key: 'jwt_token', value: token);

        return {'user': user, 'token': token};
      } else {
        throw Exception(body['message'] ?? 'Google login failed');
      }
    } catch (e) {
      print('❌ Google Sign-In Error: $e');
      rethrow;
    }
  }

  // Retrieve stored JWT token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'jwt_token');
  }

  // Logout user
  Future<void> logout() async {
    await _secureStorage.delete(key: 'jwt_token');
    await _googleSignIn.signOut();
  }

  // Fetch current user info with JWT token
  Future<User> getCurrentUser(String token) async {
    final url = Uri.parse('$baseUrl/me');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200 && body['success'] == true) {
      return User.fromJson(body['data']);
    } else {
      throw Exception(body['message'] ?? 'Failed to fetch user info');
    }
  }
}
