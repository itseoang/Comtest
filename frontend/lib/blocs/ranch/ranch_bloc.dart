import 'dart:math';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../models/collection.dart';
import '../../models/ranch_creature.dart';
import '../../models/ranch_decoration.dart';
import '../../data/ranch_decoration_catalog.dart';
import '../../services/ranch_storage_service.dart';

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

abstract class RanchEvent extends Equatable {
  const RanchEvent();

  @override
  List<Object?> get props => [];
}

class InitializeRanch extends RanchEvent {
  const InitializeRanch({required this.collections, required this.bounds});

  final List<CollectionItem> collections;
  final Size bounds;

  @override
  List<Object?> get props => [collections, bounds];
}

class FeedAllCreatures extends RanchEvent {
  const FeedAllCreatures();
}

class FeedingAnimationComplete extends RanchEvent {
  const FeedingAnimationComplete();
}

class LoadRanchDecorations extends RanchEvent {
  const LoadRanchDecorations({required this.bounds});
  final Size bounds;

  @override
  List<Object?> get props => [bounds];
}

class PurchaseDecorationItem extends RanchEvent {
  const PurchaseDecorationItem({required this.itemId});
  final String itemId;

  @override
  List<Object?> get props => [itemId];
}

class ToggleEditMode extends RanchEvent {
  const ToggleEditMode();
}

class PlaceDecoration extends RanchEvent {
  const PlaceDecoration({required this.itemId, required this.gridX, required this.gridY});
  final String itemId;
  final int gridX;
  final int gridY;

  @override
  List<Object?> get props => [itemId, gridX, gridY];
}

class MoveDecoration extends RanchEvent {
  const MoveDecoration({required this.instanceId, required this.gridX, required this.gridY});
  final String instanceId;
  final int gridX;
  final int gridY;

  @override
  List<Object?> get props => [instanceId, gridX, gridY];
}

class RemoveDecoration extends RanchEvent {
  const RemoveDecoration({required this.instanceId});
  final String instanceId;

  @override
  List<Object?> get props => [instanceId];
}

class SaveDecorations extends RanchEvent {
  const SaveDecorations();
}

class ChangeTheme extends RanchEvent {
  const ChangeTheme({required this.themeId});
  final String themeId;

  @override
  List<Object?> get props => [themeId];
}

class SelectInventoryItem extends RanchEvent {
  const SelectInventoryItem({this.itemId});
  final String? itemId;

  @override
  List<Object?> get props => [itemId];
}

// ---------------------------------------------------------------------------
// States
// ---------------------------------------------------------------------------

abstract class RanchState extends Equatable {
  const RanchState();

  @override
  List<Object?> get props => [];
}

class RanchInitial extends RanchState {
  const RanchInitial();
}

class RanchReady extends RanchState {
  const RanchReady({
    required this.creatures,
    this.isFeeding = false,
    this.isEditMode = false,
    this.placedDecorations = const [],
    this.ownedItemIds = const {},
    this.activeThemeId = 'theme_summer',
    this.selectedItemId,
  });

  final List<RanchCreature> creatures;
  final bool isFeeding;
  final bool isEditMode;
  final List<PlacedDecoration> placedDecorations;
  final Set<String> ownedItemIds;
  final String activeThemeId;
  final String? selectedItemId;

  RanchReady copyWith({
    List<RanchCreature>? creatures,
    bool? isFeeding,
    bool? isEditMode,
    List<PlacedDecoration>? placedDecorations,
    Set<String>? ownedItemIds,
    String? activeThemeId,
    String? Function()? selectedItemId,
  }) {
    return RanchReady(
      creatures: creatures ?? this.creatures,
      isFeeding: isFeeding ?? this.isFeeding,
      isEditMode: isEditMode ?? this.isEditMode,
      placedDecorations: placedDecorations ?? this.placedDecorations,
      ownedItemIds: ownedItemIds ?? this.ownedItemIds,
      activeThemeId: activeThemeId ?? this.activeThemeId,
      selectedItemId: selectedItemId != null ? selectedItemId() : this.selectedItemId,
    );
  }

  @override
  List<Object?> get props => [
        creatures,
        isFeeding,
        isEditMode,
        placedDecorations,
        ownedItemIds,
        activeThemeId,
        selectedItemId,
      ];
}

// ---------------------------------------------------------------------------
// BLoC
// ---------------------------------------------------------------------------

class RanchBloc extends Bloc<RanchEvent, RanchState> {
  RanchBloc() : super(const RanchInitial()) {
    on<InitializeRanch>(_onInitialize);
    on<FeedAllCreatures>(_onFeedAll);
    on<FeedingAnimationComplete>(_onFeedingComplete);
    on<LoadRanchDecorations>(_onLoadDecorations);
    on<PurchaseDecorationItem>(_onPurchase);
    on<ToggleEditMode>(_onToggleEditMode);
    on<PlaceDecoration>(_onPlace);
    on<MoveDecoration>(_onMove);
    on<RemoveDecoration>(_onRemove);
    on<SaveDecorations>(_onSave);
    on<ChangeTheme>(_onChangeTheme);
    on<SelectInventoryItem>(_onSelectInventory);
  }

