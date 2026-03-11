import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/achievement/achievement_provider.dart';
import '../../widgets/common.dart';
import 'widgets/achievement_card.dart';

// Achievement screen
class AchievementScreen extends StatefulWidget {
  const AchievementScreen({super.key});

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AchievementProvider>().fetchAchievements();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AchievementProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: kBackground,
          appBar: AppTopBar(title: 'Achievements'),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator(color: kPrimary))
              : RefreshIndicator(
                  onRefresh: () => provider.fetchAchievements(),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Summary card
                      _SummaryCard(
                        earned: provider.earnedCount,
                        total: provider.total,
                      ),
                      const SizedBox(height: 20),

                      // Earned section
                      if (provider.earned.isNotEmpty) ...[
                        const SectionLabel('EARNED'),
                        const SizedBox(height: 8),
                        for (int i = 0; i < provider.earned.length; i++) ...[
                          AchievementCard(achievement: provider.earned[i]),
                          if (i < provider.earned.length - 1)
                            const SizedBox(height: 8),
                        ],
                        const SizedBox(height: 20),
                      ],

                      // Locked section
                      if (provider.locked.isNotEmpty) ...[
                        const SectionLabel('LOCKED'),
                        const SizedBox(height: 8),
                        for (int i = 0; i < provider.locked.length; i++) ...[
                          AchievementCard(achievement: provider.locked[i]),
                          if (i < provider.locked.length - 1)
                            const SizedBox(height: 8),
                        ],
                      ],

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

// Summary card at the top showing progress bar and count
class _SummaryCard extends StatelessWidget {
  final int earned;
  final int total;

  const _SummaryCard({required this.earned, required this.total});

  @override
  Widget build(BuildContext context) {
    final double progress = total == 0 ? 0 : earned / total;
    final int percentage = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_rounded, size: 32, color: kPrimary),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$earned / $total Unlocked',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: kTextDark,
                    ),
                  ),
                  Text(
                    '$percentage% complete',
                    style: const TextStyle(fontSize: 12, color: kTextGrey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: kBackground,
              color: kPrimary,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
