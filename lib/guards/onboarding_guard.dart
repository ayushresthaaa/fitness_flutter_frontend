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
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final userProvider = context.read<UserProvider>();

    try {
      if (userProvider.currentProfile == null) {
        await userProvider.fetchUserProfile();
      }
    } catch (e) {
      print('Profile fetch failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF2563EB)),
        ),
      );
    }

    final userProvider = context.watch<UserProvider>();

    if (!userProvider.hasCompletedOnboarding) {
      Future.microtask(() {
        Navigator.of(context).pushReplacementNamed(OnboardingScreen.routeName);
      });
      return const SizedBox.shrink();
    }

    return widget.child;
  }
}
