import '../../models/notification/notification_model.dart';
import '../../services/notification/notification_service.dart';
import '../base/base_provider.dart';

class NotificationProvider extends BaseProvider {
  final NotificationService _service = NotificationService();

  // List of all notifications
  List<AppNotification> _notifications = [];

  // Number of unread notifications — used for bell badge
  int _unreadCount = 0;

  // Getters
  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  // Fetch all notifications from backend
  Future<void> fetchNotifications() async {
    final result = await execute(() => _service.getNotifications());
    if (result != null) {
      _notifications = result;
      // Calculate unread count from the list
      _unreadCount = _notifications.where((n) => !n.read).length;
      notifyListeners();
    }
  }

  // Fetch only the unread count — used for bell badge on home screen
  Future<void> fetchUnreadCount() async {
    final result = await execute(() => _service.getUnreadCount());
    if (result != null) {
      _unreadCount = result;
      notifyListeners();
    }
  }

  // Mark a single notification as read
  Future<void> markAsRead(int notificationId) async {
    await execute(() => _service.markAsRead(notificationId));

    if (!hasError) {
      // Update locally without refetching
      _notifications = _notifications.map((n) {
        if (n.id == notificationId) {
          return AppNotification(
            id: n.id,
            userId: n.userId,
            title: n.title,
            body: n.body,
            type: n.type,
            read: true,
            createdAt: n.createdAt,
          );
        }
        return n;
      }).toList();

      // Recalculate unread count
      _unreadCount = _notifications.where((n) => !n.read).length;
      notifyListeners();
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    await execute(() => _service.markAllAsRead());

    if (!hasError) {
      // Update all locally
      _notifications = _notifications.map((n) {
        return AppNotification(
          id: n.id,
          userId: n.userId,
          title: n.title,
          body: n.body,
          type: n.type,
          read: true,
          createdAt: n.createdAt,
        );
      }).toList();

      _unreadCount = 0;
      notifyListeners();
    }
  }

  // Delete a single notification
  Future<void> deleteNotification(int notificationId) async {
    await execute(() => _service.deleteNotification(notificationId));

    if (!hasError) {
      // Remove from local list
      _notifications = _notifications
          .where((n) => n.id != notificationId)
          .toList();

      // Recalculate unread count
      _unreadCount = _notifications.where((n) => !n.read).length;
      notifyListeners();
    }
  }

  // Add a new notification received via socket
  // Called from socket listener when notification:new event arrives
  void addSocketNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    _unreadCount = _notifications.where((n) => !n.read).length;
    notifyListeners();
  }

  void reset() {
    _notifications = [];
    _unreadCount = 0;
    clearError();
    notifyListeners();
  }
}
