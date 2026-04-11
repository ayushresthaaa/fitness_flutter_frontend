// lib/screens/meal/meal_planner_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/common.dart';
import '../../providers/meal/meal_log_provider.dart';
import '../../providers/meal/nutrition_goal_provider.dart';
import '../../providers/auth/auth_provider.dart';
import 'food/food_search_screen.dart';
import 'insights_v2/meal_insights_screenv2.dart';
import 'report/meal_reports_screen.dart';
import 'widgets/calorie_card.dart';
import 'widgets/date_strip.dart';
import 'widgets/hydration_card.dart';
import 'widgets/macro_row.dart';
import 'widgets/meal_slot_card.dart';
import '../../providers/home/home_provider.dart';

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MealLogProvider>().loadTodayLog();
      context.read<NutritionGoalProvider>().loadGoals();
      context.read<HomeProvider>().loadTodaySummary();
    });
  }

  void _openFoodSearch(BuildContext context, String slotId, String slotName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FoodSearchScreen(slotId: slotId, slotName: slotName),
      ),
    ).then((_) => context.read<MealLogProvider>().loadTodayLog());
  }

  void _openInsights(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MealInsightsScreen()),
    );
  }

  void _openReports(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MealReportsScreen()),
    );
  }

  Future<void> _sendForReview(
    BuildContext context,
    MealLogProvider provider,
  ) async {
    final log = provider.currentLog;
    if (log == null) return;

    final dateStr =
        '${provider.selectedDate.year}-${provider.selectedDate.month.toString().padLeft(2, '0')}-${provider.selectedDate.day.toString().padLeft(2, '0')}';

    final success = await provider.sendLogForReview(dateStr);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Log sent to trainer for review' : 'Failed to send log',
        ),
        backgroundColor: success ? kGreen : kRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logProvider = context.watch<MealLogProvider>();
    final log = logProvider.currentLog;
    final isLoading = logProvider.isLoading;
    final isToday = logProvider.isToday;
    final isPro = context.read<AuthProvider>().user?.isPro ?? false;

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
          'Meal Planner',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: kTextDark,
          ),
        ),
        actions: [
          // Reports icon — pro only
          if (isPro)
            IconButton(
              icon: const Icon(Icons.assignment_outlined, color: kPrimary),
              onPressed: () => _openReports(context),
              tooltip: 'Reports',
            ),
          IconButton(
            icon: const Icon(Icons.insights_outlined, color: kPrimary),
            onPressed: () => _openInsights(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: kWhite,
            child: DateStrip(
              selectedDate: logProvider.selectedDate,
              onDateSelected: (date) =>
                  context.read<MealLogProvider>().selectDate(date),
            ),
          ),

          const SizedBox(height: 1),

          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: kPrimary),
                  )
                : log == null
                ? const EmptyState(
                    icon: Icons.restaurant_menu_outlined,
                    title: 'No log for this day',
                    subtitle: 'Select today to start logging meals',
                  )
                : RefreshIndicator(
                    color: kPrimary,
                    onRefresh: () =>
                        context.read<MealLogProvider>().loadTodayLog(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Consumer<HomeProvider>(
                            builder: (context, homeProvider, _) => CalorieCard(
                              log: log,
                              burned: homeProvider.caloriesBurned,
                            ),
                          ),
                          const SizedBox(height: 12),
                          MacroRow(log: log),
                          const SizedBox(height: 12),
                          HydrationCard(
                            hydration: log.hydration,
                            isToday: isToday,
                          ),
                          const SizedBox(height: 16),
                          const SectionLabel('Meals'),
                          const SizedBox(height: 10),

                          for (final slot in log.slots)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: MealSlotCard(
                                slot: slot,
                                isToday: isToday,
                                onAddFood: () => _openFoodSearch(
                                  context,
                                  slot.id,
                                  slot.displayName,
                                ),
                              ),
                            ),

                          // Send for review — past days only, pro only
                          if (!isToday && isPro) ...[
                            const SizedBox(height: 4),
                            _ReviewStatusWidget(
                              log: log,
                              onSend: () =>
                                  _sendForReview(context, logProvider),
                            ),
                          ],

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// REVIEW STATUS WIDGET
// shown at bottom of past day logs for pro users
// ─────────────────────────────────────────

class _ReviewStatusWidget extends StatelessWidget {
  final dynamic log;
  final VoidCallback onSend;

  const _ReviewStatusWidget({required this.log, required this.onSend});

  @override
  Widget build(BuildContext context) {
    // already reviewed — show trainer notes
    if (log.reviewStatus == 'reviewed') {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kPrimaryLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.check_circle_outline, size: 16, color: kPrimary),
                SizedBox(width: 6),
                Text(
                  'Reviewed by Trainer',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: kPrimary,
                  ),
                ),
              ],
            ),
            if (log.trainerNotes != null) ...[
              const SizedBox(height: 8),
              const SectionLabel('Trainer Notes'),
              const SizedBox(height: 4),
              Text(
                log.trainerNotes!,
                style: const TextStyle(
                  fontSize: 13,
                  color: kTextDark,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      );
    }

    // pending — waiting for trainer
    if (log.reviewStatus == 'pending') {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: const [
            Icon(Icons.schedule_outlined, size: 16, color: kTextGrey),
            SizedBox(width: 8),
            Text(
              'Sent for review · Awaiting trainer feedback',
              style: TextStyle(fontSize: 13, color: kTextGrey),
            ),
          ],
        ),
      );
    }

    // not sent — show send button
    return GestureDetector(
      onTap: onSend,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kPrimary.withOpacity(0.3)),
        ),
        child: const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.send_outlined, size: 16, color: kPrimary),
              SizedBox(width: 8),
              Text(
                'Send to Trainer for Review',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: kPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
