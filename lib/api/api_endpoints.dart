class ApiEndpoints {
  static const String ip = '192.168.1.76';
  // Base
  // static const String baseUrl = 'http://192.168.1.76:4000/api';
  static const String baseUrl =
      'https://antral-susan-undazed.ngrok-free.dev/api';

  // Static files host (images, etc.)
  static const String staticHost =
      'https://antral-susan-undazed.ngrok-free.dev';

  //authentication endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String getCurrentUser = '/auth/me'; // POST (requires token)
  static const String googleRedirect = '/auth/google'; // GET
  static const String googleCallback = '/auth/google/callback'; // GET
  static const String googleMobile = '/auth/google/mobile'; // POST
  static const String getUsers = '/auth/getusers'; // GET (test)

  //users endpoint
  static const String onboarding = '/users/me/onboarding';
  static const String me = '/auth/me';
  static const String updateAccount = '/users/me';
  static const String updateProfile = '/users/me/profile';
  static const String changePassword = '/users/me/password';
  //exercises enpoints
  // Meta (no auth required)
  static const String exerciseMuscles = '/exercises/meta/muscles'; // GET
  static const String exerciseCategories = '/exercises/meta/categories'; // GET

  // Authenticated
  static const String exercises = '/exercises'; // GET

  static String exerciseById(String id) => '/exercises/$id'; // GET
  static String exerciseByMuscle(String muscleGroup) =>
      '/exercises/muscle/$muscleGroup'; // GET

  //custom exercises
  static const String customExercises = '/exercises/custom';
  static String customExerciseById(String id) => '/exercises/custom/$id';
  //workout api endpoints
  static const String workouts = '/workouts'; // POST, GET

  static String workoutById(String id) => '/workouts/$id'; // GET, DELETE
  static String finishWorkout(String id) => '/workouts/$id/finish'; // PUT

  static String workoutExercises(String workoutId) =>
      '/workouts/$workoutId/exercises'; // POST

  static String workoutExerciseById(String workoutId, String exerciseId) =>
      '/workouts/$workoutId/exercises/$exerciseId'; // PUT, DELETE

  static const String todayWorkoutSummary = '/workouts/today-summary';
  //routine api endpoints
  static const String routines = '/routines'; // POST, GET

  static String routineById(String id) => '/routines/$id'; // GET, PUT, DELETE
  static String startRoutine(String id) => '/routines/$id/start'; // POST

  static String routineExercises(String routineId) =>
      '/routines/$routineId/exercises'; // POST

  static String routineExerciseById(String routineId, String exerciseId) =>
      '/routines/$routineId/exercises/$exerciseId'; // PUT, DELETE),

  static String sendRoutineForReview(String id) =>
      '/routines/$id/send-for-review'; // POST

  // Weekly Program endpoints
  static const String weeklyProgram = '/weekly-program';
  static const String weeklyProgramToday = '/weekly-program/today';
  static String weeklyProgramDay(String dayId) => '/weekly-program/days/$dayId';

  //progress endpoints
  static const String personalBests = '/progress/personal-bests';
  static String exerciseProgress(String id) => '/progress/exercise/$id';

  // Stats endpoints
  static const String overallStats = '/progress/stats';
  static const String weeklyStats = '/progress/weekly';
  static const String monthlyStats = '/progress/monthly';
  static const String muscleDistribution = '/progress/muscles';
  static const String streak = '/progress/streak';
  // History endpoints
  static const String history = '/history';
  static const String historySearch = '/history/search';
  static const String historyStreak = '/history/streak';
  static const String historyMonthlyStats = '/history/monthly-stats';

  //ahievements api endpoints
  static const String achievements = '/achievements'; // GET
  static const String checkAchievements = '/achievements/check'; // POST
  static const String addAchievement = '/achievements'; // POST (admin)

  //notification endpoints
  static const String notifications = '/notifications'; // GET
  static const String notificationsUnreadCount =
      '/notifications/unread-count'; // GET
  static const String notificationsMarkAllRead =
      '/notifications/read-all'; // PATCH
  static String notificationMarkRead(String id) =>
      '/notifications/$id/read'; // PATCH
  static String notificationDelete(String id) => '/notifications/$id'; // DELETE

  // Ecommerce endpoints
  static const String products = '/products';
  static const String featuredProducts = '/products/featured';
  static String productById(String id) => '/products/$id';

  static const String categories = '/categories';

  static const String cart = '/cart';
  static String cartItem(String itemId) => '/cart/$itemId';

  static const String orders = '/orders';
  static String orderById(String id) => '/orders/$id';

  // Payment endpoints
  static const String checkoutInitiate = '/payments/checkout';
  static const String checkoutVerify = '/payments/checkout/verify';

  static const String generateRoutine = '/mlv3/generate';

  //meal endpoints
  static const String mealGoal = '/meal/goal';
  static const String mealFoods = '/meal/foods';
  static const String mealFoodsRecent = '/meal/foods/recent';
  static const String mealFoodsCustom = '/meal/foods/custom';
  static String mealFoodsCustomById(String id) => '/meal/foods/custom/$id';
  static const String mealLogToday = '/meal/log/today';
  static String mealLogByDate(String date) => '/meal/log/$date';
  static const String mealLogSlots = '/meal/log/slots';
  static String mealLogSlotItems(String slotId) => '/meal/log/$slotId/items';
  static String mealLogItemById(String itemId) => '/meal/log/items/$itemId';
  static const String mealLogWater = '/meal/log/today/water';
  static const String mealLogWaterGoal = '/meal/log/today/water-goal';
  static const String mealInsights = '/meal/insights';
  static const String mealInsightHistory = '/meal/history';

  // Trainer request — user side
  static const String myTrainer = '/users/my-trainer';
  static const String submitTrainerRequest = '/users/trainer-request';
  static const String myTrainerRequests = '/users/trainer-request';

  static const String mealHistory = '/meal/log/history';
  static String mealLogReview(String date) => '/meal/log/$date/review';

  // Reminder endpoints
  static const String reminders = '/reminders';
  static String reminderToggle(String id) => '/reminders/$id/toggle';
  static String reminderById(String id) => '/reminders/$id';
}
