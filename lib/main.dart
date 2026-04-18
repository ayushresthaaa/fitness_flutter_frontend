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
import './providers/routine/weekly_program_provider.dart';
import './providers/exercise/history_provider.dart';
import './providers/progress/progress_provider.dart';
import './providers/progress/stats_provider.dart';
import './providers/exercise/custom_exercise_provider.dart';
import './providers/notification/notification_provider.dart';
import './providers/ecommerce/product_provider.dart';
import './providers/ecommerce/cart_provider.dart';
import './providers/ecommerce/order_provider.dart';
import './providers/meal/food_provider.dart';
import './providers/meal/meal_log_provider.dart';
import './providers/meal/meal_insights_provider.dart';
import './providers/meal/nutrition_goal_provider.dart';
import './providers/trainer/trainer_request_provider.dart';
import './providers/home/home_provider.dart';
import './providers/reminders/reminders_provider.dart';
import './services/notification/notification_schedular.dart';
import './providers/payment/subscription_provider.dart';

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
  await initNotifications();
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
        ChangeNotifierProvider<WeeklyProgramProvider>(
          create: (_) => WeeklyProgramProvider(),
        ),
        ChangeNotifierProvider<HistoryProvider>(
          create: (_) => HistoryProvider(),
        ),
        ChangeNotifierProvider<ProgressProvider>(
          create: (_) => ProgressProvider(),
        ),
        ChangeNotifierProvider<StatsProvider>(create: (_) => StatsProvider()),
        ChangeNotifierProvider<CustomExerciseProvider>(
          create: (_) => CustomExerciseProvider(),
        ),
        ChangeNotifierProvider<NotificationProvider>(
          create: (_) => NotificationProvider(),
        ),
        ChangeNotifierProvider<ProductProvider>(
          create: (_) => ProductProvider(),
        ),
        ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
        ChangeNotifierProvider<OrderProvider>(create: (_) => OrderProvider()),
        ChangeNotifierProvider<FoodProvider>(create: (_) => FoodProvider()),
        ChangeNotifierProvider<MealLogProvider>(
          create: (_) => MealLogProvider(),
        ),
        ChangeNotifierProvider<MealInsightsProvider>(
          create: (_) => MealInsightsProvider(),
        ),
        ChangeNotifierProvider<NutritionGoalProvider>(
          create: (_) => NutritionGoalProvider(),
        ),
        ChangeNotifierProvider<TrainerRequestProvider>(
          create: (_) => TrainerRequestProvider(),
        ),
        ChangeNotifierProvider<HomeProvider>(create: (_) => HomeProvider()),
        ChangeNotifierProvider<ReminderProvider>(
          create: (_) => ReminderProvider(),
        ),
        ChangeNotifierProvider<SubscriptionProvider>(
          create: (_) => SubscriptionProvider(),
        ),
      ],
      builder: (context, child) {
        context.read<AuthProvider>().onNewNotification = (notification) {
          context.read<NotificationProvider>().addSocketNotification(
            notification,
          );
        };
        return child!;
      },
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
