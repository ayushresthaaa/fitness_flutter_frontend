import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user/user.dart';
import '../../providers/user/user.provider.dart';
import '../home/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  static const routeName = '/onboarding';

  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  DateTime? _dateOfBirth;
  Gender? _selectedGender;
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  FitnessGoal _selectedGoal = FitnessGoal.gain_muscle;
  ActivityLevel _selectedActivityLevel = ActivityLevel.moderate;

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1995, 1, 15),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Colors.blue[700]!),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  Future<void> _completeOnboarding() async {
    if (_dateOfBirth == null ||
        _selectedGender == null ||
        _heightController.text.isEmpty ||
        _weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final profile = UserProfile(
      dateOfBirth: _dateOfBirth,
      gender: _selectedGender,
      heightCm: double.tryParse(_heightController.text),
      currentWeightKg: double.tryParse(_weightController.text),
      fitnessGoal: _selectedGoal,
      activityLevel: _selectedActivityLevel,
      isOnboardingComplete: true,
    );

    try {
      await context.read<UserProvider>().completeOnboarding(profile: profile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile Complete! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to home
        Navigator.pushReplacementNamed(context, HomeScreen.routeName);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                const Text(
                  '🎯',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 80),
                ),
                const SizedBox(height: 16),
                Text(
                  'Complete Your Profile',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Help us personalize your experience',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 40),

                // Personal Information Section
                _SectionTitle(title: 'Personal Information'),
                const SizedBox(height: 16),

                // Date of Birth
                GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _dateOfBirth == null
                              ? 'Date of Birth'
                              : '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}',
                          style: TextStyle(
                            fontSize: 16,
                            color: _dateOfBirth == null
                                ? Colors.grey[600]
                                : Colors.grey[800],
                          ),
                        ),
                        Icon(Icons.calendar_today, color: Colors.grey[600]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Gender Dropdown
                DropdownButtonFormField<Gender>(
                  value: _selectedGender,
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  items: Gender.values.map((gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: Text(
                        gender.name[0].toUpperCase() + gender.name.substring(1),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedGender = value),
                ),
                const SizedBox(height: 32),

                // Body Measurements Section
                _SectionTitle(title: 'Body Measurements'),
                const SizedBox(height: 16),

                // Height
                TextField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Height (cm)',
                    hintText: '175',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Weight
                TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Current Weight (kg)',
                    hintText: '70',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Fitness Goal Section
                _SectionTitle(title: 'Fitness Goal'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _GoalChip(
                        label: 'Lose Fat',
                        isSelected: _selectedGoal == FitnessGoal.lose_fat,
                        onTap: () => setState(
                          () => _selectedGoal = FitnessGoal.lose_fat,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _GoalChip(
                        label: 'Gain Muscle',
                        isSelected: _selectedGoal == FitnessGoal.gain_muscle,
                        onTap: () => setState(
                          () => _selectedGoal = FitnessGoal.gain_muscle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _GoalChip(
                        label: 'Maintain',
                        isSelected: _selectedGoal == FitnessGoal.maintain,
                        onTap: () => setState(
                          () => _selectedGoal = FitnessGoal.maintain,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Activity Level Section
                _SectionTitle(title: 'Activity Level'),
                const SizedBox(height: 16),
                _ActivityOption(
                  label: 'Sedentary',
                  isSelected: _selectedActivityLevel == ActivityLevel.sedentary,
                  onTap: () => setState(
                    () => _selectedActivityLevel = ActivityLevel.sedentary,
                  ),
                ),
                const SizedBox(height: 12),
                _ActivityOption(
                  label: 'Light',
                  isSelected: _selectedActivityLevel == ActivityLevel.light,
                  onTap: () => setState(
                    () => _selectedActivityLevel = ActivityLevel.light,
                  ),
                ),
                const SizedBox(height: 12),
                _ActivityOption(
                  label: 'Moderate',
                  isSelected: _selectedActivityLevel == ActivityLevel.moderate,
                  onTap: () => setState(
                    () => _selectedActivityLevel = ActivityLevel.moderate,
                  ),
                ),
                const SizedBox(height: 12),
                _ActivityOption(
                  label: 'Active',
                  isSelected: _selectedActivityLevel == ActivityLevel.active,
                  onTap: () => setState(
                    () => _selectedActivityLevel = ActivityLevel.active,
                  ),
                ),
                const SizedBox(height: 12),
                _ActivityOption(
                  label: 'Very Active',
                  isSelected:
                      _selectedActivityLevel == ActivityLevel.very_active,
                  onTap: () => setState(
                    () => _selectedActivityLevel = ActivityLevel.very_active,
                  ),
                ),
                const SizedBox(height: 40),

                // Submit Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: userProvider.isLoading
                        ? null
                        : _completeOnboarding,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: userProvider.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Complete Setup',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Reusable Widgets
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.grey[800],
      ),
    );
  }
}

class _GoalChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalChip({
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
          color: isSelected ? Colors.blue[700] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue[700]! : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey[800],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ActivityOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[700] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue[700]! : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[800],
          ),
        ),
      ),
    );
  }
}
