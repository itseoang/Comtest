import 'dart:math';
import 'package:flutter/material.dart';

enum CreatureNeed {
  water('💧', '물주기', Color(0xFF42A5F5)),
  heart('❤️', '쓰다듬기', Color(0xFFEF5350)),
  food('🍎', '먹이주기', Color(0xFFFF7043)),
  play('🎮', '놀아주기', Color(0xFF7E57C2));

  const CreatureNeed(this.emoji, this.label, this.color);
  final String emoji;
  final String label;
  final Color color;
}

class RanchCreature {
  RanchCreature({
    required this.id,
    required this.speciesName,
    required this.speciesCategory,
    required this.emoji,
    this.discoveredAt,
    this.locationName,
    required this.currentPosition,
    required this.targetPosition,
  });

  final String id;
  final String speciesName;
  final String speciesCategory;
  final String emoji;
  final DateTime? discoveredAt;
  final String? locationName;

  Offset currentPosition;
  Offset targetPosition;
  bool isMoving = false;
  double facingDirection = 1.0; // 1=right, -1=left

  /// Current need requested by this creature (null = no request)
  CreatureNeed? currentNeed;

  /// Whether we already checked/rolled for a need this approach
  bool _needChecked = false;

  /// Roll a random need when player approaches. 60% chance to have a need, 40% nothing.
  void rollNeed(Random random) {
    if (_needChecked) return;
    _needChecked = true;
    if (random.nextDouble() < 0.6) {
      currentNeed = CreatureNeed.values[random.nextInt(CreatureNeed.values.length)];
    } else {
      currentNeed = null;
    }
  }

  /// Fulfill the current need
  void fulfillNeed() {
    currentNeed = null;
  }

  /// Reset need check when player moves away
  void resetNeedCheck() {
    _needChecked = false;
    currentNeed = null;
  }

  /// Category-based movement speed (px per frame)
  double get speed {
    switch (speciesCategory) {
      case 'plant':
        return 0.3;
      case 'bird':
        return 1.5;
      case 'insect':
        return 1.2;
      case 'mammal':
        return 1.0;
      case 'amphibian':
        return 0.7;
      default:
        return 0.8;
    }
  }

  /// Move probability per frame (plant=0.3%, others=1%)
  double get moveProbability {
    return speciesCategory == 'plant' ? 0.003 : 0.01;
  }

  /// Max wander radius (plant stays very close)
  double get wanderRadius {
    switch (speciesCategory) {
      case 'plant':
        return 30.0;
      case 'bird':
        return 200.0;
      case 'insect':
        return 150.0;
      case 'mammal':
        return 180.0;
      case 'amphibian':
        return 100.0;
      default:
        return 120.0;
    }
  }

  /// Pick a new random target within bounds
  void pickNewTarget(Size bounds, Random random) {
    final radius = wanderRadius;
    final dx = (random.nextDouble() - 0.5) * 2 * radius;
    final dy = (random.nextDouble() - 0.5) * 2 * radius;

    final newX = (currentPosition.dx + dx).clamp(30.0, bounds.width - 30.0);
    final newY = (currentPosition.dy + dy).clamp(30.0, bounds.height - 80.0);

    targetPosition = Offset(newX, newY);
    isMoving = true;

    // Update facing direction
    if (targetPosition.dx > currentPosition.dx) {
      facingDirection = 1.0;
    } else if (targetPosition.dx < currentPosition.dx) {
      facingDirection = -1.0;
    }
  }
}
