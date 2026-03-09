import 'package:flutter/material.dart';
import '../../models/ranch_creature.dart';

class CreatureInfoPopup extends StatelessWidget {
  const CreatureInfoPopup({super.key, required this.creature});

  final RanchCreature creature;

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

  String _categoryLabel() {
    switch (creature.speciesCategory) {
      case 'plant': return '식물';
      case 'bird': return '조류';
      case 'insect': return '곤충';
      case 'mammal': return '포유류';
      case 'amphibian': return '양서류';
      default: return '기타';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor();
    final dateStr = creature.discoveredAt != null
        ? '${creature.discoveredAt!.year}.${creature.discoveredAt!.month}.${creature.discoveredAt!.day}'
        : '알 수 없음';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Big emoji
            Text(creature.emoji, style: const TextStyle(fontSize: 72)),
            const SizedBox(height: 12),
            // Species name
            Text(
              creature.speciesName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2723),
              ),
            ),
            const SizedBox(height: 8),
            // Category chip
            Chip(
              label: Text(
                _categoryLabel(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              backgroundColor: color,
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(height: 16),
            // Discovered date
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Color(0xFF757575)),
                const SizedBox(width: 4),
                Text(
                  '발견일: $dateStr',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF757575)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Location
            if (creature.locationName != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.place, size: 14, color: Color(0xFF757575)),
                  const SizedBox(width: 4),
                  Text(
                    creature.locationName!,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF757575)),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('닫기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
