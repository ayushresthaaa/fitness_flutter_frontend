import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification/notification_provider.dart';
import '../../models/notification/notification_model.dart';
import '../../widgets/common.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch notifications when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  // Get icon for each notification type
  IconData _getIcon(String type) {
    if (type == 'routine_reviewed') return Icons.check_circle_outline;
    if (type == 'routine_updated') return Icons.fitness_center;
    if (type == 'routine_review') return Icons.rate_review_outlined;
    return Icons.notifications_outlined;
  }

  // Get icon color for each notification type
  Color _getIconColor(String type) {
    if (type == 'routine_reviewed') return const Color(0xFF43A047);
    if (type == 'routine_updated') return const Color(0xFF1E88E5);
    if (type == 'routine_review') return const Color(0xFFF57C00);
    return const Color(0xFF9E9E9E);
  }

  // Get icon background color for each notification type
  Color _getIconBgColor(String type) {
    if (type == 'routine_reviewed') return const Color(0xFFE8F5E9);
    if (type == 'routine_updated') return const Color(0xFFE3F2FD);
    if (type == 'routine_review') return const Color(0xFFFFF3E0);
    return const Color(0xFFF5F5F5);
  }

  // Format date to readable string
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final notifications = provider.notifications;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF212121),
          ),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Color(0xFF212121)),
        ),
        // Mark all as read button — only shown if there are unread notifications
        actions: [
          if (provider.unreadCount > 0)
            TextButton(
              onPressed: () {
                context.read<NotificationProvider>().markAllAsRead();
              },
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1E88E5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),

      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_outlined,
              title: 'No notifications yet',
              subtitle: 'You\'ll see updates from your trainer here',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _NotificationCard(
                  notification: notification,
                  onTap: () {
                    // Mark as read when tapped
                    if (!notification.read) {
                      context.read<NotificationProvider>().markAsRead(
                        notification.id,
                      );
                    }
                  },
                  onDelete: () {
                    context.read<NotificationProvider>().deleteNotification(
                      notification.id,
                    );
                  },
                  getIcon: _getIcon,
                  getIconColor: _getIconColor,
                  getIconBgColor: _getIconBgColor,
                  formatDate: _formatDate,
                );
              },
            ),
    );
  }
}

// Private card widget for each notification
class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final IconData Function(String) getIcon;
  final Color Function(String) getIconColor;
  final Color Function(String) getIconBgColor;
  final String Function(DateTime) formatDate;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDelete,
    required this.getIcon,
    required this.getIconColor,
    required this.getIconBgColor,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          // Unread notifications have a slightly different background
          color: notification.read ? Colors.white : const Color(0xFFF0F7FF),
          borderRadius: BorderRadius.circular(14),
          border: notification.read
              ? null
              : Border.all(color: const Color(0xFFBBDEFB), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: getIconBgColor(notification.type),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                getIcon(notification.type),
                size: 20,
                color: getIconColor(notification.type),
              ),
            ),

            const SizedBox(width: 12),

            // Title + body + date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row with unread dot
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: notification.read
                                ? FontWeight.w500
                                : FontWeight.w700,
                            color: const Color(0xFF212121),
                          ),
                        ),
                      ),
                      // Blue dot for unread
                      if (!notification.read)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1E88E5),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 3),

                  // Body
                  Text(
                    notification.body,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF757575),
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Date + delete button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatDate(notification.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                      GestureDetector(
                        onTap: onDelete,
                        child: const Text(
                          'Remove',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
