import 'package:equatable/equatable.dart';

enum ChallengeTaskType {
  discoverSpecies,
  discoverCategory,
  writeDiary,
  quizCorrect,
  petCare,
}

class ChallengeTask extends Equatable {
  const ChallengeTask({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.emoji,
    required this.targetCount,
    this.currentCount = 0,
    this.targetCategory,
    this.targetSpecies,
  });

  final String id;
  final ChallengeTaskType type;
  final String title;
  final String description;
  final String emoji;
  final int targetCount;
  final int currentCount;
  final String? targetCategory;
  final String? targetSpecies;

  bool get isCompleted => currentCount >= targetCount;

  ChallengeTask copyWith({
    String? id,
    ChallengeTaskType? type,
    String? title,
    String? description,
    String? emoji,
    int? targetCount,
    int? currentCount,
    String? targetCategory,
    String? targetSpecies,
  }) {
    return ChallengeTask(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      targetCount: targetCount ?? this.targetCount,
      currentCount: currentCount ?? this.currentCount,
      targetCategory: targetCategory ?? this.targetCategory,
      targetSpecies: targetSpecies ?? this.targetSpecies,
    );
  }

  @override
  List<Object?> get props => [id, type, title, description, emoji, targetCount, currentCount, targetCategory, targetSpecies];
}

class Challenge extends Equatable {
  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.weekNumber,
    required this.tasks,
    required this.rewardPoints,
    required this.rewardPetExp,
    this.isClaimed = false,
  });

  final String id;
  final String title;
  final String description;
  final int weekNumber;
  final List<ChallengeTask> tasks;
  final int rewardPoints;
  final int rewardPetExp;
  final bool isClaimed;

  int get completedCount => tasks.where((t) => t.isCompleted).length;
  int get totalCount => tasks.length;
  bool get isAllCompleted => tasks.every((t) => t.isCompleted);
  double get progress => totalCount > 0 ? completedCount / totalCount : 0.0;

  Challenge copyWith({
    String? id,
    String? title,
    String? description,
    int? weekNumber,
    List<ChallengeTask>? tasks,
    int? rewardPoints,
    int? rewardPetExp,
    bool? isClaimed,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      weekNumber: weekNumber ?? this.weekNumber,
      tasks: tasks ?? this.tasks,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      rewardPetExp: rewardPetExp ?? this.rewardPetExp,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }

  @override
  List<Object?> get props => [id, title, description, weekNumber, tasks, rewardPoints, rewardPetExp, isClaimed];
}
