import 'dart:math';

import '../models/collection.dart';

class StatsBoostResult {
  const StatsBoostResult({
    required this.beforeStats,
    required this.afterStats,
    required this.boostAmounts,
  });

  final CardStats beforeStats;
  final CardStats afterStats;
  final Map<String, int> boostAmounts;
}

class StatsCalculator {
  static final _random = Random();

  /// 10~30% 랜덤 boost 계산. 최소 1 보장, 최대 100 캡.
  /// rarityScore는 상승하지 않음.
  static StatsBoostResult calculateBoost(CardStats current) {
    int boostStat(int value) {
      if (value >= 100) return 0;
      final minBoost = (value * 0.10).ceil().clamp(1, 100 - value);
      final maxBoost = (value * 0.30).ceil().clamp(minBoost, 100 - value);
      return minBoost + _random.nextInt(maxBoost - minBoost + 1);
    }

    final hpBoost = boostStat(current.hp);
    final attackBoost = boostStat(current.attack);
    final defenseBoost = boostStat(current.defense);
    final speedBoost = boostStat(current.speed);
    final charmBoost = boostStat(current.charm);

    final afterStats = CardStats(
      hp: (current.hp + hpBoost).clamp(0, 100),
      attack: (current.attack + attackBoost).clamp(0, 100),
      defense: (current.defense + defenseBoost).clamp(0, 100),
      speed: (current.speed + speedBoost).clamp(0, 100),
      charm: (current.charm + charmBoost).clamp(0, 100),
      rarityScore: current.rarityScore,
    );

    return StatsBoostResult(
      beforeStats: current,
      afterStats: afterStats,
      boostAmounts: {
        'hp': hpBoost,
        'attack': attackBoost,
        'defense': defenseBoost,
        'speed': speedBoost,
        'charm': charmBoost,
      },
    );
  }

  /// 최대 boost 미리보기 (+30% 기준)
  static CardStats getMaxBoostStats(CardStats current) {
    int maxBoosted(int value) {
      if (value >= 100) return value;
      final boost = (value * 0.30).ceil().clamp(1, 100 - value);
      return (value + boost).clamp(0, 100);
    }

    return CardStats(
      hp: maxBoosted(current.hp),
      attack: maxBoosted(current.attack),
      defense: maxBoosted(current.defense),
      speed: maxBoosted(current.speed),
      charm: maxBoosted(current.charm),
      rarityScore: current.rarityScore,
    );
  }
}
