import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../widgets/common.dart';

class CreateExerciseImagePicker extends StatelessWidget {
  final List<String> imagePaths;
  final VoidCallback onPick;
  final ValueChanged<int> onRemove;

  const CreateExerciseImagePicker({
    super.key,
    required this.imagePaths,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('IMAGES (OPTIONAL)'),
        const SizedBox(height: 8),

        // Show thumbnails if any images are picked
        if (imagePaths.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: imagePaths.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return _ImageThumbnail(
                  path: imagePaths[index],
                  onRemove: () => onRemove(index),
                );
              },
            ),
          ),

        if (imagePaths.isNotEmpty) const SizedBox(height: 10),

        // hidden when max 5 images reached
        if (imagePaths.length < 5) AddButton(text: 'Add Images', onTap: onPick),
      ],
    );
  }
}

// Single image thumbnail with remove button
class _ImageThumbnail extends StatelessWidget {
  final String path;
  final VoidCallback onRemove;

  const _ImageThumbnail({required this.path, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            File(path),
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 100,
                height: 100,
                color: kBackground,
                child: const Icon(Icons.image, color: kTextHint),
              );
            },
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: kRed,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: kWhite),
            ),
          ),
        ),
      ],
    );
  }
}
