import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class BaseProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  /// Generic wrapper for API calls
  /// Handles loading states, errors, and notifications automatically
  Future<T?> execute<T>(Future<T> Function() apiCall) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await apiCall();
      return result;
    } catch (e) {
      _error = _parseError(e);
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Execute without loading state (for background operations)
  Future<T?> executeSilent<T>(Future<T> Function() apiCall) async {
    _error = null;

    try {
      final result = await apiCall();
      return result;
    } catch (e) {
      _error = _parseError(e);
      return null;
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Parse error from different sources
  String _parseError(dynamic error) {
    if (error is DioException) {
      // Handle dio errors
      if (error.response?.data != null &&
          error.response?.data['message'] != null) {
        return error.response!.data['message'];
      }
      return error.message ?? 'Network error occurred';
    }
    return error.toString();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
