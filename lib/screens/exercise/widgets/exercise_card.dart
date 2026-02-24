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
    // Get first image if available
    String? imageUrl;
    if (exercise.images.isNotEmpty) {
      imageUrl = exercise.images[0].replaceAll('localhost', '192.168.1.76');
    }

    // Format subtitle text
    final category = _capitalize(exercise.category);
    final level = _capitalize(exercise.level);

    // Get first 2 muscles as plain text
    final muscles = exercise.primaryMuscles.take(2).join(', ');

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
            _ExerciseImage(imageUrl: imageUrl),

            const SizedBox(width: 12),

            /// TEXT PART
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    '$category · $level',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),

                  if (muscles.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      muscles,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
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

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
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
      child: imageUrl == null
          ? const Icon(Icons.fitness_center, size: 24, color: Color(0xFF2563EB))
          : Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.fitness_center, size: 24),
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;

                return const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
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
    final bgColor = isSelected
        ? const Color(0xFF2563EB)
        : const Color(0xFFF0F4FF);

    final iconColor = isSelected ? Colors.white : const Color(0xFF2563EB);

    final icon = isSelected ? Icons.check : Icons.add;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
    );
  }
}
