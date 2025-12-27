import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

// Import your AuthProvider
import 'providers/auth/auth_provider.dart';

// Import your routes
import 'routes/app_routes.dart';

// Import your screens
import 'screens/app_screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from the .env file
  await dotenv.load(fileName: ".env");

  // Run the app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthProvider>(
      create: (_) => AuthProvider()..tryAutoLogin(),
      child: Consumer<AuthProvider>(
        builder: (ctx, auth, _) {
          return MaterialApp(
            title: 'Fitness App',
            initialRoute: auth.isLoading
                ? '/loading'
                : auth.token != null
                ? HomeScreen.routeName
                : LoginScreen.routeName,
            routes: {
              '/loading': (context) =>
                  Scaffold(body: Center(child: CircularProgressIndicator())),
              ...appRoutes,
            },
          );
        },
      ),
    );
  }
}
