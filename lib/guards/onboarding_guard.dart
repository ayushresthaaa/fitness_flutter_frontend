import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user/user.provider.dart';
import '../screens/user/onboarding_screen.dart';

class OnboardingGuard extends StatefulWidget {
  final Widget child;

  const OnboardingGuard({Key? key, required this.child}) : super(key: key);

  @override
  _OnboardingGuardState createState() => _OnboardingGuardState();
}

class _OnboardingGuardState extends State<OnboardingGuard> {
  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final userProvider = context.read<UserProvider>();

    // Fetch profile if needed
    if (userProvider.currentProfile == null) {
      await userProvider.fetchUserProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    // Not onboarded? Redirect immediately
    if (!userProvider.hasCompletedOnboarding) {
      Future.microtask(() {
        Navigator.of(context).pushReplacementNamed(OnboardingScreen.routeName);
      });
      return SizedBox.shrink(); // Return nothing while redirecting
    }

    return widget.child; // Show the protected screen
  }
}
