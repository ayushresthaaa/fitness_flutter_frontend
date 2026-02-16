class ApiEndpoints {
  // Base
  static const String baseUrl = 'http://192.168.1.82:4000/api';

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
      '/routines/$routineId/exercises/$exerciseId'; // PUT, DELETE

  //progress api endpoints
  static const String progressStats = '/progress/stats'; // GET
  static const String progressStreak = '/progress/streak'; // GET
  static const String progressWeekly = '/progress/weekly'; // GET
  static const String progressMonthly = '/progress/monthly'; // GET
  static const String progressMuscles = '/progress/muscles'; // GET
  static const String progressPersonalBests = '/progress/personal-bests'; // GET
  static const String progressHistory = '/progress/history'; // GET

  static String exerciseProgress(String exerciseId) =>
      '/progress/exercise/$exerciseId'; // GET

  //ahievements api endpoints
  static const String achievements = '/achievements'; // GET
  static const String checkAchievements = '/achievements/check'; // POST
  static const String addAchievement = '/achievements'; // POST (admin)
}
