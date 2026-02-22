import '../base/base_provider.dart';
import '../../models/achievement/achievement_model.dart';
import '../../services/achievement/achievement_service.dart';

class AchievementProvider extends BaseProvider {
  final AchievementService _service = AchievementService();

  AchievementsSummary? _summary;

  AchievementsSummary? get summary => _summary;
  List<Achievement> get earned => _summary?.earned ?? [];
  List<Achievement> get locked => _summary?.locked ?? [];
  int get earnedCount => _summary?.earnedCount ?? 0;
  int get total => _summary?.total ?? 0;

  Future<void> fetchAchievements() async {
    final result = await execute(() => _service.getAchievements());
    if (result != null) {
      _summary = result;
      notifyListeners();
    }
  }
}
