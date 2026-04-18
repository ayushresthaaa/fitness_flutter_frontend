import 'package:flutter/material.dart';
import '../../models/user/user.dart';
import '../../services/auth/auth_service.dart';
import '../../utils/validation/validators.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../models/notification/notification_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;
  IO.Socket? _socket;
  void Function(AppNotification)? onNewNotification;
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

      //token is stored in secure storage in auth service, so no need to store it again here
      //fetch user profile after login
      // final userProvider = UserProvider();
      // userProvider.setUser(_user!);
      //do this in the login screen after successful login, so we can fetch the profile and set it in the user provider
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    _connectSocket(); // add this line
  }

  Future<String?> register(
    String email,
    String password,
    String confirmPassword,
    String name,
  ) async {
    final nameError = Validators.name(name);
    if (nameError != null) {
      _error = nameError;
      notifyListeners();
      return null;
    }

    final emailError = Validators.email(email);
    if (emailError != null) {
      _error = emailError;
      notifyListeners();
      return null;
    }

    final passwordError = Validators.password(password);
    if (passwordError != null) {
      _error = passwordError;
      notifyListeners();
      return null;
    }

    final confirmPasswordError = Validators.confirmPassword(
      confirmPassword,
      password,
    );
    if (confirmPasswordError != null) {
      _error = confirmPasswordError;
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final registeredEmail = await _authService.register(
        email,
        password,
        name,
      );
      _isLoading = false;
      notifyListeners();
      return registeredEmail; // return email to screen for navigation
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
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
    _connectSocket();
  }

  /// Logout
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _token = null;
    _error = null;
    notifyListeners();
    _disconnectSocket();
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
      _connectSocket();
    } catch (e) {
      await logout();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _connectSocket() {
    if (_user == null) return;

    _socket = IO.io(
      'http://192.168.1.76:4000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      debugPrint('Socket connected');
      _socket!.emit('join', _user!.id);
    });

    _socket!.on('notification:new', (data) {
      final notification = AppNotification(
        id: data['id'] ?? 0,
        userId: _user!.id,
        title: data['title'] ?? '',
        body: data['body'] ?? '',
        type: data['type'] ?? '',
        read: false,
        createdAt: DateTime.now(),
      );
      if (onNewNotification != null) {
        onNewNotification!(notification);
      }
    });

    _socket!.onDisconnect((_) => debugPrint('Socket disconnected'));
  }

  void _disconnectSocket() {
    _socket?.disconnect();
    _socket = null;
  }
}
