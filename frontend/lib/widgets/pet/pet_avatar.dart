import 'package:flutter/material.dart';
import '../../config/constants.dart';

class PetAvatar extends StatelessWidget {
  final String petType;
  final String petColor;
  final int? level;
  final double size;

  const PetAvatar({
    super.key,
    required this.petType,
    this.petColor = '#4CAF50',
    this.level,
    this.size = 80,
  });

  Color _parseColor(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final petData = AppConstants.petTypes[petType];
    final emoji = petData?['emoji'] ?? '🌱';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: _parseColor(petColor).withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: _parseColor(petColor).withValues(alpha: 0.4),
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
                color: _parseColor(petColor),
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
}
