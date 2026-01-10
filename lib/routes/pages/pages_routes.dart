import 'package:flutter/material.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/user/onboarding_screen.dart';
import '../../guards/auth_guard.dart';
import '../../guards/onboarding_guard.dart';
// import '../../screens/home/home_screen.dart';

Map<String, WidgetBuilder> pageRoutes = {
  HomeScreen.routeName: (context) => AuthGuard(
    child: OnboardingGuard(child: HomeScreen()),
  ), //since home screen requires both auth guard + onboarding guard
  OnboardingScreen.routeName: (context) => AuthGuard(
    child: OnboardingScreen(),
  ), //onboarding only requires the auth guard
};
