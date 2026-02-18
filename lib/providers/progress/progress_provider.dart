import '../../models/progress/progress_model.dart';
import '../../services/progress/progress_service.dart';
import '../base/base_provider.dart';

class ProgressProvider extends BaseProvider {
  final ProgressService _service = ProgressService();

  // Stats data
  OverallStats? _overallStats;
  Streak? _streak;
  List<WeeklyDay> _weeklyStats = [];
  List<MonthlyData> _monthlyStats = [];
  List<MuscleDistribution> _muscleDistribution = [];
  List<PersonalBest> _personalBests = [];
  ExerciseProgressData? _exerciseProgress;
  List<WorkoutHistoryItem> _workoutHistory = [];

  // Pagination for history
  int _currentPage = 1;
  int _totalPages = 1;
  int _total = 0;
  bool _hasMore = true;

  // Getters
  OverallStats? get overallStats => _overallStats;
  Streak? get streak => _streak;
  List<WeeklyDay> get weeklyStats => _weeklyStats;
  List<MonthlyData> get monthlyStats => _monthlyStats;
  List<MuscleDistribution> get muscleDistribution => _muscleDistribution;
  List<PersonalBest> get personalBests => _personalBests;
  ExerciseProgressData? get exerciseProgress => _exerciseProgress;
  List<WorkoutHistoryItem> get workoutHistory => _workoutHistory;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get total => _total;
  bool get hasMore => _hasMore;

  // Fetch overall stats
  Future<void> fetchOverallStats() async {
    final result = await execute(() => _service.getOverallStats());
    if (result != null) {
      _overallStats = result;
      notifyListeners();
    }
  }

  // Fetch streak
  Future<void> fetchStreak() async {
    final result = await execute(() => _service.getStreak());
    if (result != null) {
      _streak = result;
      notifyListeners();
    }
  }

  // Fetch weekly stats
  Future<void> fetchWeeklyStats() async {
    final result = await execute(() => _service.getWeeklyStats());
    if (result != null) {
      _weeklyStats = result;
      notifyListeners();
    }
  }

  // Fetch monthly stats
  Future<void> fetchMonthlyStats() async {
    final result = await execute(() => _service.getMonthlyStats());
    if (result != null) {
      _monthlyStats = result;
      notifyListeners();
    }
  }

  // Fetch muscle distribution
  Future<void> fetchMuscleDistribution() async {
    final result = await execute(() => _service.getMuscleDistribution());
    if (result != null) {
      _muscleDistribution = result;
      notifyListeners();
    }
  }

  // Fetch personal bests
  Future<void> fetchPersonalBests() async {
    final result = await execute(() => _service.getPersonalBests());
    if (result != null) {
      _personalBests = result;
      notifyListeners();
    }
  }

  // Fetch exercise progress
  Future<void> fetchExerciseProgress(String exerciseId) async {
    final result = await execute(
      () => _service.getExerciseProgress(exerciseId),
    );
    if (result != null) {
      _exerciseProgress = result;
      notifyListeners();
    }
  }

  // Fetch workout history
  Future<void> fetchWorkoutHistory({
    int page = 1,
    int limit = 10,
    bool loadMore = false,
  }) async {
    final result = await execute(
      () => _service.getWorkoutHistory(page: page, limit: limit),
    );

    if (result != null) {
      final List<WorkoutHistoryItem> newHistory = result['workouts'];

      if (loadMore) {
        _workoutHistory.addAll(newHistory);
      } else {
        _workoutHistory = newHistory;
      }

      final pagination = result['pagination'];
      _currentPage = pagination['page'];
      _totalPages = pagination['totalPages'];
      _total = pagination['total'];
      _hasMore = _currentPage < _totalPages;

      notifyListeners();
    }
  }

  // Load more history
  Future<void> loadMoreHistory() async {
    if (!_hasMore || isLoading) return;
    await fetchWorkoutHistory(page: _currentPage + 1, loadMore: true);
  }

  // Fetch all dashboard data at once
  Future<void> fetchDashboardData() async {
    await Future.wait([
      fetchOverallStats(),
      fetchStreak(),
      fetchWeeklyStats(),
      fetchMuscleDistribution(),
    ]);
  }

  // Reset provider
  void reset() {
    _overallStats = null;
    _streak = null;
    _weeklyStats = [];
    _monthlyStats = [];
    _muscleDistribution = [];
    _personalBests = [];
    _exerciseProgress = null;
    _workoutHistory = [];
    _currentPage = 1;
    _totalPages = 1;
    _total = 0;
    _hasMore = true;
    clearError();
    notifyListeners();
  }
}
