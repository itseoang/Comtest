part of 'achievement_bloc.dart';

abstract class AchievementState extends Equatable {
  const AchievementState();
  @override
  List<Object?> get props => [];
}

class AchievementInitial extends AchievementState {
  const AchievementInitial();
}

class AchievementLoaded extends AchievementState {
  const AchievementLoaded({
    required this.earnedBadgeIds,
    this.newlyEarnedBadge,
  });

  final List<String> earnedBadgeIds;
  /// non-null이면 축하 팝업 표시 후 null로 초기화
  final BadgeDefinition? newlyEarnedBadge;

  @override
  List<Object?> get props => [earnedBadgeIds, newlyEarnedBadge];
}
