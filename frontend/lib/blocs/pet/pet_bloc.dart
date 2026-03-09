import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../config/constants.dart';
import '../../models/pet.dart';

// Events
abstract class PetEvent extends Equatable {
  const PetEvent();
  @override
  List<Object?> get props => [];
}

class LoadPet extends PetEvent {
  const LoadPet();
}

class SelectPetFromCollection extends PetEvent {
  const SelectPetFromCollection({
    required this.collectionId,
    required this.speciesName,
    required this.speciesCategory,
    required this.nickname,
  });
  final String collectionId;
  final String speciesName;
  final String speciesCategory;
  final String nickname;
  @override
  List<Object?> get props => [collectionId, speciesName, speciesCategory, nickname];
}

class PerformCareAction extends PetEvent {
  const PerformCareAction({required this.action});
  final CareAction action;
  @override
  List<Object?> get props => [action];
}

class AddPetExp extends PetEvent {
  const AddPetExp({required this.exp, required this.source});
  final int exp;
  final String source;
  @override
  List<Object?> get props => [exp, source];
}

class UpdatePetGauges extends PetEvent {
  const UpdatePetGauges();
}

class PerformMiniGameTap extends PetEvent {
  const PerformMiniGameTap();
}

class ResetMiniGameSession extends PetEvent {
  const ResetMiniGameSession();
}

// States
abstract class PetState extends Equatable {
  const PetState();
  @override
  List<Object?> get props => [];
}

class PetInitial extends PetState {
  const PetInitial();
}

class PetNone extends PetState {
  const PetNone();
}

class PetLoaded extends PetState {
  const PetLoaded({
    required this.pet,
    this.canFeed = true,
    this.canWater = true,
    this.canPlay = true,
    this.canWalk = true,
    this.canBath = true,
    this.canLullaby = true,
    this.activities = const [],
    this.miniGameTapsRemaining = 20,
  });
  final Pet pet;
  final bool canFeed;
  final bool canWater;
  final bool canPlay;
  final bool canWalk;
  final bool canBath;
  final bool canLullaby;
  final List<PetActivity> activities;
  final int miniGameTapsRemaining;
  @override
  List<Object?> get props => [pet, canFeed, canWater, canPlay, canWalk, canBath, canLullaby, activities, miniGameTapsRemaining];
}

class PetLevelUp extends PetState {
  const PetLevelUp({
    required this.pet,
    required this.previousLevel,
    this.newStage,
  });
  final Pet pet;
  final int previousLevel;
  final PetGrowthStage? newStage;
  @override
  List<Object?> get props => [pet, previousLevel, newStage];
}

class PetError extends PetState {
  const PetError({required this.message});
  final String message;
  @override
  List<Object?> get props => [message];
}

// BLoC
class PetBloc extends Bloc<PetEvent, PetState> {
  PetBloc() : super(const PetInitial()) {
    on<LoadPet>(_onLoadPet);
    on<SelectPetFromCollection>(_onSelectPet);
    on<PerformCareAction>(_onPerformCare);
    on<AddPetExp>(_onAddExp);
    on<UpdatePetGauges>(_onUpdateGauges);
    on<PerformMiniGameTap>(_onMiniGameTap);
    on<ResetMiniGameSession>(_onResetMiniGame);
  }

  Pet? _currentPet;
  final List<PetActivity> _activities = [];
  int _miniGameTapsRemaining = PetConstants.miniGameMaxTapsPerSession;

  Future<void> _onLoadPet(LoadPet event, Emitter<PetState> emit) async {
    if (_currentPet != null) {
      _applyGaugeDecay();
      emit(_buildLoadedState());
    } else {
      emit(const PetNone());
    }
  }

  Future<void> _onSelectPet(SelectPetFromCollection event, Emitter<PetState> emit) async {
    _currentPet = Pet(
      id: 'pet-${DateTime.now().millisecondsSinceEpoch}',
      collectionId: event.collectionId,
      speciesName: event.speciesName,
      speciesCategory: event.speciesCategory,
      nickname: event.nickname,
      // 처음 선택 시 돌봄 즉시 가능하도록 null로 설정

    );
    _activities.clear();
    _miniGameTapsRemaining = PetConstants.miniGameMaxTapsPerSession;
    _addActivity('${event.nickname}을(를) 입양했어요!', PetActivityType.care, icon: '🎉');
    emit(_buildLoadedState());
  }

