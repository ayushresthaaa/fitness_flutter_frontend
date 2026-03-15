import 'package:dio/dio.dart';
import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import '../../models/notification/notification_model.dart';

class NotificationService {
  final Dio _dio = ApiClient().dio;

  // GET /api/notifications
  // Returns list of notifications for the logged in user
  Future<List<AppNotification>> getNotifications() async {
    final response = await _dio.get(
      ApiEndpoints.notifications,
      queryParameters: {'limit': 50, 'page': 1},
    );

    final data = response.data['data'];
    final List<dynamic> list = data['notifications'] as List;

    return list.map((item) => AppNotification.fromJson(item)).toList();
  }

  // GET /api/notifications/unread-count
  // Returns the number of unread notifications
  Future<int> getUnreadCount() async {
    final response = await _dio.get(ApiEndpoints.notificationsUnreadCount);
    return response.data['data']['unreadCount'] as int;
  }

  // PATCH /api/notifications/:id/read
  // Marks a single notification as read
  Future<void> markAsRead(int notificationId) async {
    await _dio.patch(
      ApiEndpoints.notificationMarkRead(notificationId.toString()),
    );
  }

  // PATCH /api/notifications/read-all
  // Marks all notifications as read
  Future<void> markAllAsRead() async {
    await _dio.patch(ApiEndpoints.notificationsMarkAllRead);
  }

  // DELETE /api/notifications/:id
  // Deletes a single notification
  Future<void> deleteNotification(int notificationId) async {
    await _dio.delete(
      ApiEndpoints.notificationDelete(notificationId.toString()),
    );
  }
}
