import '../../models/progress/progress_model.dart';
import '../../services/progress/progress_service.dart';
import '../base/base_provider.dart';

class ProgressProvider extends BaseProvider {
  final ProgressService _service = ProgressService();

  List<PersonalBest> _personalBests = [];
  ExerciseProgressData? _exerciseProgress;

  List<PersonalBest> get personalBests => _personalBests;
  ExerciseProgressData? get exerciseProgress => _exerciseProgress;

  Future<void> fetchPersonalBests() async {
    final result = await execute(() => _service.getPersonalBests());
    if (result != null) {
      _personalBests = result;
      notifyListeners();
    }
  }

  Future<void> fetchExerciseProgress(String exerciseId) async {
    _exerciseProgress = null;
    notifyListeners();
    final result = await execute(
      () => _service.getExerciseProgress(exerciseId),
    );
    if (result != null) {
      _exerciseProgress = result;
      notifyListeners();
    }
  }

  //pr calculation
  // All computed from _exerciseProgress.history

  // Heaviest weight ever lifted for this exercise
  double? get heaviestWeight {
    if (_exerciseProgress == null) return null;
    final weights = _exerciseProgress!.history
        .map((p) => p.maxWeightKg)
        .whereType<double>()
        .toList();
    if (weights.isEmpty) return null;
    return weights.reduce((a, b) => a > b ? a : b);
  }

  // Best 1RM estimate using Epley formula: weight × (1 + reps/30)
  double? get best1RM {
    if (_exerciseProgress == null) return null;
    double? best;
    for (final point in _exerciseProgress!.history) {
      for (final set in point.sets) {
        if (!set.isCompleted || set.isWarmup) continue;
        if (set.weightKg == null || set.reps == null || set.reps! <= 0)
          continue;
        final estimate = set.weightKg! * (1 + set.reps! / 30);
        if (best == null || estimate > best) best = estimate;
      }
    }
    return best;
  }

  // Best single set volume (weight × reps)
  double? get bestSetVolume {
    if (_exerciseProgress == null) return null;
    double? best;
    for (final point in _exerciseProgress!.history) {
      for (final set in point.sets) {
        if (!set.isCompleted || set.isWarmup) continue;
        if (set.weightKg == null || set.reps == null) continue;
        final vol = set.weightKg! * set.reps!;
        if (best == null || vol > best) best = vol;
      }
    }
    return best;
  }

  // Best session total volume
  double? get bestSessionVolume {
    if (_exerciseProgress == null) return null;
    if (_exerciseProgress!.history.isEmpty) return null;
    return _exerciseProgress!.history
        .map((p) => p.volume)
        .reduce((a, b) => a > b ? a : b);
  }

  // Set records: best weight per rep count (sorted by reps asc)
  Map<int, double> get setRecords {
    if (_exerciseProgress == null) return {};
    final records = <int, double>{};
    for (final point in _exerciseProgress!.history) {
      for (final set in point.sets) {
        if (!set.isCompleted || set.isWarmup) continue;
        if (set.reps == null || set.weightKg == null) continue;
        final current = records[set.reps!];
        if (current == null || set.weightKg! > current) {
          records[set.reps!] = set.weightKg!;
        }
      }
    }
    return Map.fromEntries(
      records.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  // Chart data for heaviest weight over time
  List<Map<String, dynamic>> get weightChartData {
    if (_exerciseProgress == null) return [];
    return _exerciseProgress!.history
        .where((p) => p.maxWeightKg != null)
        .map((p) => {'date': p.date, 'value': p.maxWeightKg!})
        .toList();
  }

  // Chart data for volume over time
  List<Map<String, dynamic>> get volumeChartData {
    if (_exerciseProgress == null) return [];
    return _exerciseProgress!.history
        .where((p) => p.volume > 0)
        .map((p) => {'date': p.date, 'value': p.volume})
        .toList();
  }

  // Chart data for estimated 1RM over time
  List<Map<String, dynamic>> get oneRMChartData {
    if (_exerciseProgress == null) return [];
    final data = <Map<String, dynamic>>[];
    for (final point in _exerciseProgress!.history) {
      double? best;
      for (final set in point.sets) {
        if (!set.isCompleted || set.isWarmup) continue;
        if (set.weightKg == null || set.reps == null || set.reps! <= 0)
          continue;
        final estimate = set.weightKg! * (1 + set.reps! / 30);
        if (best == null || estimate > best) best = estimate;
      }
      if (best != null) data.add({'date': point.date, 'value': best});
    }
    return data;
  }

  void reset() {
    _personalBests = [];
    _exerciseProgress = null;
    clearError();
    notifyListeners();
  }
}
