// lib/screens/meal/meal_planner_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/common.dart';
import '../../providers/meal/meal_log_provider.dart';
import '../../providers/meal/nutrition_goal_provider.dart';
import 'food/food_search_screen.dart';
import 'insights/meal_insights_screen.dart';
import 'widgets/calorie_card.dart';
import 'widgets/date_strip.dart';
import 'widgets/hydration_card.dart';
import 'widgets/macro_row.dart';
import 'widgets/meal_slot_card.dart';

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

  @override
  Widget build(BuildContext context) {
    final logProvider = context.watch<MealLogProvider>();
    final log = logProvider.currentLog;
    final isLoading = logProvider.isLoading;
    final isToday = logProvider.isToday;

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
          IconButton(
            icon: const Icon(Icons.insights_outlined, color: kPrimary),
            onPressed: () => _openInsights(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // date strip pinned at top
          Container(
            color: kWhite,
            child: DateStrip(
              selectedDate: logProvider.selectedDate,
              onDateSelected: (date) =>
                  context.read<MealLogProvider>().selectDate(date),
            ),
          ),

          const SizedBox(height: 1),

          // main scrollable content
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
                          // calorie ring
                          CalorieCard(log: log),

                          const SizedBox(height: 12),

                          // protein / carbs / fat bars
                          MacroRow(log: log),

                          const SizedBox(height: 12),

                          // water tracking
                          HydrationCard(
                            hydration: log.hydration,
                            isToday: isToday,
                          ),

                          const SizedBox(height: 16),

                          // meal slots label
                          const SectionLabel('Meals'),

                          const SizedBox(height: 10),

                          // one card per slot — no nested ListView
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

                          const SizedBox(height: 16),
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
