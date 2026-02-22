import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/exercise/workout_provider.dart';
import '../../providers/achievement/achievement_provider.dart';
import '../../models/achievement/achievement_model.dart';
import '../workout/active_workout_screen.dart';
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
    final provider = context.read<WorkoutProvider>();
    await provider.startWorkout();
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
          const Text(
            'QUICK START',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF9E9E9E),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),

          // Quick Log — blue card
          GestureDetector(
            onTap: _quickLog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bolt, color: Colors.white, size: 22),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Log',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Start a blank workout',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.white70,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // From Routine
          _OptionCard(
            icon: Icons.repeat,
            title: 'From Routine',
            subtitle: 'Pick one of your routines',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RoutinesScreen()),
            ),
          ),
          const SizedBox(height: 8),

          // Generate with AI
          _OptionCard(
            icon: Icons.auto_awesome,
            title: 'Generate with AI',
            subtitle: 'Let AI build a routine for you',
            onTap: null,
            disabled: true,
          ),

          const SizedBox(height: 20),

          const Text(
            'ACHIEVEMENTS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF9E9E9E),
              letterSpacing: 0.5,
            ),
          ),
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

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool disabled;

  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: GestureDetector(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFFBDBDBD),
                size: 20,
              ),
            ],
          ),
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
