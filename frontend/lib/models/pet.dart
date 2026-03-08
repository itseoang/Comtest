import 'package:equatable/equatable.dart';

enum PetGrowthStage { egg, baby, juvenile, adult }

enum CareAction { feed, water, play, walk, bath, lullaby }

class Pet extends Equatable {
  const Pet({
    required this.id,
    required this.collectionId,
    required this.speciesName,
    required this.speciesCategory,
    required this.nickname,
    this.level = 1,
    this.exp = 0,
    this.maxExp = 50,
    this.hunger = 80,
    this.thirst = 80,
    this.happiness = 80,
    this.lastFedAt,
    this.lastWateredAt,
    this.lastPlayedAt,
    this.lastWalkedAt,
    this.lastBathedAt,
    this.lastLullabyAt,
  });

  final String id;
  final String collectionId;
  final String speciesName;
  final String speciesCategory;
  final String nickname;
  final int level;
  final int exp;
  final int maxExp;
  final int hunger;    // 0~100
  final int thirst;    // 0~100
  final int happiness; // 0~100

  final DateTime? lastFedAt;
  final DateTime? lastWateredAt;
  final DateTime? lastPlayedAt;
  final DateTime? lastWalkedAt;
  final DateTime? lastBathedAt;
  final DateTime? lastLullabyAt;

  PetGrowthStage get growthStage {
    if (level < 3) return PetGrowthStage.egg;
    if (level < 8) return PetGrowthStage.baby;
    if (level < 15) return PetGrowthStage.juvenile;
    return PetGrowthStage.adult;
  }

  String get stageEmoji {
    switch (speciesCategory) {
      case 'plant':
        switch (growthStage) {
          case PetGrowthStage.egg: return '🌰';
          case PetGrowthStage.baby: return '🌱';
          case PetGrowthStage.juvenile: return '🌿';
          case PetGrowthStage.adult: return '🌸';
        }
      case 'bird':
        switch (growthStage) {
          case PetGrowthStage.egg: return '🥚';
          case PetGrowthStage.baby: return '🐣';
          case PetGrowthStage.juvenile: return '🐦';
          case PetGrowthStage.adult: return '🦅';
        }
      case 'insect':
        switch (growthStage) {
          case PetGrowthStage.egg: return '🟡';
          case PetGrowthStage.baby: return '🐛';
          case PetGrowthStage.juvenile: return '🫎';
          case PetGrowthStage.adult: return '🐞';
        }
      case 'mammal':
        switch (growthStage) {
          case PetGrowthStage.egg: return '🍼';
          case PetGrowthStage.baby: return '🐿️';
          case PetGrowthStage.juvenile: return '🐾';
          case PetGrowthStage.adult: return '🏔️';
        }
      case 'amphibian':
        switch (growthStage) {
          case PetGrowthStage.egg: return '🫧';
          case PetGrowthStage.baby: return '🦎';
          case PetGrowthStage.juvenile: return '🔄';
          case PetGrowthStage.adult: return '🦗';
        }
      default:
        return '🐾';
    }
  }

  String get stageName {
    switch (growthStage) {
      case PetGrowthStage.egg: return '알/씨앗';
      case PetGrowthStage.baby: return '아기';
      case PetGrowthStage.juvenile: return '청소년';
      case PetGrowthStage.adult: return '성체';
    }
  }

  String get moodEmoji {
    final avg = ((hunger + thirst + happiness) / 3).round();
    if (avg >= 70) return '😊';
    if (avg >= 40) return '😐';
    if (avg >= 20) return '😢';
    return '😫';
  }

  String get moodLabel {
    final avg = ((hunger + thirst + happiness) / 3).round();
    if (avg >= 70) return '행복해요';
    if (avg >= 40) return '보통이에요';
    if (avg >= 20) return '슬퍼요';
    return '힘들어요';
  }

  Pet copyWith({
    String? id,
    String? collectionId,
    String? speciesName,
    String? speciesCategory,
    String? nickname,
    int? level,
    int? exp,
    int? maxExp,
    int? hunger,
    int? thirst,
    int? happiness,
    DateTime? lastFedAt,
    DateTime? lastWateredAt,
    DateTime? lastPlayedAt,
    DateTime? lastWalkedAt,
    DateTime? lastBathedAt,
    DateTime? lastLullabyAt,
  }) {
    return Pet(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      speciesName: speciesName ?? this.speciesName,
      speciesCategory: speciesCategory ?? this.speciesCategory,
      nickname: nickname ?? this.nickname,
      level: level ?? this.level,
      exp: exp ?? this.exp,
      maxExp: maxExp ?? this.maxExp,
      hunger: hunger ?? this.hunger,
      thirst: thirst ?? this.thirst,
      happiness: happiness ?? this.happiness,
      lastFedAt: lastFedAt ?? this.lastFedAt,
      lastWateredAt: lastWateredAt ?? this.lastWateredAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      lastWalkedAt: lastWalkedAt ?? this.lastWalkedAt,
      lastBathedAt: lastBathedAt ?? this.lastBathedAt,
      lastLullabyAt: lastLullabyAt ?? this.lastLullabyAt,
    );
  }

  @override
  List<Object?> get props => [
        id, collectionId, speciesName, speciesCategory, nickname,
        level, exp, maxExp, hunger, thirst, happiness,
        lastFedAt, lastWateredAt, lastPlayedAt,
        lastWalkedAt, lastBathedAt, lastLullabyAt,
      ];
}

enum PetActivityType { care, expGain, levelUp, stageChange, miniGame }

class PetActivity extends Equatable {
  const PetActivity({
    required this.id,
    required this.description,
    required this.type,
    required this.timestamp,
    this.icon,
    this.expAmount,
  });

  final String id;
  final String description;
  final PetActivityType type;
  final DateTime timestamp;
  final String? icon;
  final int? expAmount;

  @override
  List<Object?> get props => [id, description, type, timestamp, icon, expAmount];
}