  Future<void> _onPerformCare(PerformCareAction event, Emitter<PetState> emit) async {
    if (_currentPet == null) return;

    final now = DateTime.now();
    const cooldown = Duration(minutes: PetConstants.careCooldownMinutes);

    switch (event.action) {
      case CareAction.feed:
        if (_currentPet!.lastFedAt != null &&
            now.difference(_currentPet!.lastFedAt!) < cooldown) { return; }
        _currentPet = _currentPet!.copyWith(
          hunger: (_currentPet!.hunger + PetConstants.careGaugeRestore).clamp(0, 100),
          lastFedAt: now,
        );
        _addActivity('밥을 먹었어요!', PetActivityType.care, icon: '🍽️', expAmount: PetConstants.careExp);
      case CareAction.water:
        if (_currentPet!.lastWateredAt != null &&
            now.difference(_currentPet!.lastWateredAt!) < cooldown) { return; }
        _currentPet = _currentPet!.copyWith(
          thirst: (_currentPet!.thirst + PetConstants.careGaugeRestore).clamp(0, 100),
          lastWateredAt: now,
        );
        _addActivity('물을 마셨어요!', PetActivityType.care, icon: '💧', expAmount: PetConstants.careExp);
      case CareAction.play:
        if (_currentPet!.lastPlayedAt != null &&
            now.difference(_currentPet!.lastPlayedAt!) < cooldown) { return; }
        _currentPet = _currentPet!.copyWith(
          happiness: (_currentPet!.happiness + PetConstants.careGaugeRestore).clamp(0, 100),
          lastPlayedAt: now,
        );
        _addActivity('놀아줬어요!', PetActivityType.care, icon: '🎮', expAmount: PetConstants.careExp);
      case CareAction.walk:
        if (_currentPet!.lastWalkedAt != null &&
            now.difference(_currentPet!.lastWalkedAt!) < cooldown) { return; }
        _currentPet = _currentPet!.copyWith(
          happiness: (_currentPet!.happiness + PetConstants.walkHappinessRestore).clamp(0, 100),
          lastWalkedAt: now,
        );
        _addActivity('산책을 다녀왔어요!', PetActivityType.care, icon: '🚶', expAmount: PetConstants.walkExp);
        _addExpInternal(PetConstants.walkExp, emit);
        return;
      case CareAction.bath:
        if (_currentPet!.lastBathedAt != null &&
            now.difference(_currentPet!.lastBathedAt!) < cooldown) { return; }
        _currentPet = _currentPet!.copyWith(
          happiness: (_currentPet!.happiness + PetConstants.bathHappinessRestore).clamp(0, 100),
          lastBathedAt: now,
        );
        _addActivity('목욕을 했어요!', PetActivityType.care, icon: '🛁', expAmount: PetConstants.bathExp);
        _addExpInternal(PetConstants.bathExp, emit);
        return;
      case CareAction.lullaby:
        if (_currentPet!.lastLullabyAt != null &&
            now.difference(_currentPet!.lastLullabyAt!) < cooldown) { return; }
        _currentPet = _currentPet!.copyWith(
          happiness: (_currentPet!.happiness + PetConstants.lullabyHappinessRestore).clamp(0, 100),
          lastLullabyAt: now,
        );
        _addActivity('자장가를 불러줬어요!', PetActivityType.care, icon: '🎵', expAmount: PetConstants.lullabyExp);
        _addExpInternal(PetConstants.lullabyExp, emit);
        return;
    }

    // 돌봄 경험치 (feed, water, play)
    _addExpInternal(PetConstants.careExp, emit);
  }

  Future<void> _onAddExp(AddPetExp event, Emitter<PetState> emit) async {
    if (_currentPet == null) return;
    _addExpInternal(event.exp, emit);
  }

