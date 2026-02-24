import 'package:fitness_app/api/api_endpoints.dart';
import 'package:flutter/material.dart';
import '../../../models/exercise/exercise_model.dart';
import '../../../widgets/common.dart';

// Single exercise card shown in the picker list
class ExerciseCardV2 extends StatelessWidget {
  final Exercise exercise;
  final bool isSelected;
  final VoidCallback onTap;

  const ExerciseCardV2({
    super.key,
    required this.exercise,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Fix localhost URL to actual backend IP
    String? imageUrl;
    if (exercise.images.isNotEmpty) {
      imageUrl = exercise.images.first.replaceAll('localhost', ApiEndpoints.ip);
    }

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
          // blue border when selected
          border: Border.all(
            color: isSelected ? kPrimary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Exercise thumbnail
            _Thumbnail(imageUrl: imageUrl),
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

            // Select circle — filled blue with checkmark when selected
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

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
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
