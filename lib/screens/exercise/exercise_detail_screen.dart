import 'package:flutter/material.dart';
import '../../models/exercise/exercise_model.dart';
import '../../widgets/common.dart';
import '../../api/api_endpoints.dart';

// Exercise detail screen
// Shows full info images, muscles, instructions
// Opened from workout screen or browse exercises screen
class ExerciseDetailScreen extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  String _fixUrl(String url) => url.replaceAll('localhost', ApiEndpoints.ip);

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppTopBar(title: 'Exercise Details'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First image — hero
            // Swipeable image gallery
            if (exercise.images.isNotEmpty)
              SizedBox(
                height: 200, // height for the gallery
                child: PageView(
                  children: exercise.images
                      .map(
                        (url) => ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            _fixUrl(url),
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.fitness_center,
                              size: 40,
                              color: kPrimary,
                            ),
                            loadingBuilder: (_, child, progress) {
                              if (progress == null) return child;
                              return const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: kPrimary,
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),

            const SizedBox(height: 16),

            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: kTextDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _Tag(label: _capitalize(exercise.category), isBlue: true),
                      _Tag(label: _capitalize(exercise.level), isBlue: true),
                      if (exercise.equipment != null)
                        _Tag(
                          label: _capitalize(
                            exercise.equipment!.replaceAll('_', ' '),
                          ),
                          isBlue: false,
                        ),
                      if (exercise.mechanic != null)
                        _Tag(
                          label: _capitalize(exercise.mechanic!),
                          isBlue: false,
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Muscles
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionLabel('Muscles'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      for (final m in exercise.primaryMuscles)
                        _MusclePill(label: _capitalize(m), isPrimary: true),
                      for (final m in exercise.secondaryMuscles)
                        _MusclePill(label: _capitalize(m), isPrimary: false),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Instructions
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionLabel('Instructions'),
                  const SizedBox(height: 12),
                  for (int i = 0; i < exercise.instructions.length; i++) ...[
                    _Step(number: i + 1, text: exercise.instructions[i]),
                    if (i < exercise.instructions.length - 1)
                      const Divider(color: kDivider, height: 20),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// White card container used throughout this screen
class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

// Blue or grey tag — category, level, equipment
class _Tag extends StatelessWidget {
  final String label;
  final bool isBlue;

  const _Tag({required this.label, required this.isBlue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isBlue ? kPrimaryLight : kBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isBlue ? kPrimary : kTextGrey,
        ),
      ),
    );
  }
}

// Muscle pill — blue for primary, grey for secondary
class _MusclePill extends StatelessWidget {
  final String label;
  final bool isPrimary;

  const _MusclePill({required this.label, required this.isPrimary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: isPrimary ? kPrimaryLight : kBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isPrimary ? kPrimary : kTextDark,
        ),
      ),
    );
  }
}

// Single numbered step
class _Step extends StatelessWidget {
  final int number;
  final String text;

  const _Step({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(
            color: kPrimary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: kWhite,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: kTextDark, height: 1.5),
          ),
        ),
      ],
    );
  }
}
