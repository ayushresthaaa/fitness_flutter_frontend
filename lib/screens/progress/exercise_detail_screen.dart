import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/progress/progress_provider.dart';
import '../../../widgets/common.dart';
import 'widgets/exercise_chart.dart';
import 'widgets/pr_stats.dart';
import 'widgets/set_records_table.dart';
import 'widgets/exercise_history_list.dart';
import 'how_to_tab.dart';
import '../../../models/exercise/exercise_model.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final String exerciseId;
  final String exerciseName;
  final Exercise? exercise;
  const ExerciseDetailScreen({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
    this.exercise,
  });

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final tabCount = widget.exercise != null ? 3 : 2;
    _tabController = TabController(length: tabCount, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressProvider>().fetchExerciseProgress(widget.exerciseId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressProvider>(
      builder: (context, provider, _) {
        final data = provider.exerciseProgress;

        return Scaffold(
          backgroundColor: kBackground,
          appBar: AppTopBar(title: widget.exerciseName),
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  color: kWhite,
                  child: Column(
                    children: [
                      // Primary muscle
                      if (data != null && data.primaryMuscles.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: kPrimaryLight,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  data.primaryMuscles.first,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: kPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                data.category,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: kTextGrey,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Tab bar
                      TabBar(
                        controller: _tabController,
                        labelColor: kPrimary,
                        unselectedLabelColor: kTextGrey,
                        indicatorColor: kPrimary,
                        indicatorSize: TabBarIndicatorSize.label,
                        labelStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        tabs: [
                          const Tab(text: 'Summary'),
                          const Tab(text: 'History'),
                          if (widget.exercise != null)
                            const Tab(text: 'How To'),
                        ],
                      ),
                    ],
                  ),
                ),

                // Tab content
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : data == null
                      ? const EmptyState(
                          icon: Icons.bar_chart_rounded,
                          title: 'No data yet',
                          subtitle: 'Complete a workout with this exercise',
                        )
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            // Summary tab
                            _SummaryTab(provider: provider, data: data),

                            // History tab
                            _HistoryTab(provider: provider, data: data),
                            if (widget.exercise != null)
                              HowToTab(exercise: widget.exercise!),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// summary tab content
class _SummaryTab extends StatelessWidget {
  final ProgressProvider provider;
  final dynamic data;

  const _SummaryTab({required this.provider, required this.data});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Chart
        ExerciseChart(
          weightData: data.isCardio
              ? provider.durationChartData
              : provider.weightChartData,
          oneRMData: data.isCardio
              ? provider.distanceChartData
              : provider.oneRMChartData,
          volumeData: provider.volumeChartData,
          isCardio: data.isCardio,
        ),

        const SizedBox(height: 12),

        // PR stats
        PRStatsCard(
          heaviestWeight: provider.heaviestWeight,
          best1RM: data.isCardio ? null : provider.best1RM,
          bestSetVolume: data.isCardio ? null : provider.bestSetVolume,
          bestSessionVolume: provider.bestSessionVolume,
        ),

        const SizedBox(height: 12),

        // Set records (strength only)
        if (!data.isCardio) SetRecordsTable(setRecords: provider.setRecords),

        const SizedBox(height: 16),
      ],
    );
  }
}

// history tab
class _HistoryTab extends StatelessWidget {
  final ProgressProvider provider;
  final dynamic data;

  const _HistoryTab({required this.provider, required this.data});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ExerciseHistoryList(history: data.history, isCardio: data.isCardio),
        const SizedBox(height: 16),
      ],
    );
  }
}
