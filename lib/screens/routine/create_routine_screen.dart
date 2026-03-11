import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/routine/routine_provider.dart';
import '../../widgets/common.dart';
import 'routine_detail_screenV2.dart';

// Simple screen to create a new routine
// Just name and description, exercises added in detail screen after
class CreateRoutineScreen extends StatefulWidget {
  const CreateRoutineScreen({super.key});

  @override
  State<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a routine name'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final provider = context.read<RoutineProvider>();
    await provider.createRoutine(
      name: name,
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
    );

    if (mounted && provider.selectedRoutine != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RoutineDetailScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppTopBar(title: 'New Routine'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('NAME'),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: _nameController,
                      hint: 'e.g. Push Day',
                    ),
                    const SizedBox(height: 16),
                    const SectionLabel('DESCRIPTION (optional)'),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: _descController,
                      hint: 'e.g. Chest, shoulders and triceps',
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Consumer<RoutineProvider>(
                builder: (context, provider, _) => PrimaryButton(
                  text: 'Create Routine',
                  isLoading: provider.isLoading,
                  onTap: _save,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
