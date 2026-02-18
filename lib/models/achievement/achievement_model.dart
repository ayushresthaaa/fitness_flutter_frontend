class Achievement {
  final String id;
  final String name;
  final String description;
  final String type;
  final int requirement;
  final String? iconUrl;
  final bool earned;
  final DateTime? unlockedAt;
  final DateTime createdAt;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.requirement,
    this.iconUrl,
    required this.earned,
    this.unlockedAt,
    required this.createdAt,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: json['type'],
      requirement: json['requirement'],
      iconUrl: json['iconUrl'],
      earned: json['earned'] ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'requirement': requirement,
      'iconUrl': iconUrl,
      'earned': earned,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class AchievementsSummary {
  final List<Achievement> earned;
  final List<Achievement> locked;
  final int total;
  final int earnedCount;

  AchievementsSummary({
    required this.earned,
    required this.locked,
    required this.total,
    required this.earnedCount,
  });

  factory AchievementsSummary.fromJson(Map<String, dynamic> json) {
    return AchievementsSummary(
      earned: (json['earned'] as List)
          .map((a) => Achievement.fromJson(a))
          .toList(),
      locked: (json['locked'] as List)
          .map((a) => Achievement.fromJson(a))
          .toList(),
      total: json['total'],
      earnedCount: json['earnedCount'],
    );
  }
}

class CheckAchievementsResult {
  final List<Achievement> newlyUnlocked;
  final int count;

  CheckAchievementsResult({required this.newlyUnlocked, required this.count});

  factory CheckAchievementsResult.fromJson(Map<String, dynamic> json) {
    return CheckAchievementsResult(
      newlyUnlocked: (json['newlyUnlocked'] as List)
          .map((a) => Achievement.fromJson(a))
          .toList(),
      count: json['count'],
    );
  }
}
