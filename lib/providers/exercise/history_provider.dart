import '../../models/exercise/history_model.dart';
import '../../services/exercise/history_service.dart';
import '../base/base_provider.dart';

class HistoryProvider extends BaseProvider {
  final HistoryService _service = HistoryService();

  // State
  List<WorkoutHistory> _workouts = [];
  List<WorkoutHistory> _searchResults = [];
  StreakData? _streak;
  MonthlyStats? _monthlyStats;
  String _currentMonth = _thisMonth();
  DateTime _selectedDay = DateTime.now();
  bool _isSearching = false;

  // Getters
  List<WorkoutHistory> get workouts => _workouts;
  List<WorkoutHistory> get searchResults => _searchResults;
  StreakData? get streak => _streak;
  MonthlyStats? get monthlyStats => _monthlyStats;
  String get currentMonth => _currentMonth;
  DateTime get selectedDay => _selectedDay;
  bool get isSearching => _isSearching;

  // Workout dates for calendar dots
  Set<String> get workoutDates =>
      _workouts.map((w) => _dateKey(w.startTime)).toSet();

  // Workouts for selected day
  List<WorkoutHistory> get selectedDayWorkouts => _workouts
      .where((w) => _dateKey(w.startTime) == _dateKey(_selectedDay))
      .toList();

  // Fetch history for current month
  Future<void> fetchHistory({String? month}) async {
    final m = month ?? _currentMonth;
    final result = await execute(() => _service.getHistoryByMonth(m));
    if (result != null) {
      _workouts = result;
      notifyListeners();
    }
  }

  // Fetch monthly stats
  Future<void> fetchMonthlyStats({String? month}) async {
    final m = month ?? _currentMonth;
    final result = await execute(() => _service.getMonthlyStats(m));
    if (result != null) {
      _monthlyStats = result;
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

  // Fetch all on init
  Future<void> fetchAll() async {
    await Future.wait([fetchHistory(), fetchMonthlyStats(), fetchStreak()]);
    // Auto-select most recent workout day
    // so screen never opens empty
    if (_workouts.isNotEmpty) {
      _selectedDay = _workouts.first.startTime;
      notifyListeners();
    }
  }

  // Search workouts
  Future<void> search(String q) async {
    if (q.trim().isEmpty) {
      clearSearch();
      return;
    }
    final result = await execute(() => _service.searchWorkouts(q.trim()));
    if (result != null) {
      _searchResults = result;
      notifyListeners();
    }
  }

  // Toggle search mode
  void setSearching(bool value) {
    _isSearching = value;
    if (!value) clearSearch();
    notifyListeners();
  }

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }

  // Select a day on calendar
  void selectDay(DateTime day) {
    _selectedDay = day;
    notifyListeners();
  }

  // Navigate to previous month
  Future<void> previousMonth() async {
    final parts = _currentMonth.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final prev = month == 1
        ? '${year - 1}-12'
        : '$year-${(month - 1).toString().padLeft(2, '0')}';
    _currentMonth = prev;
    _selectedDay = DateTime(
      int.parse(prev.split('-')[0]),
      int.parse(prev.split('-')[1]),
      1,
    );
    notifyListeners();
    await Future.wait([
      fetchHistory(month: prev),
      fetchMonthlyStats(month: prev),
    ]);
  }

  // Navigate to next month
  Future<void> nextMonth() async {
    final parts = _currentMonth.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final next = month == 12
        ? '${year + 1}-01'
        : '$year-${(month + 1).toString().padLeft(2, '0')}';
    _currentMonth = next;
    _selectedDay = DateTime(
      int.parse(next.split('-')[0]),
      int.parse(next.split('-')[1]),
      1,
    );
    notifyListeners();
    await Future.wait([
      fetchHistory(month: next),
      fetchMonthlyStats(month: next),
    ]);
  }

  // Reset
  void reset() {
    _workouts = [];
    _searchResults = [];
    _streak = null;
    _monthlyStats = null;
    _currentMonth = _thisMonth();
    _selectedDay = DateTime.now();
    _isSearching = false;
    clearError();
    notifyListeners();
  }

  // Helpers
  static String _thisMonth() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  static String _dateKey(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
