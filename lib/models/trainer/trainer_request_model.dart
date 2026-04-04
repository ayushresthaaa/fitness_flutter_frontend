// lib/models/trainer/trainer_request_model.dart

class TrainerChangeRequest {
  final int id;
  final int userId;
  final String status;
  final String? reason;
  final String? adminNote;
  final int? assignedTrainerId;
  final int attemptCount;
  final List<int> rejectedByTrainerIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  // included on trainer side only
  final TrainerRequestUser? user;

  TrainerChangeRequest({
    required this.id,
    required this.userId,
    required this.status,
    this.reason,
    this.adminNote,
    this.assignedTrainerId,
    required this.attemptCount,
    required this.rejectedByTrainerIds,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory TrainerChangeRequest.fromJson(Map<String, dynamic> json) {
    return TrainerChangeRequest(
      id: json['id'],
      userId: json['userId'],
      status: json['status'],
      reason: json['reason'],
      adminNote: json['adminNote'],
      assignedTrainerId: json['assignedTrainerId'],
      attemptCount: json['attemptCount'] ?? 0,
      rejectedByTrainerIds: List<int>.from(json['rejectedByTrainerIds'] ?? []),
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt']).toLocal(),
      user: json['user'] != null
          ? TrainerRequestUser.fromJson(json['user'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'status': status,
      'reason': reason,
      'adminNote': adminNote,
      'assignedTrainerId': assignedTrainerId,
      'attemptCount': attemptCount,
      'rejectedByTrainerIds': rejectedByTrainerIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isPending =>
      status == 'pending_auto_assign' || status == 'pending_trainer_response';

  bool get isAccepted => status == 'accepted' || status == 'assigned_by_admin';

  bool get needsAdmin => status == 'needs_admin_attention';
  bool get isClosed => status == 'closed';

  String get statusLabel {
    switch (status) {
      case 'pending_auto_assign':
        return 'Finding a trainer';
      case 'pending_trainer_response':
        return 'Awaiting trainer confirmation';
      case 'accepted':
        return 'Trainer assigned';
      case 'rejected_by_trainer':
        return 'Searching again';
      case 'needs_admin_attention':
        return 'Under review by admin';
      case 'assigned_by_admin':
        return 'Manually assigned';
      case 'closed':
        return 'Closed';
      default:
        return status;
    }
  }

  String get statusDescription {
    switch (status) {
      case 'pending_auto_assign':
        return 'We are finding the best available trainer for you';
      case 'pending_trainer_response':
        return 'A trainer has been found and is reviewing your request';
      case 'accepted':
        return 'Your new trainer has been assigned successfully';
      case 'rejected_by_trainer':
        return 'The trainer was unavailable, searching for another';
      case 'needs_admin_attention':
        return 'Our team is handling this manually';
      case 'assigned_by_admin':
        return 'Our team has manually assigned a trainer to you';
      case 'closed':
        return adminNote ?? 'This request has been closed';
      default:
        return '';
    }
  }
}

// ─────────────────────────────────────────
// USER INFO (included on trainer side)
// ─────────────────────────────────────────

class TrainerRequestUser {
  final int id;
  final String name;
  final String email;
  final TrainerRequestUserProfile? profile;

  TrainerRequestUser({
    required this.id,
    required this.name,
    required this.email,
    this.profile,
  });

  factory TrainerRequestUser.fromJson(Map<String, dynamic> json) {
    return TrainerRequestUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profile: json['profile'] != null
          ? TrainerRequestUserProfile.fromJson(json['profile'])
          : null,
    );
  }
}

class TrainerRequestUserProfile {
  final String? fitnessGoal;
  final String? activityLevel;
  final String? equipmentAccess;
  final String? gender;

  TrainerRequestUserProfile({
    this.fitnessGoal,
    this.activityLevel,
    this.equipmentAccess,
    this.gender,
  });

  factory TrainerRequestUserProfile.fromJson(Map<String, dynamic> json) {
    return TrainerRequestUserProfile(
      fitnessGoal: json['fitnessGoal'],
      activityLevel: json['activityLevel'],
      equipmentAccess: json['equipmentAccess'],
      gender: json['gender'],
    );
  }

  String get fitnessGoalLabel {
    switch (fitnessGoal) {
      case 'lose_fat':
        return 'Lose Fat';
      case 'gain_muscle':
        return 'Gain Muscle';
      case 'maintain':
        return 'Maintain';
      default:
        return fitnessGoal ?? 'Not set';
    }
  }

  String get activityLevelLabel {
    switch (activityLevel) {
      case 'sedentary':
        return 'Sedentary';
      case 'light':
        return 'Light';
      case 'moderate':
        return 'Moderate';
      case 'active':
        return 'Active';
      case 'very_active':
        return 'Very Active';
      default:
        return activityLevel ?? 'Not set';
    }
  }
}
