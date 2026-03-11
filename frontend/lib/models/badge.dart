import 'package:equatable/equatable.dart';

enum BadgeCategory { login, quiz, collection, ecoPoints, special }

class BadgeDefinition extends Equatable {
  const BadgeDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.category,
    required this.conditionKey,
    required this.requiredValue,
  });

  final String id;
  final String name;
  final String description;
  final String emoji;
  final BadgeCategory category;
  /// 'loginCount' | 'loginStreak' | 'quizCount' | 'collectionCount' | 'ecoPoints'
  final String conditionKey;
  final int requiredValue;

  /// 이모지 + 이름 형태의 칭호 문자열
  String get titleLabel => '$emoji $name';

  @override
  List<Object?> get props => [id, name, description, emoji, category, conditionKey, requiredValue];
}
