// Enums to match Prisma schema
enum Gender {
  male,
  female,
  other;

  static Gender? fromString(String? value) {
    if (value == null) return null;
    try {
      return Gender.values.firstWhere(
        (e) => e.name.toLowerCase() == value.toLowerCase(),
      );
    } catch (e) {
      return null; // Return null if invalid value
    }
  }

  String toJson() => name;
}

enum FitnessGoal {
  lose_fat,
  gain_muscle,
  maintain;

  static FitnessGoal? fromString(String? value) {
    if (value == null) return null;
    try {
      return FitnessGoal.values.firstWhere(
        (e) => e.name.toLowerCase() == value.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  String toJson() => name;
}

enum ActivityLevel {
  sedentary,
  light,
  moderate,
  active,
  very_active;

  static ActivityLevel? fromString(String? value) {
    if (value == null) return null;
    try {
      return ActivityLevel.values.firstWhere(
        (e) => e.name.toLowerCase() == value.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  String toJson() => name;
}

class User {
  final int id;
  final String email;
  final String? name;
  final String? oauthProvider;
  final String? oauthId;
  final DateTime? createdAt;
  final UserProfile? profile;

  User({
    required this.id,
    required this.email,
    this.name,
    this.oauthProvider,
    this.oauthId,
    this.createdAt,
    this.profile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      oauthProvider: json['oauthProvider'],
      oauthId: json['oauthId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      profile: json['profile'] != null
          ? UserProfile.fromJson(json['profile'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'oauthProvider': oauthProvider,
    'oauthId': oauthId,
    'createdAt': createdAt?.toIso8601String(),
    'profile': profile?.toJson(),
  };
}

class UserProfile {
  final DateTime? dateOfBirth;
  final Gender? gender;
  final double? heightCm;
  final double? currentWeightKg;
  final FitnessGoal? fitnessGoal;
  final ActivityLevel? activityLevel;
  final bool isOnboardingComplete;

  UserProfile({
    this.dateOfBirth,
    this.gender,
    this.heightCm,
    this.currentWeightKg,
    this.fitnessGoal,
    this.activityLevel,
    this.isOnboardingComplete = false,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      gender: Gender.fromString(json['gender']),
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      currentWeightKg: (json['currentWeightKg'] as num?)?.toDouble(),
      fitnessGoal: FitnessGoal.fromString(json['fitnessGoal']),
      activityLevel: ActivityLevel.fromString(json['activityLevel']),
      isOnboardingComplete: json['isOnboardingComplete'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'dateOfBirth': dateOfBirth?.toIso8601String(),
    'gender': gender?.toJson(),
    'heightCm': heightCm,
    'currentWeightKg': currentWeightKg,
    'fitnessGoal': fitnessGoal?.toJson(),
    'activityLevel': activityLevel?.toJson(),
    'isOnboardingComplete': isOnboardingComplete,
  };
}
