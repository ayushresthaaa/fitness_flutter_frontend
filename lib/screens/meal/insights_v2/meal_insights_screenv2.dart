import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../widgets/common.dart';
import '../../../../providers/meal/meal_insights_provider.dart';
import '../../../../providers/meal/meal_log_provider.dart';
import '../../../../models/meal/meal_insights_model.dart';
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
      context.read<MealInsightsProvider>().loadInsights();
      context.read<MealInsightsProvider>().loadHistory();
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
          indicatorWeight: 2,
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
        children: const [_DayTab(), _WeekTab(), _MonthTab()],
      ),
    );
  }
}

// day tab shows today's macro and water breakdown
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
        _MacroCard(
          label: 'Calories',
          consumed: log.totals.calories.toInt(),
          goal: log.goals.calories.toInt(),
          unit: 'kcal',
          progress: log.calorieProgress,
          color: log.isOverCalorieGoal ? kRed : kPrimary,
          icon: Icons.local_fire_department_outlined,
        ),
        const SizedBox(height: 12),
        _MacroCard(
          label: 'Protein',
          consumed: log.totals.protein.toInt(),
          goal: log.goals.protein.toInt(),
          unit: 'g',
          progress: log.proteinProgress,
          color: kPrimary,
          icon: Icons.fitness_center_outlined,
        ),
        const SizedBox(height: 12),
        _MacroCard(
          label: 'Carbs',
          consumed: log.totals.carbs.toInt(),
          goal: log.goals.carbs.toInt(),
          unit: 'g',
          progress: log.carbsProgress,
          color: const Color(0xFFFB8C00),
          icon: Icons.grain_outlined,
        ),
        const SizedBox(height: 12),
        _MacroCard(
          label: 'Fat',
          consumed: log.totals.fat.toInt(),
          goal: log.goals.fat.toInt(),
          unit: 'g',
          progress: log.fatProgress,
          color: const Color(0xFF8E24AA),
          icon: Icons.opacity_outlined,
        ),
        const SizedBox(height: 12),
        _MacroCard(
          label: 'Water',
          consumed: log.hydration.consumed,
          goal: log.hydration.goal,
          unit: 'ml',
          progress: log.hydration.progress,
          color: kPrimary,
          icon: Icons.water_drop_outlined,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String label;
  final int consumed;
  final int goal;
  final String unit;
  final double progress;
  final Color color;
  final IconData icon;

  const _MacroCard({
    required this.label,
    required this.consumed,
    required this.goal,
    required this.unit,
    required this.progress,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = goal - consumed;
    final isOver = consumed > goal;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
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
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: kDivider,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 8),
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
                    : '$remaining $unit left',
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

// week tab shows score, streak, chart, hit rates, averages
class _WeekTab extends StatelessWidget {
  const _WeekTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MealInsightsProvider>();
    final insights = provider.insights;

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: kPrimary));
    }

    if (insights == null) {
      return const EmptyState(
        icon: Icons.bar_chart_outlined,
        title: 'No data yet',
        subtitle: 'Log meals for a few days to see weekly insights',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: NutritionScoreCard(insights: insights)),
            const SizedBox(width: 12),
            Expanded(child: StreakCard(streak: insights.loggingStreak)),
          ],
        ),
        const SizedBox(height: 12),
        WeeklyChart(days: insights.weeklyCalorieChart),
        const SizedBox(height: 12),
        MacroHitRateCard(goalHitRates: insights.goalHitRates),
        const SizedBox(height: 12),
        _WeeklyAveragesCard(averages: insights.weeklyAverages),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _WeeklyAveragesCard extends StatelessWidget {
  final WeeklyAverages averages;

  const _WeeklyAveragesCard({required this.averages});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
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
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(unit, style: const TextStyle(fontSize: 10, color: kTextGrey)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: kTextGrey)),
        ],
      ),
    );
  }
}

// month tab shows 30 day history list
class _MonthTab extends StatelessWidget {
  const _MonthTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MealInsightsProvider>();
    final history = provider.history;

    if (provider.isLoading) {
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
      itemBuilder: (_, index) => _HistoryTile(item: history[index]),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final InsightsHistoryItem item;

  const _HistoryTile({required this.item});

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
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
              Text(
                _formatDate(item.date),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kTextDark,
                ),
              ),
              const Spacer(),
              Text(
                item.goalHit ? 'On Track' : 'Off Track',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: item.goalHit ? kPrimary : kTextGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
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
          Row(
            children: [
              Text(
                '${item.caloriesConsumed.toInt()} / ${item.calorieGoal.toInt()} kcal',
                style: const TextStyle(fontSize: 12, color: kTextGrey),
              ),
              const Spacer(),
              Text(
                'P ${item.proteinConsumed.toInt()}g  C ${item.carbsConsumed.toInt()}g  F ${item.fatConsumed.toInt()}g',
                style: const TextStyle(fontSize: 11, color: kTextHint),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
