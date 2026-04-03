// lib/screens/meal/meal_insights_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../widgets/common.dart';
import '../../../providers/meal/meal_insights_provider.dart';
import '../../../providers/meal/meal_log_provider.dart';
import '../../../models/meal/meal_insights_model.dart';
import 'widgets/nutrition_score_card.dart';
import 'widgets/streak_card.dart';
import 'widgets/macro_hit_rate.dart';
import 'widgets/weekly_chart.dart';

class MealInsightsScreen extends StatefulWidget {
  const MealInsightsScreen({super.key});

  @override
  State<MealInsightsScreen> createState() => _MealInsightsScreenState();
}

class _MealInsightsScreenState extends State<MealInsightsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // load insights + history in parallel
      context.read<MealInsightsProvider>().loadInsights();
      context.read<MealInsightsProvider>().loadHistory();

      // today log may already be loaded from meal planner — only load if missing
      final logProvider = context.read<MealLogProvider>();
      if (logProvider.todayLog == null) {
        logProvider.loadTodayLog();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Insights',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: kTextDark,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: kPrimary,
          unselectedLabelColor: kTextGrey,
          indicatorColor: kPrimary,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          tabs: const [
            Tab(text: 'Day'),
            Tab(text: 'Week'),
            Tab(text: 'Month'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _DayTab(),
          _WeekTab(),
          _MonthTab(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// DAY TAB — today's macro breakdown
// ─────────────────────────────────────────

class _DayTab extends StatelessWidget {
  const _DayTab();

  @override
  Widget build(BuildContext context) {
    final logProvider = context.watch<MealLogProvider>();
    final log = logProvider.todayLog;

    if (logProvider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: kPrimary));
    }

    if (log == null) {
      return const EmptyState(
        icon: Icons.restaurant_menu_outlined,
        title: 'No log for today',
        subtitle: 'Start logging meals to see your daily breakdown',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // calories summary card
        _DaySummaryCard(
          label: 'Calories',
          consumed: log.totals.calories.toInt(),
          goal: log.goals.calories.toInt(),
          unit: 'kcal',
          progress: log.calorieProgress,
          color: log.isOverCalorieGoal ? kRed : kPrimary,
        ),

        const SizedBox(height: 12),

        // macros breakdown
        _DaySummaryCard(
          label: 'Protein',
          consumed: log.totals.protein.toInt(),
          goal: log.goals.protein.toInt(),
          unit: 'g',
          progress: log.proteinProgress,
          color: kPrimary,
        ),

        const SizedBox(height: 12),

        _DaySummaryCard(
          label: 'Carbs',
          consumed: log.totals.carbs.toInt(),
          goal: log.goals.carbs.toInt(),
          unit: 'g',
          progress: log.carbsProgress,
          color: const Color(0xFFFB8C00),
        ),

        const SizedBox(height: 12),

        _DaySummaryCard(
          label: 'Fat',
          consumed: log.totals.fat.toInt(),
          goal: log.goals.fat.toInt(),
          unit: 'g',
          progress: log.fatProgress,
          color: const Color(0xFF8E24AA),
        ),

        const SizedBox(height: 12),

        // water intake
        _DaySummaryCard(
          label: 'Water',
          consumed: log.hydration.consumed,
          goal: log.hydration.goal,
          unit: 'ml',
          progress: log.hydration.progress,
          color: kPrimary,
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}

// single macro card for the Day tab
class _DaySummaryCard extends StatelessWidget {
  final String label;
  final int consumed;
  final int goal;
  final String unit;
  final double progress;
  final Color color;

  const _DaySummaryCard({
    required this.label,
    required this.consumed,
    required this.goal,
    required this.unit,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = goal - consumed;
    final isOver = consumed > goal;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // label + percentage
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kTextDark,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: kDivider,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),

          const SizedBox(height: 8),

          // consumed / remaining / goal row
          Row(
            children: [
              Text(
                '$consumed $unit consumed',
                style: const TextStyle(fontSize: 12, color: kTextGrey),
              ),
              const Spacer(),
              Text(
                isOver
                    ? '${remaining.abs()} $unit over'
                    : '$remaining $unit remaining',
                style: TextStyle(
                  fontSize: 12,
                  color: isOver ? kRed : kTextGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// WEEK TAB — score, streak, chart, hit rates, averages
// ─────────────────────────────────────────

class _WeekTab extends StatelessWidget {
  const _WeekTab();

  @override
  Widget build(BuildContext context) {
    final insightsProvider = context.watch<MealInsightsProvider>();
    final insights = insightsProvider.insights;

    if (insightsProvider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: kPrimary));
    }

    if (insights == null) {
      return const EmptyState(
        icon: Icons.bar_chart_outlined,
        title: 'No data yet',
        subtitle: 'Log meals for a few days to see your weekly insights',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        NutritionScoreCard(insights: insights),
        const SizedBox(height: 12),
        StreakCard(streak: insights.loggingStreak),
        const SizedBox(height: 12),
        WeeklyChart(days: insights.weeklyCalorieChart),
        const SizedBox(height: 12),
        MacroHitRateCard(goalHitRates: insights.goalHitRates),
        const SizedBox(height: 12),
        _WeeklyAveragesCard(averages: insights.weeklyAverages),
        const SizedBox(height: 16),
      ],
    );
  }
}

// weekly averages card — shown at bottom of week tab
class _WeeklyAveragesCard extends StatelessWidget {
  final WeeklyAverages averages;

  const _WeeklyAveragesCard({required this.averages});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Weekly Averages'),
          const SizedBox(height: 14),
          Row(
            children: [
              _AvgCell(
                label: 'Calories',
                value: '${averages.calories}',
                unit: 'kcal',
                color: kTextDark,
              ),
              _AvgCell(
                label: 'Protein',
                value: '${averages.protein}',
                unit: 'g',
                color: kPrimary,
              ),
              _AvgCell(
                label: 'Carbs',
                value: '${averages.carbs}',
                unit: 'g',
                color: const Color(0xFFFB8C00),
              ),
              _AvgCell(
                label: 'Fat',
                value: '${averages.fat}',
                unit: 'g',
                color: const Color(0xFF8E24AA),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AvgCell extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _AvgCell({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: kTextGrey),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            unit,
            style: const TextStyle(fontSize: 10, color: kTextGrey),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// MONTH TAB — 30 day history list
// ─────────────────────────────────────────

class _MonthTab extends StatelessWidget {
  const _MonthTab();

  @override
  Widget build(BuildContext context) {
    final insightsProvider = context.watch<MealInsightsProvider>();
    final history = insightsProvider.history;

    if (insightsProvider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: kPrimary));
    }

    if (history.isEmpty) {
      return const EmptyState(
        icon: Icons.calendar_month_outlined,
        title: 'No history yet',
        subtitle: 'Your last 30 days of meal logs will appear here',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return _HistoryTile(item: history[index]);
      },
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final MealHistoryItem item;

  const _HistoryTile({required this.item});

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // date
              Text(
                _formatDate(item.date),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kTextDark,
                ),
              ),
              const Spacer(),
              // goal hit badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: item.goalHit ? kGreen.withOpacity(0.1) : kRedLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.goalHit ? 'On Track' : 'Off Track',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: item.goalHit ? kGreen : kRed,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // calorie progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: item.calorieProgress,
              minHeight: 5,
              backgroundColor: kDivider,
              valueColor: AlwaysStoppedAnimation<Color>(
                item.goalHit ? kPrimary : kRed,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // calories + macros row
          Row(
            children: [
              Text(
                '${item.caloriesConsumed.toInt()} / ${item.calorieGoal.toInt()} kcal',
                style: const TextStyle(fontSize: 12, color: kTextGrey),
              ),
              const Spacer(),
              Text(
                'P ${item.proteinConsumed.toInt()}g · C ${item.carbsConsumed.toInt()}g · F ${item.fatConsumed.toInt()}g',
                style: const TextStyle(fontSize: 11, color: kTextHint),
              ),
            ],
          ),
        ],
      ),
    );
  }
}