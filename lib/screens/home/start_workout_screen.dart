import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/exercise/workout_provider.dart';
import '../../providers/achievement/achievement_provider.dart';
import '../../models/achievement/achievement_model.dart';
import '../workout/active_workout_screen.dart';
import '../workout/workout_history_screen.dart';
import '../routine/routines_screen.dart';

class StartWorkoutScreen extends StatefulWidget {
  const StartWorkoutScreen({super.key});

  @override
  State<StartWorkoutScreen> createState() => _StartWorkoutScreenState();
}

class _StartWorkoutScreenState extends State<StartWorkoutScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AchievementProvider>().fetchAchievements();
    });
  }

  Future<void> _quickLog() async {
    await context.read<WorkoutProvider>().startWorkout();
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ActiveWorkoutScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final achievementProvider = context.watch<AchievementProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF212121)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Start Workout',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF212121),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionLabel('QUICK START'),
          const SizedBox(height: 8),

          // Quick Log — blue
          _BlueCard(icon: Icons.bolt, title: 'Quick Log', onTap: _quickLog),
          const SizedBox(height: 8),

          // From Routine
          _SimpleCard(
            icon: Icons.repeat,
            title: 'From Routine',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RoutinesScreen()),
            ),
          ),
          const SizedBox(height: 8),

          // Generate with AI — disabled
          const Opacity(
            opacity: 0.5,
            child: _SimpleCard(
              icon: Icons.auto_awesome,
              title: 'Generate with AI',
              onTap: null,
            ),
          ),

          const SizedBox(height: 20),

          const _SectionLabel('HISTORY'),
          const SizedBox(height: 8),

          _SimpleCard(
            icon: Icons.history,
            title: 'Workout History',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WorkoutHistoryScreen()),
            ),
          ),

          const SizedBox(height: 20),

          const _SectionLabel('ACHIEVEMENTS'),
          const SizedBox(height: 8),

          if (achievementProvider.isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF1E88E5)),
            )
          else ...[
            ...achievementProvider.earned.map(
              (a) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _AchievementCard(achievement: a),
              ),
            ),
            ...achievementProvider.locked.map(
              (a) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _AchievementCard(achievement: a),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF9E9E9E),
        letterSpacing: 0.5,
      ),
    );
  }
}

class _BlueCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _BlueCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E88E5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white70, size: 20),
          ],
        ),
      ),
    );
  }
}

class _SimpleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _SimpleCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF1E88E5), size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF212121),
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFBDBDBD), size: 20),
          ],
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  const _AchievementCard({required this.achievement});

  IconData _iconForType(String type) {
    switch (type) {
      case 'first_workout':
        return Icons.star;
      case 'workout_count':
        return Icons.fitness_center;
      case 'streak':
        return Icons.local_fire_department;
      case 'exercises_logged':
        return Icons.list_alt;
      case 'personal_record':
        return Icons.emoji_events;
      default:
        return Icons.military_tech;
    }
  }

  @override
  Widget build(BuildContext context) {
    final earned = achievement.earned;

    return Opacity(
      opacity: earned ? 1.0 : 0.4,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: earned
                    ? const Color(0xFFE3F2FD)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _iconForType(achievement.type),
                size: 20,
                color: earned
                    ? const Color(0xFF1E88E5)
                    : const Color(0xFF9E9E9E),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    achievement.description,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              earned ? 'Done' : 'Locked',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: earned
                    ? const Color(0xFF1E88E5)
                    : const Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
