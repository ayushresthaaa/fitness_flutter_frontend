import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/user/user.provider.dart';
import '../../widgets/common.dart';
import '../../screens/notification/notification_screen.dart';
import '../../screens/ecommerce/orders_screen.dart';
import 'edit_profile_screen.dart';
import 'edit_fitness_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final isOAuth = user?.isOAuth ?? false;
    final isPro = user?.isPro ?? false;

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppTopBar(title: 'Profile'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),

            // Avatar + name + email centered
            Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: kPrimaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      (user?.name ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: kPrimary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  user?.name ?? 'User',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: kTextDark,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  user?.email ?? '',
                  style: const TextStyle(fontSize: 13, color: kTextGrey),
                ),

                const SizedBox(height: 8),

                // Plan badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isPro ? kPrimary : kBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isPro ? '⭐ Pro Plan' : 'Free Plan',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isPro ? kWhite : kTextGrey,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Action rows
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _ActionRow(
                    icon: Icons.person_outline,
                    label: 'Edit Profile',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    ),
                  ),
                  _ActionRow(
                    icon: Icons.fitness_center_outlined,
                    label: 'Fitness Profile',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditFitnessScreen(),
                      ),
                    ),
                  ),
                  if (!isOAuth)
                    _ActionRow(
                      icon: Icons.lock_outline,
                      label: 'Change Password',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChangePasswordScreen(),
                        ),
                      ),
                    ),
                  _ActionRow(
                    icon: Icons.shopping_bag_outlined,
                    label: 'My Orders',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OrdersScreen()),
                    ),
                  ),
                  _ActionRow(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationScreen(),
                      ),
                    ),
                  ),
                  _ActionRow(
                    icon: Icons.alarm_outlined,
                    label: 'Set Reminder',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reminders coming soon')),
                      );
                    },
                  ),
                  _ActionRow(
                    icon: Icons.logout,
                    label: 'Log Out',
                    isLast: true,
                    isDestructive: true,
                    onTap: () async {
                      await context.read<AuthProvider>().logout();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Pro upgrade banner — only for free users
            if (!isPro)
              GestureDetector(
                onTap: () {
                  // TODO: navigate to pro upgrade screen
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.star_rounded, color: Colors.white, size: 26),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Upgrade to Pro',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'AI routines + trainer — Rs. 500/month',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLast;
  final bool isDestructive;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLast = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red : kTextDark;
    final iconColor = isDestructive ? Colors.red : kTextGrey;

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            color: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? Colors.red.withOpacity(0.08)
                        : kBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(fontSize: 14, color: color),
                  ),
                ),
                if (!isDestructive)
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: kTextHint,
                  ),
              ],
            ),
          ),
        ),
        if (!isLast) const Divider(color: kDivider, height: 1, indent: 66),
      ],
    );
  }
}
