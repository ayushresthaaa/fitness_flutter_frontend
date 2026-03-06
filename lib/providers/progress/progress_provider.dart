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
    final seen = <String, double>{};
    for (final p in _exerciseProgress!.history) {
      if (p.maxWeightKg == null) continue;
      final dateKey = p.date.toIso8601String().split('T')[0];
      final current = seen[dateKey];
      if (current == null || p.maxWeightKg! > current) {
        seen[dateKey] = p.maxWeightKg!;
      }
    }
    return seen.entries
        .map((e) => {'date': DateTime.parse(e.key), 'value': e.value})
        .toList();
  }

  // Chart data for volume over time
  List<Map<String, dynamic>> get volumeChartData {
    if (_exerciseProgress == null) return [];
    final seen = <String, double>{};
    for (final p in _exerciseProgress!.history) {
      if (p.volume <= 0) continue;
      final dateKey = p.date.toIso8601String().split('T')[0];
      final current = seen[dateKey];
      if (current == null || p.volume > current) {
        seen[dateKey] = p.volume;
      }
    }
    return seen.entries
        .map((e) => {'date': DateTime.parse(e.key), 'value': e.value})
        .toList();
  }

  // Chart data for estimated 1RM over time
  List<Map<String, dynamic>> get oneRMChartData {
    if (_exerciseProgress == null) return [];
    final seen = <String, double>{};
    for (final point in _exerciseProgress!.history) {
      final dateKey = point.date.toIso8601String().split('T')[0];
      for (final set in point.sets) {
        if (!set.isCompleted || set.isWarmup) continue;
        if (set.weightKg == null || set.reps == null || set.reps! <= 0)
          continue;
        final estimate = set.weightKg! * (1 + set.reps! / 30);
        final current = seen[dateKey];
        if (current == null || estimate > current) {
          seen[dateKey] = estimate;
        }
      }
    }
    return seen.entries
        .map((e) => {'date': DateTime.parse(e.key), 'value': e.value})
        .toList();
  }

  // Best duration per day (cardio)
  List<Map<String, dynamic>> get durationChartData {
    if (_exerciseProgress == null) return [];
    final seen = <String, double>{};
    for (final point in _exerciseProgress!.history) {
      final dateKey = point.date.toIso8601String().split('T')[0];
      for (final set in point.sets) {
        if (!set.isCompleted || set.isWarmup) continue;
        if (set.durationSec == null) continue;
        final current = seen[dateKey];
        if (current == null || set.durationSec!.toDouble() > current) {
          seen[dateKey] = set.durationSec!.toDouble();
        }
      }
    }
    return seen.entries
        .map((e) => {'date': DateTime.parse(e.key), 'value': e.value})
        .toList();
  }

  // Best distance per day (cardio)
  List<Map<String, dynamic>> get distanceChartData {
    if (_exerciseProgress == null) return [];
    final seen = <String, double>{};
    for (final point in _exerciseProgress!.history) {
      final dateKey = point.date.toIso8601String().split('T')[0];
      for (final set in point.sets) {
        if (!set.isCompleted || set.isWarmup) continue;
        if (set.distanceMeters == null) continue;
        final current = seen[dateKey];
        if (current == null || set.distanceMeters! > current) {
          seen[dateKey] = set.distanceMeters!;
        }
      }
    }
    return seen.entries
        .map((e) => {'date': DateTime.parse(e.key), 'value': e.value})
        .toList();
  }

  void reset() {
    _personalBests = [];
    _exerciseProgress = null;
    clearError();
    notifyListeners();
  }
}