  void _addExpInternal(int expToAdd, Emitter<PetState> emit) {
    if (_currentPet == null) return;

    final previousLevel = _currentPet!.level;
    final previousStage = _currentPet!.growthStage;
    var newExp = _currentPet!.exp + expToAdd;
    var newLevel = _currentPet!.level;
    var newMaxExp = _currentPet!.maxExp;

    while (newExp >= newMaxExp) {
      newExp -= newMaxExp;
      newLevel++;
      newMaxExp = PetConstants.expForLevel(newLevel);
    }

    _currentPet = _currentPet!.copyWith(
      level: newLevel,
      exp: newExp,
      maxExp: newMaxExp,
    );

    if (newLevel > previousLevel) {
      final newStage = _currentPet!.growthStage;
      _addActivity('레벨 $newLevel로 성장했어요!', PetActivityType.levelUp, icon: '⬆️');
      if (newStage != previousStage) {
        _addActivity('${_currentPet!.stageName} 단계로 진화했어요!', PetActivityType.stageChange, icon: '✨');
      }
      emit(PetLevelUp(
        pet: _currentPet!,
        previousLevel: previousLevel,
        newStage: newStage != previousStage ? newStage : null,
      ));
      // 바로 뒤에 PetLoaded도 emit
      Future.microtask(() => add(const UpdatePetGauges()));
    } else {
      emit(_buildLoadedState());
    }
  }

  Future<void> _onUpdateGauges(UpdatePetGauges event, Emitter<PetState> emit) async {
    if (_currentPet == null) {
      emit(const PetNone());
      return;
    }
    _applyGaugeDecay();
    emit(_buildLoadedState());
  }

  void _applyGaugeDecay() {
    if (_currentPet == null) return;
    final now = DateTime.now();

    int decayFor(DateTime? lastAction) {
      if (lastAction == null) return 0;
      final minutes = now.difference(lastAction).inMinutes;
      return (minutes * PetConstants.gaugeDecayPerMinute).round();
    }

    _currentPet = _currentPet!.copyWith(
      hunger: (_currentPet!.hunger - decayFor(_currentPet!.lastFedAt)).clamp(0, 100),
      thirst: (_currentPet!.thirst - decayFor(_currentPet!.lastWateredAt)).clamp(0, 100),
      happiness: (_currentPet!.happiness - decayFor(_currentPet!.lastPlayedAt)).clamp(0, 100),
    );
  }

  void _addActivity(String description, PetActivityType type, {String? icon, int? expAmount}) {
    _activities.insert(0, PetActivity(
      id: 'act-${DateTime.now().millisecondsSinceEpoch}',
      description: description,
      type: type,
      timestamp: DateTime.now(),
      icon: icon,
      expAmount: expAmount,
    ));
    if (_activities.length > PetConstants.maxActivityLogSize) {
      _activities.removeLast();
    }
  }

  Future<void> _onMiniGameTap(PerformMiniGameTap event, Emitter<PetState> emit) async {
    if (_currentPet == null || _miniGameTapsRemaining <= 0) return;

    _miniGameTapsRemaining--;
    _currentPet = _currentPet!.copyWith(
      happiness: (_currentPet!.happiness + 2).clamp(0, 100),
    );
    _addActivity('쓰다듬어줬어요!', PetActivityType.miniGame, icon: '💕', expAmount: PetConstants.miniGameTapExp);
    _addExpInternal(PetConstants.miniGameTapExp, emit);
  }

  Future<void> _onResetMiniGame(ResetMiniGameSession event, Emitter<PetState> emit) async {
    _miniGameTapsRemaining = PetConstants.miniGameMaxTapsPerSession;
    if (_currentPet != null) {
      emit(_buildLoadedState());
    }
  }

  PetLoaded _buildLoadedState() {
    final now = DateTime.now();
    const cooldown = Duration(minutes: PetConstants.careCooldownMinutes);
    return PetLoaded(
      pet: _currentPet!,
      canFeed: _currentPet!.lastFedAt == null ||
          now.difference(_currentPet!.lastFedAt!) >= cooldown,
      canWater: _currentPet!.lastWateredAt == null ||
          now.difference(_currentPet!.lastWateredAt!) >= cooldown,
      canPlay: _currentPet!.lastPlayedAt == null ||
          now.difference(_currentPet!.lastPlayedAt!) >= cooldown,
      canWalk: _currentPet!.lastWalkedAt == null ||
          now.difference(_currentPet!.lastWalkedAt!) >= cooldown,
      canBath: _currentPet!.lastBathedAt == null ||
          now.difference(_currentPet!.lastBathedAt!) >= cooldown,
      canLullaby: _currentPet!.lastLullabyAt == null ||
          now.difference(_currentPet!.lastLullabyAt!) >= cooldown,
      activities: List.unmodifiable(_activities),
      miniGameTapsRemaining: _miniGameTapsRemaining,
    );
  }
}
