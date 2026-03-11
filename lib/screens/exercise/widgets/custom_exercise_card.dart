import 'package:flutter/material.dart';
import '../../../models/exercise/custom_exercise_model.dart';
import '../../../widgets/common.dart';

class CustomExerciseCard extends StatelessWidget {
  final CustomExercise exercise;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEditTap;

  const CustomExerciseCard({
    super.key,
    required this.exercise,
    required this.isSelected,
    required this.onTap,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final meta =
        '${_capitalize(exercise.category)}  ${_capitalize(exercise.level)}';
    final muscles = exercise.primaryMuscles.take(2).join(', ');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? kPrimary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Thumbnail — show first image or fallback icon
            _Thumbnail(
              imageUrl: exercise.images.isNotEmpty
                  ? exercise.images.first
                  : null,
            ),
            const SizedBox(width: 12),

            // Name, category, muscles
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
                      color: kTextDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    meta,
                    style: const TextStyle(fontSize: 12, color: kTextHint),
                  ),
                  if (muscles.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      muscles,
                      style: const TextStyle(fontSize: 11, color: kTextHint),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Edit button
            GestureDetector(
              onTap: onEditTap,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: kBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: kTextGrey,
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Select circle
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? kPrimary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? kPrimary : kTextHint,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: kWhite)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

// Thumbnail with network image and fallback icon
class _Thumbnail extends StatelessWidget {
  final String? imageUrl;

  const _Thumbnail({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: kPrimaryLight,
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl == null
          ? const Icon(Icons.fitness_center, size: 24, color: kPrimary)
          : Image.network(imageUrl!, fit: BoxFit.cover),
    );
  }
}
