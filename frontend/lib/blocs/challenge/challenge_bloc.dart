import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/challenge_bank.dart';
import '../../models/challenge.dart';
import '../collection/collection_bloc.dart';

// Events
abstract class ChallengeEvent extends Equatable {
  const ChallengeEvent();
  @override
  List<Object?> get props => [];
}

class LoadChallenge extends ChallengeEvent {
  const LoadChallenge();
}

class UpdateTaskProgress extends ChallengeEvent {
  const UpdateTaskProgress({
    required this.type,
    this.speciesName,
    this.category,
  });

  final ChallengeTaskType type;
  final String? speciesName;
  final String? category;

  @override
  List<Object?> get props => [type, speciesName, category];
}

class ClaimReward extends ChallengeEvent {
  const ClaimReward();
}

// States
abstract class ChallengeState extends Equatable {
  const ChallengeState();
  @override
  List<Object?> get props => [];
}

class ChallengeInitial extends ChallengeState {
  const ChallengeInitial();
}

class ChallengeLoaded extends ChallengeState {
  const ChallengeLoaded({required this.challenge});
  final Challenge challenge;

  @override
  List<Object?> get props => [challenge];
}

class ChallengeRewardClaimed extends ChallengeState {
  const ChallengeRewardClaimed({
    required this.challenge,
    required this.points,
    required this.petExp,
  });
  final Challenge challenge;
  final int points;
  final int petExp;

  @override
  List<Object?> get props => [challenge, points, petExp];
}

class ChallengeError extends ChallengeState {
  const ChallengeError({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}

// BLoC
class ChallengeBloc extends Bloc<ChallengeEvent, ChallengeState> {
  ChallengeBloc() : super(const ChallengeInitial()) {
    on<LoadChallenge>(_onLoadChallenge);
    on<UpdateTaskProgress>(_onUpdateTaskProgress);
    on<ClaimReward>(_onClaimReward);
  }

  Future<void> _onLoadChallenge(
    LoadChallenge event,
    Emitter<ChallengeState> emit,
  ) async {
    try {
      var challenge = getCurrentChallenge();

      // CollectionBloc.mockData를 사용하여 초기 진행도 계산
      final collections = CollectionBloc.mockData;
      final updatedTasks = challenge.tasks.map((task) {
        switch (task.type) {
          case ChallengeTaskType.discoverSpecies:
            if (task.targetSpecies != null) {
              final count = collections.where((c) => c.speciesName == task.targetSpecies).length;
              return task.copyWith(currentCount: count.clamp(0, task.targetCount));
            }
            // targetSpecies가 null이면 아무 종이든 카운트
            final count = collections.length;
            return task.copyWith(currentCount: count.clamp(0, task.targetCount));
          case ChallengeTaskType.discoverCategory:
            if (task.targetCategory != null) {
              final count = collections.where((c) => c.speciesCategory == task.targetCategory).length;
              return task.copyWith(currentCount: count.clamp(0, task.targetCount));
            }
            return task;
          case ChallengeTaskType.writeDiary:
          case ChallengeTaskType.quizCorrect:
          case ChallengeTaskType.petCare:
            return task;
        }
      }).toList();

      challenge = challenge.copyWith(tasks: updatedTasks);
      emit(ChallengeLoaded(challenge: challenge));
    } catch (e) {
      emit(ChallengeError(message: e.toString()));
    }
  }

  Future<void> _onUpdateTaskProgress(
    UpdateTaskProgress event,
    Emitter<ChallengeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChallengeLoaded) return;

    final challenge = currentState.challenge;
    if (challenge.isClaimed) return;

    final updatedTasks = challenge.tasks.map((task) {
      if (task.type != event.type) return task;
      if (task.isCompleted) return task;

      // 카테고리/종 필터링
      if (task.type == ChallengeTaskType.discoverCategory &&
          task.targetCategory != null &&
          event.category != task.targetCategory) {
        return task;
      }
      if (task.type == ChallengeTaskType.discoverSpecies &&
          task.targetSpecies != null &&
          event.speciesName != task.targetSpecies) {
        return task;
      }

      return task.copyWith(currentCount: task.currentCount + 1);
    }).toList();

    emit(ChallengeLoaded(
      challenge: challenge.copyWith(tasks: updatedTasks),
    ));
  }

  Future<void> _onClaimReward(
    ClaimReward event,
    Emitter<ChallengeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChallengeLoaded) return;

    final challenge = currentState.challenge;
    if (!challenge.isAllCompleted || challenge.isClaimed) return;

    final claimedChallenge = challenge.copyWith(isClaimed: true);
    emit(ChallengeRewardClaimed(
      challenge: claimedChallenge,
      points: challenge.rewardPoints,
      petExp: challenge.rewardPetExp,
    ));
  }
}