  static const Map<String, String> _emojiMap = {
    '진달래': '🌸',
    '청딱따구리': '🐦',
    '무당벌레': '🐞',
    '다람쥐': '🐿️',
    '도롱뇽': '🦎',
    '은행나무': '🌳',
  };

  static String _getEmoji(String speciesName) {
    return _emojiMap[speciesName] ?? '🌿';
  }

  // ── Default decorations (same seed=42 as original _generateDecorations) ──

  static List<PlacedDecoration> _generateDefaultDecorations(Size bounds) {
    final random = Random(42);
    final decorations = <PlacedDecoration>[];
    final occupied = <String>{};
    int counter = 0;

    final gridW = (bounds.width / 48.0).floor();
    final gridH = (bounds.height / 48.0).floor();

    PlacedDecoration? tryPlace(String itemId, String emoji, int attempts) {
      for (int a = 0; a < attempts; a++) {
        final gx = 1 + random.nextInt(gridW - 2);
        final gy = 1 + random.nextInt(gridH - 2);
        final key = '$gx,$gy';
        if (!occupied.contains(key)) {
          occupied.add(key);
          return PlacedDecoration(
            instanceId: 'default_${counter++}',
            itemId: itemId,
            emoji: emoji,
            gridX: gx,
            gridY: gy,
          );
        }
      }
      return null;
    }

    // 25 trees
    for (int i = 0; i < 25; i++) {
      final emojis = ['🌲', '🌳', '🌴'];
      final d = tryPlace('deco_pine', emojis[random.nextInt(3)], 20);
      if (d != null) decorations.add(d);
    }

    // 18 flowers
    for (int i = 0; i < 18; i++) {
      final emojis = ['🌻', '🌼', '🌸', '🌺', '🌾'];
      final d = tryPlace('deco_sunflower', emojis[random.nextInt(5)], 20);
      if (d != null) decorations.add(d);
    }

    // 10 rocks
    for (int i = 0; i < 10; i++) {
      final d = tryPlace('deco_rock', '🪨', 20);
      if (d != null) decorations.add(d);
    }

    return decorations;
  }

  // ── Free items that are owned by default ──

  static Set<String> _defaultOwnedIds() {
    return kDecorationCatalog
        .where((d) => d.price == 0)
        .map((d) => d.id)
        .toSet();
  }

  // ── Handlers ──

  void _onInitialize(InitializeRanch event, Emitter<RanchState> emit) {
    final random = Random();
    final creatures = event.collections.map((item) {
      final x = 30.0 + random.nextDouble() * (event.bounds.width - 60);
      final y = 30.0 + random.nextDouble() * (event.bounds.height - 110);
      final pos = Offset(x, y);
      return RanchCreature(
        id: item.id,
        speciesName: item.speciesName,
        speciesCategory: item.speciesCategory,
        emoji: _getEmoji(item.speciesName),
        discoveredAt: item.discoveredAt,
        locationName: item.locationName,
        currentPosition: pos,
        targetPosition: pos,
      );
    }).toList();

    // Preserve decoration state if already loaded
    if (state is RanchReady) {
      final current = state as RanchReady;
      emit(current.copyWith(creatures: creatures));
    } else {
      emit(RanchReady(creatures: creatures));
    }
  }

  Future<void> _onLoadDecorations(
      LoadRanchDecorations event, Emitter<RanchState> emit) async {
    final saved = await RanchStorageService.load();
    final current = state;

    if (saved != null) {
      final ownedIds = _defaultOwnedIds()..addAll(saved.ownedItemIds);
      if (current is RanchReady) {
        emit(current.copyWith(
          placedDecorations: saved.placedDecorations,
          ownedItemIds: ownedIds,
          activeThemeId: saved.activeThemeId,
        ));
      } else {
        emit(RanchReady(
          creatures: const [],
          placedDecorations: saved.placedDecorations,
          ownedItemIds: ownedIds,
          activeThemeId: saved.activeThemeId,
        ));
      }
    } else {
      // First launch – generate defaults
      final defaults = _generateDefaultDecorations(event.bounds);
      final ownedIds = _defaultOwnedIds();
      if (current is RanchReady) {
        emit(current.copyWith(
          placedDecorations: defaults,
          ownedItemIds: ownedIds,
        ));
      } else {
        emit(RanchReady(
          creatures: const [],
          placedDecorations: defaults,
          ownedItemIds: ownedIds,
        ));
      }
    }
  }

