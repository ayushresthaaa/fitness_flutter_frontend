import '../../models/exercise/exercise_model.dart';
import '../../services/exercise/exercise_service.dart';
import '../base/base_provider.dart';

class ExerciseProvider extends BaseProvider {
  final ExerciseService _service = ExerciseService();

  List<Exercise> _exercises = [];
  Exercise? _selectedExercise;
  List<String> _muscles = [];
  List<String> _categories = [];

  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  int _total = 0;
  bool _hasMore = true;

  // Getters
  List<Exercise> get exercises => _exercises;
  Exercise? get selectedExercise => _selectedExercise;
  List<String> get muscles => _muscles;
  List<String> get categories => _categories;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get total => _total;
  bool get hasMore => _hasMore;

  // Fetch exercises with filters and pagination
  Future<void> fetchExercises({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
    String? level,
    String? equipment,
    String? muscleGroup,
    bool loadMore = false,
  }) async {
    final result = await execute(
      () => _service.getExercises(
        page: page,
        limit: limit,
        search: search,
        category: category,
        level: level,
        equipment: equipment,
        muscleGroup: muscleGroup,
      ),
    );

    if (result != null) {
      final List<Exercise> newExercises = result['exercises'];

      if (loadMore) {
        _exercises.addAll(newExercises);
      } else {
        _exercises = newExercises;
      }

      final pagination = result['pagination'];
      _currentPage = pagination['page'];
      _totalPages = pagination['totalPages'];
      _total = pagination['total'];
      _hasMore = _currentPage < _totalPages;

      notifyListeners();
    }
  }

  // Load more exercises (for infinite scroll)
  Future<void> loadMoreExercises({
    String? search,
    String? category,
    String? level,
    String? equipment,
    String? muscleGroup,
  }) async {
    if (!_hasMore || isLoading) return;

    await fetchExercises(
      page: _currentPage + 1,
      search: search,
      category: category,
      level: level,
      equipment: equipment,
      muscleGroup: muscleGroup,
      loadMore: true,
    );
  }

  // Get single exercise by ID
  Future<void> fetchExerciseById(String id) async {
    final result = await execute(() => _service.getExerciseById(id));

    if (result != null) {
      _selectedExercise = result;
      notifyListeners();
    }
  }

  // Get exercises by muscle group
  Future<void> fetchExercisesByMuscle(String muscleGroup) async {
    final result = await execute(
      () => _service.getExercisesByMuscle(muscleGroup),
    );

    if (result != null) {
      _exercises = result;
      notifyListeners();
    }
  }

  // Fetch muscles list (meta, no auth required)
  Future<void> fetchMuscles() async {
    final result = await executeSilent(() => _service.getMuscles());

    if (result != null) {
      _muscles = result;
      notifyListeners();
    }
  }

  // Fetch categories list (meta, no auth required)
  Future<void> fetchCategories() async {
    final result = await executeSilent(() => _service.getCategories());

    if (result != null) {
      _categories = result;
      notifyListeners();
    }
  }

  // Clear selected exercise
  void clearSelectedExercise() {
    _selectedExercise = null;
    notifyListeners();
  }

  // Reset provider to initial state
  void reset() {
    _exercises = [];
    _selectedExercise = null;
    _muscles = [];
    _categories = [];
    _currentPage = 1;
    _totalPages = 1;
    _total = 0;
    _hasMore = true;
    clearError();
    notifyListeners();
  }
}
