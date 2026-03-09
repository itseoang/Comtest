import 'package:flutter/material.dart';
import '../../models/ranch_creature.dart';

class RanchCreatureWidget extends StatelessWidget {
  const RanchCreatureWidget({
    super.key,
    required this.creature,
    required this.onTap,
    this.showHeart = false,
  });

  final RanchCreature creature;
  final VoidCallback onTap;
  final bool showHeart;

  Color _categoryColor() {
    switch (creature.speciesCategory) {
      case 'plant': return const Color(0xFF4CAF50);
      case 'bird': return const Color(0xFF2196F3);
      case 'insect': return const Color(0xFFFF9800);
      case 'mammal': return const Color(0xFF795548);
      case 'amphibian': return const Color(0xFF009688);
      default: return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor();

    return GestureDetector(
      onTap: onTap,
      child: Transform.scale(
        scaleX: creature.facingDirection,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Heart (shown during feeding)
            if (showHeart)
              const Text('❤️', style: TextStyle(fontSize: 16)),
            // Creature circle with emoji
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Transform.scale(
                  scaleX: creature.facingDirection, // undo parent flip for emoji
                  child: Text(
                    creature.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            // Name label
            Transform.scale(
              scaleX: creature.facingDirection, // undo parent flip for text
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  creature.speciesName,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3E2723),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