  void _onPurchase(PurchaseDecorationItem event, Emitter<RanchState> emit) {
    if (state is! RanchReady) return;
    final current = state as RanchReady;
    final newOwned = Set<String>.from(current.ownedItemIds)..add(event.itemId);
    emit(current.copyWith(ownedItemIds: newOwned));
  }

  void _onToggleEditMode(ToggleEditMode event, Emitter<RanchState> emit) {
    if (state is! RanchReady) return;
    final current = state as RanchReady;
    emit(current.copyWith(
      isEditMode: !current.isEditMode,
      selectedItemId: () => null,
    ));
  }

  Set<String> _getOccupiedCells(List<PlacedDecoration> decorations) {
    final cells = <String>{};
    for (final d in decorations) {
      final def = findDecorationById(d.itemId);
      final w = def?.gridWidth ?? 1;
      final h = def?.gridHeight ?? 1;
      for (int dx = 0; dx < w; dx++) {
        for (int dy = 0; dy < h; dy++) {
          cells.add('${d.gridX + dx},${d.gridY + dy}');
        }
      }
    }
    return cells;
  }

  bool _canPlace(int gridX, int gridY, int w, int h, Set<String> occupied) {
    for (int dx = 0; dx < w; dx++) {
      for (int dy = 0; dy < h; dy++) {
        if (occupied.contains('${gridX + dx},${gridY + dy}')) return false;
      }
    }
    return true;
  }

  void _onPlace(PlaceDecoration event, Emitter<RanchState> emit) {
    if (state is! RanchReady) return;
    final current = state as RanchReady;
    final def = findDecorationById(event.itemId);
    if (def == null) return;

    final occupied = _getOccupiedCells(current.placedDecorations);
    final w = def.gridWidth;
    final h = def.gridHeight;
    if (!_canPlace(event.gridX, event.gridY, w, h, occupied)) return;

    final instance = PlacedDecoration(
      instanceId: 'placed_${DateTime.now().millisecondsSinceEpoch}',
      itemId: event.itemId,
      emoji: def.emoji,
      gridX: event.gridX,
      gridY: event.gridY,
    );

    emit(current.copyWith(
      placedDecorations: [...current.placedDecorations, instance],
    ));
  }

  void _onMove(MoveDecoration event, Emitter<RanchState> emit) {
    if (state is! RanchReady) return;
    final current = state as RanchReady;

    final moving = current.placedDecorations.firstWhere(
      (d) => d.instanceId == event.instanceId,
      orElse: () => current.placedDecorations.first,
    );
    final def = findDecorationById(moving.itemId);
    final w = def?.gridWidth ?? 1;
    final h = def?.gridHeight ?? 1;

    // Check occupancy excluding the moving decoration
    final others = current.placedDecorations.where((d) => d.instanceId != event.instanceId).toList();
    final occupied = _getOccupiedCells(others);
    if (!_canPlace(event.gridX, event.gridY, w, h, occupied)) return;

    final updated = current.placedDecorations.map((d) {
      if (d.instanceId == event.instanceId) {
        return d.copyWith(gridX: event.gridX, gridY: event.gridY);
      }
      return d;
    }).toList();
    emit(current.copyWith(placedDecorations: updated));
  }

  void _onRemove(RemoveDecoration event, Emitter<RanchState> emit) {
    if (state is! RanchReady) return;
    final current = state as RanchReady;
    final updated = current.placedDecorations
        .where((d) => d.instanceId != event.instanceId)
        .toList();
    emit(current.copyWith(placedDecorations: updated));
  }

  Future<void> _onSave(SaveDecorations event, Emitter<RanchState> emit) async {
    if (state is! RanchReady) return;
    final current = state as RanchReady;
    await RanchStorageService.save(
      decorations: current.placedDecorations,
      ownedItemIds: current.ownedItemIds,
      activeThemeId: current.activeThemeId,
    );
  }

  void _onChangeTheme(ChangeTheme event, Emitter<RanchState> emit) {
    if (state is! RanchReady) return;
    final current = state as RanchReady;
    emit(current.copyWith(activeThemeId: event.themeId));
  }

  void _onSelectInventory(SelectInventoryItem event, Emitter<RanchState> emit) {
    if (state is! RanchReady) return;
    final current = state as RanchReady;
    emit(current.copyWith(selectedItemId: () => event.itemId));
  }

  void _onFeedAll(FeedAllCreatures event, Emitter<RanchState> emit) {
    if (state is RanchReady) {
      final current = state as RanchReady;
      emit(current.copyWith(isFeeding: true));
    }
  }

  void _onFeedingComplete(
      FeedingAnimationComplete event, Emitter<RanchState> emit) {
    if (state is RanchReady) {
      final current = state as RanchReady;
      emit(current.copyWith(isFeeding: false));
    }
  }
}
