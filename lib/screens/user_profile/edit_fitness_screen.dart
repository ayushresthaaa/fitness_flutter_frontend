import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user/user.dart';
import '../../providers/user/user.provider.dart';
import '../../widgets/common.dart';

class EditFitnessScreen extends StatefulWidget {
  const EditFitnessScreen({super.key});

  @override
  State<EditFitnessScreen> createState() => _EditFitnessScreenState();
}

class _EditFitnessScreenState extends State<EditFitnessScreen> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  FitnessGoal? _selectedGoal;
  ActivityLevel? _selectedActivity;
  EquipmentAccess? _selectedEquipment;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<UserProvider>().currentProfile;
    if (profile != null) {
      _heightController.text =
          profile.heightCm?.toStringAsFixed(0) ?? '';
      _weightController.text =
          profile.currentWeightKg?.toStringAsFixed(0) ?? '';
      _selectedGoal = profile.fitnessGoal;
      _selectedActivity = profile.activityLevel;
      _selectedEquipment = profile.equipmentAccess;
    }
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _isSaving = true;
    });

    try {
      await context.read<UserProvider>().updateFitnessProfile(
        heightCm: double.tryParse(_heightController.text.trim()),
        currentWeightKg: double.tryParse(_weightController.text.trim()),
        fitnessGoal: _selectedGoal?.toJson(),
        activityLevel: _selectedActivity?.toJson(),
        equipmentAccess: _selectedEquipment?.toJson(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fitness profile updated')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppTopBar(title: 'Fitness Profile'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Height
            const Text(
              'Height (cm)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 6),
            AppTextField(
              controller: _heightController,
              hint: 'e.g. 175',
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 16),

            // Weight
            const Text(
              'Weight (kg)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 6),
            AppTextField(
              controller: _weightController,
              hint: 'e.g. 70',
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 16),

            // Fitness Goal
            const Text(
              'Fitness Goal',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 6),
            _DropdownField<FitnessGoal>(
              value: _selectedGoal,
              hint: 'Select goal',
              items: FitnessGoal.values,
              labelFor: (goal) => goal.label,
              onChanged: (value) {
                setState(() {
                  _selectedGoal = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // Activity Level
            const Text(
              'Activity Level',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 6),
            _DropdownField<ActivityLevel>(
              value: _selectedActivity,
              hint: 'Select activity level',
              items: ActivityLevel.values,
              labelFor: (level) => level.label,
              onChanged: (value) {
                setState(() {
                  _selectedActivity = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // Equipment Access
            const Text(
              'Equipment Access',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 6),
            _DropdownField<EquipmentAccess>(
              value: _selectedEquipment,
              hint: 'Select equipment',
              items: EquipmentAccess.values,
              labelFor: (eq) => eq.label,
              onChanged: (value) {
                setState(() {
                  _selectedEquipment = value;
                });
              },
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: BottomBar(
        child: PrimaryButton(
          text: 'Save Changes',
          isLoading: _isSaving,
          onTap: _save,
        ),
      ),
    );
  }
}

// Reusable dropdown field styled like AppTextField
class _DropdownField<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final List<T> items;
  final String Function(T) labelFor;
  final void Function(T?) onChanged;

  const _DropdownField({
    required this.value,
    required this.hint,
    required this.items,
    required this.labelFor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kDivider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(fontSize: 14, color: kTextHint),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: kTextGrey),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                labelFor(item),
                style: const TextStyle(fontSize: 14, color: kTextDark),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}