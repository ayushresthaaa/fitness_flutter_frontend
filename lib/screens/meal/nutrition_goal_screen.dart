import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/meal/nutrition_goal_provider.dart';
import '../../storage/local_storage.dart';
import '../../widgets/common.dart';
import '../home/home_screen.dart';

class NutritionGoalScreen extends StatefulWidget {
  static const routeName = '/nutrition-goal';

  final bool isOnboarding;

  const NutritionGoalScreen({super.key, required this.isOnboarding});

  @override
  State<NutritionGoalScreen> createState() => _NutritionGoalScreenState();
}

class _NutritionGoalScreenState extends State<NutritionGoalScreen> {
  // Which split mode the user picked
  bool _isManual = false;

  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load any existing goal and pre-fill the fields
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingGoal();
    });
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingGoal() async {
    final provider = context.read<NutritionGoalProvider>();
    await provider.loadGoals();

    final goal = provider.goal;
    if (goal != null && mounted) {
      _caloriesController.text = goal.calories.toStringAsFixed(0);
      _proteinController.text = goal.protein.toStringAsFixed(0);
      _carbsController.text = goal.carbs.toStringAsFixed(0);
      _fatController.text = goal.fat.toStringAsFixed(0);
    }
  }

  Future<void> _save() async {
    // Validate calories field — always required
    final caloriesText = _caloriesController.text.trim();
    if (caloriesText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your daily calorie goal'),
          backgroundColor: kRed,
        ),
      );
      return;
    }

    final calories = double.tryParse(caloriesText);
    if (calories == null || calories <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid calorie amount'),
          backgroundColor: kRed,
        ),
      );
      return;
    }

    // In manual mode, all three macro fields are required
    double? protein;
    double? carbs;
    double? fat;

    if (_isManual) {
      final proteinText = _proteinController.text.trim();
      final carbsText = _carbsController.text.trim();
      final fatText = _fatController.text.trim();

      if (proteinText.isEmpty || carbsText.isEmpty || fatText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill in protein, carbs, and fat'),
            backgroundColor: kRed,
          ),
        );
        return;
      }

      protein = double.tryParse(proteinText);
      carbs = double.tryParse(carbsText);
      fat = double.tryParse(fatText);

      if (protein == null || carbs == null || fat == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter valid numbers for all macros'),
            backgroundColor: kRed,
          ),
        );
        return;
      }
    }

    final provider = context.read<NutritionGoalProvider>();
    final success = await provider.updateGoals(
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
    );

    if (!mounted) return;

    if (success) {
      // Mark that the user has completed nutrition goal setup so the
      // OnboardingGuard does not prompt them again on next app launch.
      await LocalStorageService().setBool('nutrition_goal_set', true);

      if (!mounted) return;

      if (widget.isOnboarding) {
        Navigator.pushReplacementNamed(context, HomeScreen.routeName);
      } else {
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to save goal'),
          backgroundColor: kRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NutritionGoalProvider>();

    return Scaffold(
      backgroundColor: kBackground,
      appBar: widget.isOnboarding
          ? null
          : AppTopBar(title: 'Nutrition Goal'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.isOnboarding) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Set Your Nutrition Goal',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: kTextDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'We\'ll track your daily intake against these targets',
                        style: TextStyle(fontSize: 14, color: kTextGrey),
                      ),
                      const SizedBox(height: 32),
                    ] else
                      const SizedBox(height: 8),

                    // Calories field
                    const SectionLabel('Daily Calories'),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: _caloriesController,
                      hint: 'e.g. 2000',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),

                    // Mode toggle: Auto Split / Manual
                    const SectionLabel('Macro Split'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _ModeChip(
                            label: 'Auto Split',
                            isSelected: !_isManual,
                            onTap: () => setState(() => _isManual = false),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ModeChip(
                            label: 'Manual',
                            isSelected: _isManual,
                            onTap: () => setState(() => _isManual = true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isManual
                          ? 'Enter your own protein, carbs, and fat targets.'
                          : 'Macros will be calculated automatically based on your fitness goal.',
                      style: const TextStyle(fontSize: 13, color: kTextGrey),
                    ),

                    // Manual macro fields — only visible in manual mode
                    if (_isManual) ...[
                      const SizedBox(height: 24),
                      const SectionLabel('Protein (g)'),
                      const SizedBox(height: 8),
                      AppTextField(
                        controller: _proteinController,
                        hint: 'e.g. 150',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      const SectionLabel('Carbs (g)'),
                      const SizedBox(height: 8),
                      AppTextField(
                        controller: _carbsController,
                        hint: 'e.g. 200',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      const SectionLabel('Fat (g)'),
                      const SizedBox(height: 8),
                      AppTextField(
                        controller: _fatController,
                        hint: 'e.g. 65',
                        keyboardType: TextInputType.number,
                      ),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Save button pinned at bottom
            BottomBar(
              child: PrimaryButton(
                text: widget.isOnboarding ? 'Get Started' : 'Save Goal',
                isLoading: provider.isLoading,
                onTap: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? kPrimary : kWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? kPrimary : kTextHint,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? kWhite : kTextDark,
            ),
          ),
        ),
      ),
    );
  }
}
