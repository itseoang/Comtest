import 'package:equatable/equatable.dart';

class GuardianComment extends Equatable {
  const GuardianComment({
    required this.id,
    required this.authorName,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String authorName;
  final String content;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, authorName, content, createdAt];
}

class DiaryEntry extends Equatable {
  const DiaryEntry({
    required this.id,
    required this.speciesName,
    required this.speciesCategory,
    required this.title,
    required this.content,
    required this.mood,
    required this.createdAt,
    this.imagePath,
    this.location,
    this.latitude,
    this.longitude,
    this.companion,
    this.guardianComments = const [],
  });

  final String id;
  final String speciesName;
  final String speciesCategory;
  final String title;
  final String content;
  final String mood;
  final DateTime createdAt;
  final String? imagePath;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String? companion;
  final List<GuardianComment> guardianComments;

  DiaryEntry copyWith({
    String? id,
    String? speciesName,
    String? speciesCategory,
    String? title,
    String? content,
    String? mood,
    DateTime? createdAt,
    String? imagePath,
    String? location,
    double? latitude,
    double? longitude,
    String? companion,
    List<GuardianComment>? guardianComments,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      speciesName: speciesName ?? this.speciesName,
      speciesCategory: speciesCategory ?? this.speciesCategory,
      title: title ?? this.title,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      createdAt: createdAt ?? this.createdAt,
      imagePath: imagePath ?? this.imagePath,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      companion: companion ?? this.companion,
      guardianComments: guardianComments ?? this.guardianComments,
    );
  }

  @override
  List<Object?> get props => [
        id,
        speciesName,
        speciesCategory,
        title,
        content,
        mood,
        createdAt,
        imagePath,
        location,
        latitude,
        longitude,
        companion,
        guardianComments,
      ];
}
