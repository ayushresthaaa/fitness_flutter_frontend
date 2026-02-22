import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'api/api_client.dart';
// Import your providers
import 'providers/auth/auth_provider.dart';
import './providers/user/user.provider.dart';
import './providers/exercise/exercise_provider.dart';
import './providers/exercise/workout_provider.dart';
import './providers/routine/routine_provider.dart';
import './providers/achievement/achievement_provider.dart';
// Import your routes
import 'routes/app_routes.dart';

// Import your screens
import 'screens/app_screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from the .env file
  await dotenv.load(fileName: ".env");

  // Initialize the API client
  ApiClient().initialize();

  // Run the app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Use MultiProvider to provide BOTH AuthProvider and UserProvider
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
        ChangeNotifierProvider<ExerciseProvider>(
          create: (_) => ExerciseProvider(),
        ),
        ChangeNotifierProvider<WorkoutProvider>(
          create: (_) => WorkoutProvider(),
        ),
        ChangeNotifierProvider<RoutineProvider>(
          create: (_) => RoutineProvider(),
        ),
        ChangeNotifierProvider<AchievementProvider>(
          create: (_) => AchievementProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Fitness App',
        initialRoute: LoginScreen.routeName,
        routes: {
          '/loading': (context) =>
              Scaffold(body: Center(child: CircularProgressIndicator())),
          ...appRoutes,
        },
      ),
    );
  }
}
