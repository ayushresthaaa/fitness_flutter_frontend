class ApiEndpoints {
  static const String ip = '192.168.1.76';
  // Base
  // static const String baseUrl = 'http://192.168.1.76:4000/api';
  static const String baseUrl = 'http://192.168.1.76:4000/api';

  //authentication endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String getCurrentUser = '/auth/me'; // POST (requires token)
  static const String googleRedirect = '/auth/google'; // GET
  static const String googleCallback = '/auth/google/callback'; // GET
  static const String googleMobile = '/auth/google/mobile'; // POST
  static const String getUsers = '/auth/getusers'; // GET (test)

  //users endpoint
  static const String onboarding = '/users/me/onboarding'; // POST

  //exercises enpoints
  // Meta (no auth required)
  static const String exerciseMuscles = '/exercises/meta/muscles'; // GET
  static const String exerciseCategories = '/exercises/meta/categories'; // GET

  // Authenticated
  static const String exercises = '/exercises'; // GET

  static String exerciseById(String id) => '/exercises/$id'; // GET
  static String exerciseByMuscle(String muscleGroup) =>
      '/exercises/muscle/$muscleGroup'; // GET

  //workout api endpoints
  static const String workouts = '/workouts'; // POST, GET

  static String workoutById(String id) => '/workouts/$id'; // GET, DELETE
  static String finishWorkout(String id) => '/workouts/$id/finish'; // PUT

  static String workoutExercises(String workoutId) =>
      '/workouts/$workoutId/exercises'; // POST

  static String workoutExerciseById(String workoutId, String exerciseId) =>
      '/workouts/$workoutId/exercises/$exerciseId'; // PUT, DELETE

  //routine api endpoints
  static const String routines = '/routines'; // POST, GET

  static String routineById(String id) => '/routines/$id'; // GET, PUT, DELETE
  static String startRoutine(String id) => '/routines/$id/start'; // POST

  static String routineExercises(String routineId) =>
      '/routines/$routineId/exercises'; // POST

  static String routineExerciseById(String routineId, String exerciseId) =>
      '/routines/$routineId/exercises/$exerciseId'; // PUT, DELETE),

  // Weekly Program endpoints
  static const String weeklyProgram = '/weekly-program';
  static const String weeklyProgramToday = '/weekly-program/today';
  static String weeklyProgramDay(String dayId) => '/weekly-program/days/$dayId';

  //progress endpoints
  static const String personalBests = '/progress/personal-bests';
  static String exerciseProgress(String id) => '/progress/exercise/$id';

  // History endpoints
  static const String history = '/history';
  static const String historySearch = '/history/search';
  static const String historyStreak = '/history/streak';
  static const String historyMonthlyStats = '/history/monthly-stats';

  //ahievements api endpoints
  static const String achievements = '/achievements'; // GET
  static const String checkAchievements = '/achievements/check'; // POST
  static const String addAchievement = '/achievements'; // POST (admin)
}
