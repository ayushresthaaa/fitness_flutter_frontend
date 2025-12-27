// lib/utils/validation/validators.dart
class Validators {
  /// Validates email with stricter rules
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    value = value.trim();

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  /// Validates password with strong security rules
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain an uppercase letter';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain a lowercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain a number';
    }

    // Fixed: Escape special characters properly
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_+=\-\[\]\\\/~`]'))) {
      return 'Password must contain a special character';
    }

    return null;
  }

  /// Validates name
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    value = value.trim();

    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (value.length > 50) {
      return 'Name is too long';
    }

    return null;
  }

  /// Validates confirm password
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }
}
