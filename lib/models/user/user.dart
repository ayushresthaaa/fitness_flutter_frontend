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
      return null;
    }
  }

  String toJson() => name;

  String get label {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
    }
  }
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

  String get label {
    switch (this) {
      case FitnessGoal.lose_fat:
        return 'Lose Fat';
      case FitnessGoal.gain_muscle:
        return 'Gain Muscle';
      case FitnessGoal.maintain:
        return 'Maintain';
    }
  }
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

  String get label {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Sedentary';
      case ActivityLevel.light:
        return 'Light';
      case ActivityLevel.moderate:
        return 'Moderate';
      case ActivityLevel.active:
        return 'Active';
      case ActivityLevel.very_active:
        return 'Very Active';
    }
  }
}

enum EquipmentAccess {
  full_gym,
  garage_gym,
  dumbbell_only,
  at_home;

  static EquipmentAccess? fromString(String? value) {
    if (value == null) return null;
    try {
      return EquipmentAccess.values.firstWhere(
        (e) => e.name.toLowerCase() == value.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  String toJson() => name;

  String get label {
    switch (this) {
      case EquipmentAccess.full_gym:
        return 'Full Gym';
      case EquipmentAccess.garage_gym:
        return 'Garage Gym';
      case EquipmentAccess.dumbbell_only:
        return 'Dumbbells Only';
      case EquipmentAccess.at_home:
        return 'At Home';
    }
  }
}

class User {
  final int id;
  final String email;
  final String? name;
  final String? oauthProvider;
  final String? oauthId;
  final DateTime? createdAt;
  final UserProfile? profile;
  final String plan;
  final String role;

  User({
    required this.id,
    required this.email,
    this.name,
    this.oauthProvider,
    this.oauthId,
    this.createdAt,
    this.profile,
    this.plan = 'free',
    this.role = 'user',
  });

  bool get isOAuth => oauthProvider != null;
  bool get isPro => plan == 'pro';
  bool get isTrainer => role == 'trainer';

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
      plan: json['plan'] ?? 'free',
      role: json['role'] ?? 'user',
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
    'plan': plan,
    'role': role,
  };
}

class UserProfile {
  final DateTime? dateOfBirth;
  final Gender? gender;
  final double? heightCm;
  final double? currentWeightKg;
  final FitnessGoal? fitnessGoal;
  final ActivityLevel? activityLevel;
  final EquipmentAccess? equipmentAccess;
  final bool isOnboardingComplete;

  UserProfile({
    this.dateOfBirth,
    this.gender,
    this.heightCm,
    this.currentWeightKg,
    this.fitnessGoal,
    this.activityLevel,
    this.equipmentAccess,
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
      equipmentAccess: EquipmentAccess.fromString(json['equipmentAccess']),
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
    'equipmentAccess': equipmentAccess?.toJson(),
    'isOnboardingComplete': isOnboardingComplete,
  };
}
