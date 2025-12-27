import 'package:flutter/material.dart';
import '../../models/user/user.dart';
import '../../services/auth/auth_service.dart';
import '../../utils/validation/validators.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isAuthenticated => _user != null && _token != null;

  /// Login with validation
  Future<void> login(String email, String password) async {
    // Validate email
    final emailError = Validators.email(email);
    if (emailError != null) {
      _error = emailError;
      notifyListeners();
      return;
    }

    // Validate password
    final passwordError = Validators.password(password);
    if (passwordError != null) {
      _error = passwordError;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.login(email, password);
      _user = result['user'];
      _token = result['token'];
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Register with validation
  Future<void> register(
    String email,
    String password,
    String confirmPassword,
    String name,
  ) async {
    // Validate name
    final nameError = Validators.name(name);
    if (nameError != null) {
      _error = nameError;
      notifyListeners();
      return;
    }

    // Validate email
    final emailError = Validators.email(email);
    if (emailError != null) {
      _error = emailError;
      notifyListeners();
      return;
    }

    // Validate password
    final passwordError = Validators.password(password);
    if (passwordError != null) {
      _error = passwordError;
      notifyListeners();
      return;
    }

    // Validate confirm password
    final confirmPasswordError = Validators.confirmPassword(
      confirmPassword,
      password,
    );
    if (confirmPasswordError != null) {
      _error = confirmPasswordError;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.register(email, password, name);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Login with Google OAuth
  Future<void> loginWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.loginWithGoogle();
      _user = result['user'];
      _token = result['token'];
      _error = null; // Explicitly clear error on success
    } catch (e) {
      _error = e.toString();
      _user = null; // Clear user on error
      _token = null; // Clear token on error
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Logout
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _token = null;
    _error = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Try auto login by reading token and fetching user
  Future<void> tryAutoLogin() async {
    final storedToken = await _secureStorage.read(key: 'jwt_token');
    if (storedToken == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.getCurrentUser(storedToken);
      _user = user;
      _token = storedToken;
    } catch (e) {
      await logout();
    }

    _isLoading = false;
    notifyListeners();
  }
}
