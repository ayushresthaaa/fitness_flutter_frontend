import 'package:flutter/material.dart';
import '../../models/user/user.dart';
import '../../services/user/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();

  User? _currentUser;
  UserProfile? _currentProfile;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  UserProfile? get currentProfile => _currentProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get hasCompletedOnboarding =>
      _currentProfile?.isOnboardingComplete ?? false;

  void setUser(User user) {
    _currentUser = user;
    _currentProfile = user.profile;
    notifyListeners();
  }

  // Complete onboarding
  Future<void> completeOnboarding({required UserProfile profile}) async {
    _setLoading(true);
    try {
      final updatedProfile = await _userService.completeOnboarding(
        profile: profile,
      );
      _currentProfile = updatedProfile;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // Fetch current user
  Future<void> fetchUserProfile() async {
    _setLoading(true);
    try {
      final user = await _userService.getUserProfile();
      _currentUser = user;
      _currentProfile = user.profile;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // Update name/email
  Future<void> updateAccount({String? name, String? email}) async {
    _setLoading(true);
    try {
      final updatedUser = await _userService.updateAccount(
        name: name,
        email: email,
      );
      _currentUser = updatedUser;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // Update fitness profile
  Future<void> updateFitnessProfile({
    double? heightCm,
    double? currentWeightKg,
    String? fitnessGoal,
    String? activityLevel,
    String? equipmentAccess,
    String? gender,
    DateTime? dateOfBirth,
  }) async {
    _setLoading(true);
    try {
      final updatedProfile = await _userService.updateFitnessProfile(
        heightCm: heightCm,
        currentWeightKg: currentWeightKg,
        fitnessGoal: fitnessGoal,
        activityLevel: activityLevel,
        equipmentAccess: equipmentAccess,
        gender: gender,
        dateOfBirth: dateOfBirth,
      );
      _currentProfile = updatedProfile;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    try {
      await _userService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  void clearUser() {
    _currentUser = null;
    _currentProfile = null;
    _error = null;
    notifyListeners();
  }

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
