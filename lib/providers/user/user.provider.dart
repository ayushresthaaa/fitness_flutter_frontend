import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../models/user/user.dart';
import '../../services/user/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  User? _currentUser;
  UserProfile? _currentProfile;
  bool _isLoading = false;
  String? _error;

  // ======================
  // Getters
  // ======================
  User? get currentUser => _currentUser;
  UserProfile? get currentProfile => _currentProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get hasCompletedOnboarding =>
      _currentProfile?.isOnboardingComplete ?? false;

  // ======================
  // Set user from auth/me
  // ======================
  void setUser(User user) {
    _currentUser = user;
    _currentProfile = user.profile;
    notifyListeners();
  }

  // ======================
  // Complete onboarding using UserProfile object
  // ======================
  Future<void> completeOnboarding({required UserProfile profile}) async {
    _setLoading(true);

    try {
      final token = await _secureStorage.read(key: 'jwt_token');
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final updatedProfile = await _userService.completeOnboarding(
        token: token,
        profile: profile,
      );

      _currentProfile = updatedProfile;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // Fetch current user profile
  Future<void> fetchUserProfile() async {
    _setLoading(true);

    try {
      final token = await _secureStorage.read(key: 'jwt_token');
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final user = await _userService.getUserProfile(token);

      _currentUser = user;
      _currentProfile = user.profile;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // Logout / clear state
  void clearUser() {
    _currentUser = null;
    _currentProfile = null;
    _error = null;
    notifyListeners();
  }

  // Helpers
  void _setLoading(bool value) {
    _isLoading = value;
    _error = null;
    notifyListeners();
  }

  void _setError(String message) {
    _isLoading = false;
    _error = message;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
