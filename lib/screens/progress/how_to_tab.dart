import 'package:flutter/material.dart';
import '../../../models/exercise/exercise_model.dart';
import '../../../api/api_endpoints.dart';
import '../../../widgets/common.dart';

class HowToTab extends StatelessWidget {
  final Exercise exercise;

  const HowToTab({super.key, required this.exercise});

  String _fixUrl(String url) {
    return url.replaceAll('localhost', ApiEndpoints.ip);
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Swipeable images
          if (exercise.images.isNotEmpty)
            SizedBox(
              height: 200,
              child: PageView(
                children: exercise.images.map((url) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _fixUrl(url),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Container(
                            color: kBackground,
                            child: const Center(
                              child: Icon(
                                Icons.fitness_center,
                                size: 40,
                                color: kPrimary,
                              ),
                            ),
                          );
                        },
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
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 16),

          // Details
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('DETAILS'),
                const SizedBox(height: 12),
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
                    if (exercise.force != null)
                      _Tag(label: _capitalize(exercise.force!), isBlue: false),
                  ],
                ),

                if (exercise.primaryMuscles.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: kDivider),
                  const SizedBox(height: 14),
                  const Text(
                    'Primary Muscles',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kTextDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: exercise.primaryMuscles.map((muscle) {
                      return _MusclePill(
                        label: _capitalize(muscle),
                        isPrimary: true,
                      );
                    }).toList(),
                  ),
                ],

                if (exercise.secondaryMuscles.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Secondary Muscles',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kTextDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: exercise.secondaryMuscles.map((muscle) {
                      return _MusclePill(
                        label: _capitalize(muscle),
                        isPrimary: false,
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Instructions
          if (exercise.instructions.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionLabel('INSTRUCTIONS'),
                  const SizedBox(height: 12),
                  for (int i = 0; i < exercise.instructions.length; i++) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Container(
                        //   width: 26,
                        //   height: 26,
                        //   decoration: const BoxDecoration(
                        //     color: kPrimary,
                        //     shape: BoxShape.circle,
                        //   ),
                        //   child: Center(
                        //     child: Text(
                        //       '${i + 1}',
                        //       style: const TextStyle(
                        //         fontSize: 12,
                        //         fontWeight: FontWeight.w700,
                        //         color: kWhite,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${i + 1}. ${exercise.instructions[i]}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: kTextDark,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (i < exercise.instructions.length - 1)
                      const Divider(color: kDivider, height: 20),
                  ],
                ],
              ),
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

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
