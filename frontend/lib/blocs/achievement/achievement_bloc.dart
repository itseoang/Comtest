import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/badge_definitions.dart';
import '../../models/badge.dart';

part 'achievement_event.dart';
part 'achievement_state.dart';

class AchievementBloc extends Bloc<AchievementEvent, AchievementState> {
  AchievementBloc() : super(const AchievementInitial()) {
    on<InitAchievements>(_onInit);
    on<CheckBadgeProgress>(_onCheck);
  }

  Future<void> _onInit(
    InitAchievements event,
    Emitter<AchievementState> emit,
  ) async {
    emit(AchievementLoaded(
      earnedBadgeIds: List<String>.from(event.earnedBadgeIds),
    ));
  }

  Future<void> _onCheck(
    CheckBadgeProgress event,
    Emitter<AchievementState> emit,
  ) async {
    if (state is! AchievementLoaded) return;
    final current = state as AchievementLoaded;

    final earned = List<String>.from(current.earnedBadgeIds);
    BadgeDefinition? newBadge;

    for (final badge in kAllBadges) {
      if (earned.contains(badge.id)) continue;
      final value = event.stats[badge.conditionKey] ?? 0;
      if (value >= badge.requiredValue) {
        earned.add(badge.id);
        // 가장 최근 획득한 뱃지만 축하 팝업
        newBadge = badge;
      }
    }

    if (newBadge != null) {
      emit(AchievementLoaded(
        earnedBadgeIds: earned,
        newlyEarnedBadge: newBadge,
      ));
    }
  }
}
