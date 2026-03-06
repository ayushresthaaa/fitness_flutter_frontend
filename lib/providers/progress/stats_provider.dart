import '../../models/progress/stats_model.dart';
import '../../models/progress/progress_model.dart';
import '../../services/progress/stats_service.dart';
import '../base/base_provider.dart';

class StatsProvider extends BaseProvider {
  final StatsService _service = StatsService();

  OverallStats? _overallStats;
  List<WeeklyDay> _weeklyStats = [];
  List<MonthlyData> _monthlyStats = [];
  List<MuscleDistribution> _muscleDistribution = [];
  List<PersonalBest> _personalBests = [];
  int _currentStreak = 0;
  int _longestStreak = 0;

  OverallStats? get overallStats => _overallStats;
  List<WeeklyDay> get weeklyStats => _weeklyStats;
  List<MonthlyData> get monthlyStats => _monthlyStats;
  List<MuscleDistribution> get muscleDistribution => _muscleDistribution;
  List<PersonalBest> get personalBests => _personalBests;
  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;

  // Fetch everything at once when screen opens
  Future<void> fetchAll() async {
    await Future.wait([
      _fetchOverallStats(),
      _fetchWeeklyStats(),
      _fetchMonthlyStats(),
      _fetchMuscleDistribution(),
      _fetchStreak(),
      _fetchPersonalBests(),
    ]);
  }

  Future<void> _fetchOverallStats() async {
    final result = await execute(() => _service.getOverallStats());
    if (result != null) {
      _overallStats = result;
      notifyListeners();
    }
  }

  Future<void> _fetchWeeklyStats() async {
    final result = await execute(() => _service.getWeeklyStats());
    if (result != null) {
      _weeklyStats = result;
      notifyListeners();
    }
  }

  Future<void> _fetchMonthlyStats() async {
    final result = await execute(() => _service.getMonthlyStats());
    if (result != null) {
      _monthlyStats = result;
      notifyListeners();
    }
  }

  Future<void> _fetchMuscleDistribution() async {
    final result = await execute(() => _service.getMuscleDistribution());
    if (result != null) {
      _muscleDistribution = result;
      notifyListeners();
    }
  }

  Future<void> _fetchStreak() async {
    final result = await execute(() => _service.getStreak());
    if (result != null) {
      _currentStreak = result['currentStreak'] ?? 0;
      _longestStreak = result['longestStreak'] ?? 0;
      notifyListeners();
    }
  }

  Future<void> _fetchPersonalBests() async {
    final result = await execute(() => _service.getPersonalBests());
    if (result != null) {
      _personalBests = result;
      notifyListeners();
    }
  }

  void reset() {
    _overallStats = null;
    _weeklyStats = [];
    _monthlyStats = [];
    _muscleDistribution = [];
    _personalBests = [];
    _currentStreak = 0;
    _longestStreak = 0;
    clearError();
    notifyListeners();
  }
}
