import 'package:equatable/equatable.dart';

class DiaryEntry extends Equatable {
  const DiaryEntry({
    required this.id,
    required this.speciesName,
    required this.title,
    required this.content,
    required this.mood,
    required this.createdAt,
  });

  final String id;
  final String speciesName;
  final String title;
  final String content;
  final String mood;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, speciesName, title, content, mood, createdAt];
}
