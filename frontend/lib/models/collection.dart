import 'package:equatable/equatable.dart';

class CardStats extends Equatable {
  const CardStats({
    required this.hp,
    required this.attack,
    required this.defense,
    required this.speed,
    required this.charm,
    required this.rarityScore,
  });

  final int hp;
  final int attack;
  final int defense;
  final int speed;
  final int charm;
  final int rarityScore;

  /// 모든 전투 스탯(rarityScore 제외)이 100인지
  bool get isMaxed =>
      hp >= 100 && attack >= 100 && defense >= 100 && speed >= 100 && charm >= 100;

  factory CardStats.fromJson(Map<String, dynamic> json) {
    return CardStats(
      hp: json['hp'] as int? ?? 0,
      attack: json['attack'] as int? ?? 0,
      defense: json['defense'] as int? ?? 0,
      speed: json['speed'] as int? ?? 0,
      charm: json['charm'] as int? ?? 0,
      rarityScore: json['rarity_score'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'hp': hp,
    'attack': attack,
    'defense': defense,
    'speed': speed,
    'charm': charm,
    'rarity_score': rarityScore,
  };

  CardStats copyWith({
    int? hp,
    int? attack,
    int? defense,
    int? speed,
    int? charm,
    int? rarityScore,
  }) {
    return CardStats(
      hp: hp ?? this.hp,
      attack: attack ?? this.attack,
      defense: defense ?? this.defense,
      speed: speed ?? this.speed,
      charm: charm ?? this.charm,
      rarityScore: rarityScore ?? this.rarityScore,
    );
  }

  @override
  List<Object?> get props => [hp, attack, defense, speed, charm, rarityScore];
}

class CollectionItem extends Equatable {
  const CollectionItem({
    required this.id,
    required this.cardNumber,
    required this.speciesName,
    required this.speciesCategory,
    required this.stats,
    this.photoUrl,
    this.thumbnailUrl,
    this.locationName,
    this.discoveredAt,
    this.notes,
    this.weather,
  });

  final String id;
  final String cardNumber;
  final String speciesName;
  final String speciesCategory;
  final String? photoUrl;
  final String? thumbnailUrl;
  final CardStats stats;
  final String? locationName;
  final DateTime? discoveredAt;
  final String? notes;
  final String? weather;

  factory CollectionItem.fromJson(Map<String, dynamic> json) {
    return CollectionItem(
      id: json['id'] as String,
      cardNumber: json['card_number'] as String,
      speciesName: json['species_name'] as String? ?? '알 수 없음',
      speciesCategory: json['species_category'] as String? ?? 'unknown',
      photoUrl: json['photo_url'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      stats: CardStats.fromJson(json['stats'] as Map<String, dynamic>? ?? {}),
      locationName: json['location_name'] as String?,
      discoveredAt: json['discovered_at'] != null
          ? DateTime.tryParse(json['discovered_at'] as String)
          : null,
      notes: json['notes'] as String?,
      weather: json['weather'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'card_number': cardNumber,
    'species_name': speciesName,
    'species_category': speciesCategory,
    'photo_url': photoUrl,
    'thumbnail_url': thumbnailUrl,
    'stats': stats.toJson(),
    'location_name': locationName,
    'discovered_at': discoveredAt?.toIso8601String(),
    'notes': notes,
    'weather': weather,
  };

  CollectionItem copyWith({
    String? id,
    String? cardNumber,
    String? speciesName,
    String? speciesCategory,
    String? photoUrl,
    String? thumbnailUrl,
    CardStats? stats,
    String? locationName,
    DateTime? discoveredAt,
    String? notes,
    String? weather,
  }) {
    return CollectionItem(
      id: id ?? this.id,
      cardNumber: cardNumber ?? this.cardNumber,
      speciesName: speciesName ?? this.speciesName,
      speciesCategory: speciesCategory ?? this.speciesCategory,
      photoUrl: photoUrl ?? this.photoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      stats: stats ?? this.stats,
      locationName: locationName ?? this.locationName,
      discoveredAt: discoveredAt ?? this.discoveredAt,
      notes: notes ?? this.notes,
      weather: weather ?? this.weather,
    );
  }

  @override
  List<Object?> get props => [
    id,
    cardNumber,
    speciesName,
    speciesCategory,
    photoUrl,
    thumbnailUrl,
    stats,
    locationName,
    discoveredAt,
    notes,
    weather,
  ];
}
