part of 'achievement_bloc.dart';

abstract class AchievementEvent extends Equatable {
  const AchievementEvent();
  @override
  List<Object?> get props => [];
}

/// 초기 뱃지 목록 로드
class InitAchievements extends AchievementEvent {
  const InitAchievements({required this.earnedBadgeIds});
  final List<String> earnedBadgeIds;
  @override
  List<Object?> get props => [earnedBadgeIds];
}

/// 뱃지 진행도 체크 (stats 맵을 넘겨 비교)
class CheckBadgeProgress extends AchievementEvent {
  const CheckBadgeProgress({required this.stats});
  final Map<String, int> stats;
  @override
  List<Object?> get props => [stats];
}
