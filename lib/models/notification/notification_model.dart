// Model for a single notification from the backend
class AppNotification {
  final int id;
  final int userId;
  final String title;
  final String body;
  final String
  type; // "routine_review" | "routine_reviewed" | "routine_updated"
  final bool read;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.read,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      body: json['body'],
      type: json['type'],
      read: json['read'] ?? false,
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
    );
  }
}
