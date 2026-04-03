import '../../api/api_endpoints.dart';

class CustomExercise {
  final String id;
  final String name;
  final String category;
  final String level;
  final String? force;
  final String? mechanic;
  final String? equipment;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final List<String> instructions;
  final List<String> images;
  final bool isCustom;
  final int createdBy;

  CustomExercise({
    required this.id,
    required this.name,
    required this.category,
    required this.level,
    this.force,
    this.mechanic,
    this.equipment,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.instructions,
    required this.images,
    required this.isCustom,
    required this.createdBy,
  });

  factory CustomExercise.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'] as List? ?? [];
    final images = rawImages.map((e) {
      final path = e as String;

      String finalUrl;
      if (path.startsWith('http://localhost:4000')) {
        // Replace localhost with Ngrok
        finalUrl = path.replaceFirst(
          RegExp(r'http://localhost:4000'),
          ApiEndpoints.staticHost,
        );
      } else if (!path.startsWith('http')) {
        // Only prepend ApiEndpoints.staticHost once, don't add extra /static
        finalUrl = '${ApiEndpoints.staticHost}/$path';
      } else {
        // Already full URL (ngrok/external)
        finalUrl = path;
      }

      print('Exercise image URL: $finalUrl'); // Debugging
      return finalUrl;
    }).toList();

    return CustomExercise(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      level: json['level'],
      force: json['force'],
      mechanic: json['mechanic'],
      equipment: json['equipment'],
      primaryMuscles: List<String>.from(json['primaryMuscles'] ?? []),
      secondaryMuscles: List<String>.from(json['secondaryMuscles'] ?? []),
      instructions: List<String>.from(json['instructions'] ?? []),
      images: images,
      isCustom: json['isCustom'] ?? true,
      createdBy: json['createdBy'] ?? 0,
    );
  }
}
