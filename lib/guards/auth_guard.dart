import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth/auth_provider.dart';
import '../screens/auth/login_screen.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Not authenticated? Redirect immediately
    if (!authProvider.isAuthenticated) {
      Future.microtask(() {
        Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
      });
      return SizedBox.shrink(); // Return nothing while redirecting
    }

    return child; // Show the protected screen
  }
}
