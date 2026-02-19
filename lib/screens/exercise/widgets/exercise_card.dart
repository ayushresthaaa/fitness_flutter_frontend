import 'package:flutter/material.dart';
import '../../../models/exercise/exercise_model.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.isSelected,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _ExerciseImage(
              imageUrl: exercise.images.isNotEmpty
                  ? exercise.images[0].replaceAll('localhost', '192.168.1.82')
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_capitalize(exercise.category)} · ${_capitalize(exercise.level)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  if (exercise.primaryMuscles.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: exercise.primaryMuscles
                          .take(2)
                          .map((m) => _MuscleTag(label: m))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            _AddButton(isSelected: isSelected, onTap: onAdd),
          ],
        ),
      ),
    );
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}

class _ExerciseImage extends StatelessWidget {
  final String? imageUrl;

  const _ExerciseImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const _ImageFallback(),
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
            )
          : const _ImageFallback(),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.fitness_center, color: Color(0xFF2563EB), size: 24);
  }
}

class _MuscleTag extends StatelessWidget {
  final String label;

  const _MuscleTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF2563EB),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _AddButton({required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF0F4FF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          isSelected ? Icons.check : Icons.add,
          size: 18,
          color: isSelected ? Colors.white : const Color(0xFF2563EB),
        ),
      ),
    );
  }
}
