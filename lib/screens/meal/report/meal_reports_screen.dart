// lib/screens/meal/meal_reports_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../widgets/common.dart';
import '../../../providers/meal/meal_log_provider.dart';
import '../../../models/meal/meal_log_model.dart';
import '../meal_planner_screen.dart';

class MealReportsScreen extends StatefulWidget {
  const MealReportsScreen({super.key});

  @override
  State<MealReportsScreen> createState() => _MealReportsScreenState();
}

class _MealReportsScreenState extends State<MealReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MealLogProvider>().loadHistory();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _openLog(MealHistoryItem item) async {
    await context.read<MealLogProvider>().selectDate(item.date);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MealPlannerScreen()),
    );
  }

  Future<void> _sendForReview(MealHistoryItem item) async {
    final dateStr =
        '${item.date.year}-${item.date.month.toString().padLeft(2, '0')}-${item.date.day.toString().padLeft(2, '0')}';
    final success = await context.read<MealLogProvider>().sendLogForReview(
      dateStr,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Log sent for review' : 'Failed to send log'),
        backgroundColor: success ? kGreen : kRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MealLogProvider>();

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppTopBar(title: 'Meal Reports'),
      body: Column(
        children: [
          Container(
            color: kWhite,
            child: TabBar(
              controller: _tabController,
              labelColor: kPrimary,
              unselectedLabelColor: kTextGrey,
              indicatorColor: kPrimary,
              indicatorWeight: 2,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                _buildTab('Not Sent', provider.notSentLogs.length, kTextGrey),
                _buildTab(
                  'Pending',
                  provider.pendingLogs.length,
                  const Color(0xFFFB8C00),
                ),
                _buildTab('Reviewed', provider.reviewedLogs.length, kGreen),
              ],
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: kPrimary),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildList(
                        provider.notSentLogs,
                        'No unsent logs',
                        'All your logs have been sent',
                        showSend: true,
                      ),
                      _buildList(
                        provider.pendingLogs,
                        'No pending reviews',
                        'Send a log to your trainer to get feedback',
                      ),
                      _buildList(
                        provider.reviewedLogs,
                        'No reviewed logs yet',
                        'Your trainer has not reviewed any logs yet',
                        showNotes: true,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Tab _buildTab(String label, int count, Color countColor) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: countColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: countColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildList(
    List<MealHistoryItem> logs,
    String emptyTitle,
    String emptySubtitle, {
    bool showSend = false,
    bool showNotes = false,
  }) {
    if (logs.isEmpty) {
      return EmptyState(
        icon: Icons.receipt_long_outlined,
        title: emptyTitle,
        subtitle: emptySubtitle,
      );
    }

    return RefreshIndicator(
      color: kPrimary,
      onRefresh: () => context.read<MealLogProvider>().loadHistory(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: logs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, index) {
          final item = logs[index];
          return _LogCard(
            item: item,
            formatDate: _formatDate,
            showSend: showSend,
            showNotes: showNotes,
            onTapCard: () => _openLog(item),
            onSend: showSend ? () => _sendForReview(item) : null,
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────
// LOG CARD
// ─────────────────────────────────────────

class _LogCard extends StatelessWidget {
  final MealHistoryItem item;
  final String Function(DateTime) formatDate;
  final bool showSend;
  final bool showNotes;
  final VoidCallback onTapCard;
  final VoidCallback? onSend;

  const _LogCard({
    required this.item,
    required this.formatDate,
    required this.onTapCard,
    this.showSend = false,
    this.showNotes = false,
    this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final calorieProgress = item.goals.calories > 0
        ? (item.totals.calories / item.goals.calories).clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      onTap: onTapCard,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date + goal hit
            Row(
              children: [
                Text(
                  formatDate(item.date),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: kTextDark,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: item.goalHit
                        ? kGreen.withOpacity(0.1)
                        : kRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.goalHit ? 'Goal Hit' : 'Goal Missed',
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

            // Calories
            Row(
              children: [
                Text(
                  '${item.totals.calories.toInt()} kcal',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: kTextDark,
                  ),
                ),
                const Text(
                  ' / ',
                  style: TextStyle(fontSize: 13, color: kTextGrey),
                ),
                Text(
                  '${item.goals.calories.toInt()} kcal goal',
                  style: const TextStyle(fontSize: 13, color: kTextGrey),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right, size: 16, color: kTextHint),
              ],
            ),

            const SizedBox(height: 8),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: calorieProgress,
                backgroundColor: kDivider,
                color: item.isOverCalorieGoal ? kRed : kPrimary,
                minHeight: 5,
              ),
            ),

            const SizedBox(height: 10),

            // Macros
            Row(
              children: [
                _MacroText(
                  label: 'Protein',
                  value: item.totals.protein.toInt(),
                  color: kPrimary,
                ),
                const SizedBox(width: 12),
                _MacroText(
                  label: 'Carbs',
                  value: item.totals.carbs.toInt(),
                  color: const Color(0xFFFB8C00),
                ),
                const SizedBox(width: 12),
                _MacroText(
                  label: 'Fat',
                  value: item.totals.fat.toInt(),
                  color: const Color(0xFF8E24AA),
                ),
              ],
            ),

            // Trainer notes — reviewed tab
            if (showNotes && item.trainerNotes != null) ...[
              const SizedBox(height: 12),
              const Divider(color: kDivider, height: 1),
              const SizedBox(height: 10),
              const SectionLabel('Trainer Notes'),
              const SizedBox(height: 6),
              Text(
                item.trainerNotes!,
                style: const TextStyle(
                  fontSize: 13,
                  color: kTextDark,
                  height: 1.5,
                ),
              ),
            ],

            // Pending status
            if (item.isPending) ...[
              const SizedBox(height: 10),
              const Divider(color: kDivider, height: 1),
              const SizedBox(height: 8),
              Row(
                children: const [
                  Icon(Icons.schedule_outlined, size: 14, color: kTextGrey),
                  SizedBox(width: 6),
                  Text(
                    'Awaiting trainer review',
                    style: TextStyle(fontSize: 12, color: kTextGrey),
                  ),
                ],
              ),
            ],

            // Send button — stops tap from bubbling to card
            if (showSend && onSend != null) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: onSend,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: kPrimaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'Send to Trainer',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// MACRO TEXT
// ─────────────────────────────────────────

class _MacroText extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _MacroText({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          '$label ${value}g',
          style: const TextStyle(fontSize: 12, color: kTextGrey),
        ),
      ],
    );
  }
}
