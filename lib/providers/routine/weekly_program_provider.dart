import '../../models/routine/weekly_program_model.dart';
import '../../services/routine/weekly_program_service.dart';
import '../base/base_provider.dart';

class WeeklyProgramProvider extends BaseProvider {
  final WeeklyProgramService _service = WeeklyProgramService();

  WeeklyProgram? _program;
  WeeklyProgramDay? _today;

  // Getters
  WeeklyProgram? get program => _program;
  WeeklyProgramDay? get today => _today;

  // GET /api/weekly-program — fetches or auto-creates program
  Future<void> fetchProgram() async {
    final result = await execute(() => _service.getProgram());
    if (result != null) {
      _program = result;
      notifyListeners();
    }
  }

  // GET /api/weekly-program/today
  Future<void> fetchToday() async {
    final result = await execute(() => _service.getToday());
    if (result != null) {
      _today = result;
      notifyListeners();
    }
  }

  // PATCH /api/weekly-program/days/:dayId — assign routine
  Future<void> assignRoutine(String dayId, String routineId) async {
    final result = await execute(
      () => _service.assignRoutine(dayId, routineId: routineId),
    );
    if (result != null) {
      _updateDayInProgram(result);
    }
  }

  // PATCH /api/weekly-program/days/:dayId — set back to rest
  Future<void> setRestDay(String dayId) async {
    final result = await execute(
      () => _service.assignRoutine(dayId, routineId: null),
    );
    if (result != null) {
      _updateDayInProgram(result);
    }
  }

  // Updates the day in local program state without re-fetching
  void _updateDayInProgram(WeeklyProgramDay updatedDay) {
    if (_program == null) return;
    final updatedDays = _program!.days.map((d) {
      return d.id == updatedDay.id ? updatedDay : d;
    }).toList();
    _program = WeeklyProgram(
      id: _program!.id,
      userId: _program!.userId,
      name: _program!.name,
      isActive: _program!.isActive,
      days: updatedDays,
      createdAt: _program!.createdAt,
      updatedAt: _program!.updatedAt,
    );
    // Also update today if it was the day that changed
    if (_today?.id == updatedDay.id) {
      _today = updatedDay;
    }
    notifyListeners();
  }

  // Reset
  void reset() {
    _program = null;
    _today = null;
    clearError();
    notifyListeners();
  }
}
