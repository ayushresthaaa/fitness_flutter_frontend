class User {
  final int id;
  final String email;
  final String? name;
  final String? oauthProvider;
  final String? oauthId;
  final DateTime? createdAt; // Make this nullable

  User({
    required this.id,
    required this.email,
    this.name,
    this.oauthProvider,
    this.oauthId,
    this.createdAt, // Remove 'required'
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
          : null, // Handle null case
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'oauthProvider': oauthProvider,
    'oauthId': oauthId,
    'createdAt': createdAt?.toIso8601String(),
  };
}
