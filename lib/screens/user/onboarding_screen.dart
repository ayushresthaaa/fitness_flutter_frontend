import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user/user.dart';
import '../../providers/user/user.provider.dart';
import '../../widgets/common.dart';
import '../meal/nutrition_goal_screen.dart';

class OnboardingScreen extends StatefulWidget {
  static const routeName = '/onboarding';

  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4;

  // Step 1
  Gender? _selectedGender;
  DateTime? _dateOfBirth;

  // Step 2
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  // Step 3
  FitnessGoal _selectedGoal = FitnessGoal.gain_muscle;

  // Step 4
  ActivityLevel _selectedActivityLevel = ActivityLevel.moderate;
  EquipmentAccess _selectedEquipment = EquipmentAccess.full_gym;

  @override
  void dispose() {
    _pageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 0) {
      if (_selectedGender == null || _dateOfBirth == null) {
        _showError('Please select your gender and date of birth');
        return;
      }
    }
    if (_currentPage == 1) {
      if (_heightController.text.trim().isEmpty ||
          _weightController.text.trim().isEmpty) {
        _showError('Please enter your height and weight');
        return;
      }
      if (double.tryParse(_heightController.text.trim()) == null ||
          double.tryParse(_weightController.text.trim()) == null) {
        _showError('Please enter valid numbers');
        return;
      }
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _prevPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: kRed));
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1995, 1, 15),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: const ColorScheme.light(primary: kPrimary)),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  Future<void> _completeOnboarding() async {
    final profile = UserProfile(
      dateOfBirth: _dateOfBirth,
      gender: _selectedGender,
      heightCm: double.tryParse(_heightController.text.trim()),
      currentWeightKg: double.tryParse(_weightController.text.trim()),
      fitnessGoal: _selectedGoal,
      activityLevel: _selectedActivityLevel,
      equipmentAccess: _selectedEquipment,
      isOnboardingComplete: true,
    );

    try {
      await context.read<UserProvider>().completeOnboarding(profile: profile);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const NutritionGoalScreen(isOnboarding: true),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar + step indicator
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Step ${_currentPage + 1} of $_totalPages',
                        style: const TextStyle(
                          fontSize: 12,
                          color: kTextGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${((_currentPage + 1) / _totalPages * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          color: kPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_currentPage + 1) / _totalPages,
                      minHeight: 5,
                      backgroundColor: kDivider,
                      valueColor: const AlwaysStoppedAnimation<Color>(kPrimary),
                    ),
                  ),
                ],
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _Step1Personal(
                    selectedGender: _selectedGender,
                    dateOfBirth: _dateOfBirth,
                    onGenderSelected: (g) =>
                        setState(() => _selectedGender = g),
                    onDateTap: _selectDate,
                  ),
                  _Step2Metrics(
                    heightController: _heightController,
                    weightController: _weightController,
                  ),
                  _Step3Goal(
                    selectedGoal: _selectedGoal,
                    onGoalSelected: (g) => setState(() => _selectedGoal = g),
                  ),
                  _Step4Activity(
                    selectedActivity: _selectedActivityLevel,
                    selectedEquipment: _selectedEquipment,
                    onActivitySelected: (a) =>
                        setState(() => _selectedActivityLevel = a),
                    onEquipmentSelected: (e) =>
                        setState(() => _selectedEquipment = e),
                  ),
                ],
              ),
            ),

            // Bottom navigation
            Container(
              color: kWhite,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: GestureDetector(
                        onTap: _prevPage,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: kBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'Back',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: kTextDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _currentPage < _totalPages - 1
                        ? PrimaryButton(text: 'Next', onTap: _nextPage)
                        : PrimaryButton(
                            text: 'Finish',
                            isLoading: userProvider.isLoading,
                            onTap: userProvider.isLoading
                                ? null
                                : _completeOnboarding,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// STEP 1 — Personal Info
// ─────────────────────────────────────────

class _Step1Personal extends StatelessWidget {
  final Gender? selectedGender;
  final DateTime? dateOfBirth;
  final ValueChanged<Gender> onGenderSelected;
  final VoidCallback onDateTap;

  const _Step1Personal({
    required this.selectedGender,
    required this.dateOfBirth,
    required this.onGenderSelected,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Tell us about yourself',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: kTextDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'We use this to personalize your experience',
            style: TextStyle(fontSize: 13, color: kTextGrey),
          ),
          const SizedBox(height: 32),

          const SectionLabel('Gender'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SizedBox(
                width: (MediaQuery.of(context).size.width - 60) / 2,
                child: _SelectChip(
                  label: 'Male',
                  isSelected: selectedGender == Gender.male,
                  onTap: () => onGenderSelected(Gender.male),
                ),
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width - 60) / 2,
                child: _SelectChip(
                  label: 'Female',
                  isSelected: selectedGender == Gender.female,
                  onTap: () => onGenderSelected(Gender.female),
                ),
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width - 60) / 2,
                child: _SelectChip(
                  label: 'Other',
                  isSelected: selectedGender == Gender.other,
                  onTap: () => onGenderSelected(Gender.other),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          const SectionLabel('Date of Birth'),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onDateTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateOfBirth == null
                        ? 'Select date'
                        : '${dateOfBirth!.day}/${dateOfBirth!.month}/${dateOfBirth!.year}',
                    style: TextStyle(
                      fontSize: 14,
                      color: dateOfBirth == null ? kTextGrey : kTextDark,
                    ),
                  ),
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: kTextGrey,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// STEP 2 — Body Metrics
// ─────────────────────────────────────────

class _Step2Metrics extends StatelessWidget {
  final TextEditingController heightController;
  final TextEditingController weightController;

  const _Step2Metrics({
    required this.heightController,
    required this.weightController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Your body metrics',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: kTextDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Used to calculate your fitness recommendations',
            style: TextStyle(fontSize: 13, color: kTextGrey),
          ),
          const SizedBox(height: 32),

          const SectionLabel('Height (cm)'),
          const SizedBox(height: 10),
          AppTextField(
            controller: heightController,
            hint: 'e.g. 175',
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 20),

          const SectionLabel('Current Weight (kg)'),
          const SizedBox(height: 10),
          AppTextField(
            controller: weightController,
            hint: 'e.g. 70',
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// STEP 3 — Fitness Goal
// ─────────────────────────────────────────

class _Step3Goal extends StatelessWidget {
  final FitnessGoal selectedGoal;
  final ValueChanged<FitnessGoal> onGoalSelected;

  const _Step3Goal({required this.selectedGoal, required this.onGoalSelected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'What is your goal?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: kTextDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'This helps us tailor your routines and nutrition',
            style: TextStyle(fontSize: 13, color: kTextGrey),
          ),
          const SizedBox(height: 32),

          _GoalOption(
            label: 'Lose Fat',
            subtitle: 'Reduce body fat while maintaining muscle',
            isSelected: selectedGoal == FitnessGoal.lose_fat,
            onTap: () => onGoalSelected(FitnessGoal.lose_fat),
          ),
          const SizedBox(height: 12),
          _GoalOption(
            label: 'Gain Muscle',
            subtitle: 'Build strength and increase muscle mass',
            isSelected: selectedGoal == FitnessGoal.gain_muscle,
            onTap: () => onGoalSelected(FitnessGoal.gain_muscle),
          ),
          const SizedBox(height: 12),
          _GoalOption(
            label: 'Maintain',
            subtitle: 'Stay at your current weight and fitness level',
            isSelected: selectedGoal == FitnessGoal.maintain,
            onTap: () => onGoalSelected(FitnessGoal.maintain),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// STEP 4 — Activity + Equipment
// ─────────────────────────────────────────

class _Step4Activity extends StatelessWidget {
  final ActivityLevel selectedActivity;
  final EquipmentAccess selectedEquipment;
  final ValueChanged<ActivityLevel> onActivitySelected;
  final ValueChanged<EquipmentAccess> onEquipmentSelected;

  const _Step4Activity({
    required this.selectedActivity,
    required this.selectedEquipment,
    required this.onActivitySelected,
    required this.onEquipmentSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Activity and equipment',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: kTextDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'So we can match routines to your lifestyle',
            style: TextStyle(fontSize: 13, color: kTextGrey),
          ),
          const SizedBox(height: 32),

          const SectionLabel('Activity Level'),
          const SizedBox(height: 10),

          _ActivityOption(
            label: 'Sedentary',
            subtitle: 'Little or no exercise',
            isSelected: selectedActivity == ActivityLevel.sedentary,
            onTap: () => onActivitySelected(ActivityLevel.sedentary),
          ),
          const SizedBox(height: 10),
          _ActivityOption(
            label: 'Lightly Active',
            subtitle: 'Light exercise 1-3 days/week',
            isSelected: selectedActivity == ActivityLevel.light,
            onTap: () => onActivitySelected(ActivityLevel.light),
          ),
          const SizedBox(height: 10),
          _ActivityOption(
            label: 'Moderately Active',
            subtitle: 'Moderate exercise 3-5 days/week',
            isSelected: selectedActivity == ActivityLevel.moderate,
            onTap: () => onActivitySelected(ActivityLevel.moderate),
          ),
          const SizedBox(height: 10),
          _ActivityOption(
            label: 'Active',
            subtitle: 'Hard exercise 6-7 days/week',
            isSelected: selectedActivity == ActivityLevel.active,
            onTap: () => onActivitySelected(ActivityLevel.active),
          ),
          const SizedBox(height: 10),
          _ActivityOption(
            label: 'Very Active',
            subtitle: 'Very hard exercise and physical job',
            isSelected: selectedActivity == ActivityLevel.very_active,
            onTap: () => onActivitySelected(ActivityLevel.very_active),
          ),

          const SizedBox(height: 28),

          const SectionLabel('Equipment Access'),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _SelectChip(
                  label: 'Full Gym',
                  isSelected: selectedEquipment == EquipmentAccess.full_gym,
                  onTap: () => onEquipmentSelected(EquipmentAccess.full_gym),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SelectChip(
                  label: 'Garage Gym',
                  isSelected: selectedEquipment == EquipmentAccess.garage_gym,
                  onTap: () => onEquipmentSelected(EquipmentAccess.garage_gym),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _SelectChip(
                  label: 'Dumbbells Only',
                  isSelected:
                      selectedEquipment == EquipmentAccess.dumbbell_only,
                  onTap: () =>
                      onEquipmentSelected(EquipmentAccess.dumbbell_only),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SelectChip(
                  label: 'At Home',
                  isSelected: selectedEquipment == EquipmentAccess.at_home,
                  onTap: () => onEquipmentSelected(EquipmentAccess.at_home),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// SHARED SMALL WIDGETS
// ─────────────────────────────────────────

class _SelectChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectChip({
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
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? kPrimary : kTextHint,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? kWhite : kTextDark,
            ),
          ),
        ),
      ),
    );
  }
}

class _GoalOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalOption({
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? kPrimary : kWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? kPrimary : kTextHint,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? kWhite : kTextDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? kWhite.withOpacity(0.8) : kTextGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ActivityOption({
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? kPrimary : kWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? kPrimary : kTextHint,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? kWhite : kTextDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? kWhite.withOpacity(0.8) : kTextGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
