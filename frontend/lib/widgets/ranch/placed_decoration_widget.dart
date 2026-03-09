import 'package:flutter/material.dart';
import '../../models/ranch_decoration.dart';

class PlacedDecorationWidget extends StatelessWidget {
  const PlacedDecorationWidget({
    super.key,
    required this.decoration,
    this.gridWidth = 1,
    this.gridHeight = 1,
    this.isEditMode = false,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
  });

  final PlacedDecoration decoration;
  final int gridWidth;
  final int gridHeight;
  final bool isEditMode;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final fontSize = gridWidth >= 2 ? 36.0 : 28.0;
    return GestureDetector(
      onTap: isEditMode ? onTap : null,
      onLongPress: isEditMode ? onLongPress : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: isSelected && isEditMode
            ? BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF2E7D32),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white.withValues(alpha: 0.3),
              )
            : null,
        padding: isSelected && isEditMode
            ? const EdgeInsets.all(2)
            : EdgeInsets.zero,
        child: Center(
          child: Text(
            decoration.emoji,
            style: TextStyle(fontSize: fontSize),
          ),
        ),
      ),
    );
  }
}
