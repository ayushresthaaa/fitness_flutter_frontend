import 'package:fitness_app/screens/history/history_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/progress/stats_provider.dart';
import '../../../widgets/common.dart';
import 'widgets/stats_card.dart';
import 'widgets/frequency_chart.dart';
import 'widgets/muscle_distribution.dart';
import 'widgets/personal_best_list.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("fetching stats...");
      context.read<StatsProvider>().fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StatsProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: kBackground,
          appBar: AppTopBar(title: 'Progress'),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () => provider.fetchAll(),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      PrimaryButton(
                        text: "View History",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HistoryScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      if (provider.overallStats != null)
                        StatsCards(
                          stats: provider.overallStats!,
                          currentStreak: provider.currentStreak,
                        ),

                      const SizedBox(height: 12),

                      // Frequency chart
                      FrequencyChart(
                        weeklyData: provider.weeklyStats,
                        monthlyData: provider.monthlyStats,
                      ),

                      const SizedBox(height: 12),

                      // Muscle distribution
                      MuscleDistributionWidget(
                        muscles: provider.muscleDistribution,
                      ),

                      const SizedBox(height: 12),

                      // Personal bests
                      PersonalBestsList(personalBests: provider.personalBests),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
