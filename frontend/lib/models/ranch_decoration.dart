import 'package:equatable/equatable.dart';

// ---------------------------------------------------------------------------
// Grid constants
// ---------------------------------------------------------------------------

const double kGridCellSize = 48.0;

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

enum DecorationCategory {
  decoration('장식물', '🌿'),
  facility('시설물', '🏠'),
  theme('테마', '🎨');

  const DecorationCategory(this.label, this.emoji);
  final String label;
  final String emoji;
}

enum RanchTheme {
  spring('봄', '🌸'),
  summer('여름', '☀️'),
  fall('가을', '🍂'),
  winter('겨울', '❄️'),
  forest('숲', '🌲'),
  desert('사막', '🏜️'),
  ocean('바다', '🌊');

  const RanchTheme(this.label, this.emoji);
  final String label;
  final String emoji;
}

// ---------------------------------------------------------------------------
// Decoration item definition (catalog entry)
// ---------------------------------------------------------------------------

class DecorationItemDef extends Equatable {
  const DecorationItemDef({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    required this.price,
    this.requiredPetLevel = 0,
    this.requiredCollections = 0,
    this.gridWidth = 1,
    this.gridHeight = 1,
    this.description = '',
  });

  final String id;
  final String name;
  final String emoji;
  final DecorationCategory category;
  final int price; // eco points
  final int requiredPetLevel; // 0 = no requirement
  final int requiredCollections; // 0 = no requirement
  final int gridWidth;
  final int gridHeight;
  final String description;

  @override
  List<Object?> get props => [id];
}

// ---------------------------------------------------------------------------
// Placed decoration (instance in the world)
// ---------------------------------------------------------------------------

class PlacedDecoration extends Equatable {
  const PlacedDecoration({
    required this.instanceId,
    required this.itemId,
    required this.emoji,
    required this.gridX,
    required this.gridY,
  });

  final String instanceId;
  final String itemId;
  final String emoji;
  final int gridX;
  final int gridY;

  double get pixelX => gridX * kGridCellSize;
  double get pixelY => gridY * kGridCellSize;

  PlacedDecoration copyWith({int? gridX, int? gridY}) {
    return PlacedDecoration(
      instanceId: instanceId,
      itemId: itemId,
      emoji: emoji,
      gridX: gridX ?? this.gridX,
      gridY: gridY ?? this.gridY,
    );
  }

  factory PlacedDecoration.fromJson(Map<String, dynamic> json) {
    final int gx;
    final int gy;

    if (!json.containsKey('gridX') && json.containsKey('x')) {
      // 마이그레이션: 구 좌표(double pixel) → 그리드 좌표
      gx = ((json['x'] as num).toDouble() / kGridCellSize).floor();
      gy = ((json['y'] as num).toDouble() / kGridCellSize).floor();
    } else {
      gx = (json['gridX'] as num).toInt();
      gy = (json['gridY'] as num).toInt();
    }

    return PlacedDecoration(
      instanceId: json['instanceId'] as String,
      itemId: json['itemId'] as String,
      emoji: json['emoji'] as String,
      gridX: gx,
      gridY: gy,
    );
  }

  Map<String, dynamic> toJson() => {
        'instanceId': instanceId,
        'itemId': itemId,
        'emoji': emoji,
        'gridX': gridX,
        'gridY': gridY,
      };

  @override
  List<Object?> get props => [instanceId, itemId, gridX, gridY];
}
