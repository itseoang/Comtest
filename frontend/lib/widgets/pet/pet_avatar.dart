import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../models/pet.dart';

class PetAvatar extends StatelessWidget {
  final String? petType;
  final String? petColor;
  final int? level;
  final double size;
  final Pet? pet;

  const PetAvatar({
    super.key,
    this.petType,
    this.petColor,
    this.level,
    this.size = 80,
    this.pet,
  });

  const PetAvatar.fromPet({
    super.key,
    required Pet this.pet,
    this.size = 80,
  })  : petType = null,
        petColor = null,
        level = null;

  Color _parseColor(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    // Pet 모델 기반
    if (pet != null) {
      return _buildPetModelAvatar();
    }
    // 레거시: petType 기반
    return _buildLegacyAvatar();
  }

  Widget _buildPetModelAvatar() {
    final p = pet!;
    final color = _categoryColor(p.speciesCategory);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withValues(alpha: 0.4),
              width: 2.5,
            ),
          ),
          child: Center(
            child: Text(
              p.stageEmoji,
              style: TextStyle(fontSize: size * 0.45),
            ),
          ),
        ),
        Positioned(
          bottom: -2,
          right: -2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: Text(
              'Lv.${p.level}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegacyAvatar() {
    final petData = AppConstants.petTypes[petType];
    final emoji = petData?['emoji'] ?? '🌱';
    final colorStr = petColor ?? '#4CAF50';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: _parseColor(colorStr).withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: _parseColor(colorStr).withValues(alpha: 0.4),
              width: 2.5,
            ),
          ),
          child: Center(
            child: Text(
              emoji,
              style: TextStyle(fontSize: size * 0.5),
            ),
          ),
        ),
        if (level != null)
          Positioned(
            bottom: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _parseColor(colorStr),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Text(
                'Lv.$level',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'plant': return const Color(0xFF4CAF50);
      case 'bird': return const Color(0xFF2196F3);
      case 'insect': return const Color(0xFFFF9800);
      case 'mammal': return const Color(0xFF795548);
      case 'amphibian': return const Color(0xFF009688);
      default: return const Color(0xFF9E9E9E);
    }
  }
}
