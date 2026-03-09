import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/collection/collection_bloc.dart';
import '../../blocs/ranch/ranch_bloc.dart';
import '../../models/ranch_creature.dart';
import '../../models/ranch_decoration.dart';
import '../../widgets/ranch/ranch_background.dart';
import '../../widgets/ranch/ranch_creature_widget.dart';
import '../../widgets/ranch/creature_info_popup.dart';
import '../../widgets/ranch/heart_effect_overlay.dart';
import '../../widgets/ranch/virtual_joystick.dart';
import '../../widgets/ranch/placed_decoration_widget.dart';
import '../../widgets/ranch/edit_mode_toolbar.dart';
import '../../data/ranch_decoration_catalog.dart';
import 'ranch_shop_screen.dart';

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class RanchScreen extends StatefulWidget {
  const RanchScreen({super.key});

  @override
  State<RanchScreen> createState() => _RanchScreenState();
}

class _RanchScreenState extends State<RanchScreen>
    with SingleTickerProviderStateMixin {
  // Constants
  static const double _worldMultiplier = 3.0;
  static const double _playerSpeed = 3.0;
  static const double _interactionRadius = 80.0;

  late final RanchBloc _ranchBloc;
  late final Ticker _ticker;
  final Random _random = Random();

  bool _initialized = false;

  Size _worldSize = Size.zero;
  Size _screenSize = Size.zero;
  Offset _playerPosition = Offset.zero;
  Offset _cameraOffset = Offset.zero;
  Offset _joystickDirection = Offset.zero;

  @override
  void initState() {
    super.initState();
    _ranchBloc = RanchBloc();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _ranchBloc.close();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // World initialization
  // ---------------------------------------------------------------------------

  void _initializeWorld(Size screenSize) {
    _screenSize = screenSize;
    _worldSize = Size(
      screenSize.width * _worldMultiplier,
      screenSize.height * _worldMultiplier,
    );
    _playerPosition = Offset(_worldSize.width / 2, _worldSize.height / 2);
    _updateCamera();
  }

  // ---------------------------------------------------------------------------
  // Camera
  // ---------------------------------------------------------------------------

  void _updateCamera() {
    if (_screenSize == Size.zero) return;
    _cameraOffset = Offset(
      (_playerPosition.dx - _screenSize.width / 2)
          .clamp(0, _worldSize.width - _screenSize.width),
      (_playerPosition.dy - _screenSize.height / 2)
          .clamp(0, _worldSize.height - _screenSize.height),
    );
  }

  // ---------------------------------------------------------------------------
  // Viewport culling
  // ---------------------------------------------------------------------------

  bool _isInViewport(Offset worldPos, {double margin = 60}) {
    return worldPos.dx >= _cameraOffset.dx - margin &&
        worldPos.dx <= _cameraOffset.dx + _screenSize.width + margin &&
        worldPos.dy >= _cameraOffset.dy - margin &&
        worldPos.dy <= _cameraOffset.dy + _screenSize.height + margin;
  }

  // ---------------------------------------------------------------------------
  // Player proximity
  // ---------------------------------------------------------------------------

  bool _isNearPlayer(Offset creaturePos) {
    final dx = creaturePos.dx - _playerPosition.dx;
    final dy = creaturePos.dy - _playerPosition.dy;
    return sqrt(dx * dx + dy * dy) < _interactionRadius;
  }

  // ---------------------------------------------------------------------------
  // Game tick
  // ---------------------------------------------------------------------------

  void _onTick(Duration elapsed) {
    final state = _ranchBloc.state;
    if (state is! RanchReady) return;

    // Skip movement in edit mode
    if (state.isEditMode) return;

    bool changed = false;

    // Player movement
    if (_joystickDirection != Offset.zero) {
      final newX =
          (_playerPosition.dx + _joystickDirection.dx * _playerSpeed)
              .clamp(24.0, _worldSize.width - 24.0);
      final newY =
          (_playerPosition.dy + _joystickDirection.dy * _playerSpeed)
              .clamp(24.0, _worldSize.height - 24.0);
      _playerPosition = Offset(newX, newY);
      _updateCamera();
      changed = true;
    }

    // Creature proximity & need check
    for (final creature in state.creatures) {
      final near = _isNearPlayer(creature.currentPosition);
      if (near) {
        creature.rollNeed(_random);
      } else {
        creature.resetNeedCheck();
      }
    }

    // Creature movement
    for (final creature in state.creatures) {
      if (!creature.isMoving) {
        if (_random.nextDouble() < creature.moveProbability) {
          creature.pickNewTarget(_worldSize, _random);
          changed = true;
        }
      } else {
        final dx = creature.targetPosition.dx - creature.currentPosition.dx;
        final dy = creature.targetPosition.dy - creature.currentPosition.dy;
        final dist = sqrt(dx * dx + dy * dy);

        if (dist < 2.0) {
          creature.currentPosition = creature.targetPosition;
          creature.isMoving = false;
          changed = true;
        } else {
          final ratio = creature.speed / dist;
          creature.currentPosition = Offset(
            creature.currentPosition.dx + dx * ratio,
            creature.currentPosition.dy + dy * ratio,
          );
          changed = true;
        }
      }
    }

    if (changed) {
      setState(() {});
    }
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  void _showCreatureInfo(RanchCreature creature) {
    showDialog(
      context: context,
      builder: (_) => CreatureInfoPopup(creature: creature),
    );
  }

  void _feedAll() {
    _ranchBloc.add(const FeedAllCreatures());
  }

  void _fulfillNeed(RanchCreature creature) {
    setState(() {
      creature.fulfillNeed();
    });
  }

  List<RanchCreature> _nearCreaturesWithNeed(List<RanchCreature> creatures) {
    return creatures
        .where((c) =>
            _isNearPlayer(c.currentPosition) && c.currentNeed != null)
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Edit mode actions
  // ---------------------------------------------------------------------------

  void _onWorldTapInEditMode(TapUpDetails details, RanchReady state) {
    if (state.selectedItemId == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('하단에서 배치할 아이템을 먼저 선택하세요!'),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFF795548),
        ),
      );
      return;
    }

    final worldX = details.localPosition.dx + _cameraOffset.dx;
    final worldY = details.localPosition.dy + _cameraOffset.dy;
    final gridX = (worldX / kGridCellSize).floor();
    final gridY = (worldY / kGridCellSize).floor();

    _ranchBloc.add(PlaceDecoration(
      itemId: state.selectedItemId!,
      gridX: gridX,
      gridY: gridY,
    ));

    // Feedback
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${findDecorationById(state.selectedItemId!)?.emoji ?? ''} 배치 완료! 계속 탭하여 더 배치하세요'),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFF2E7D32),
      ),
    );
  }

  void _showDecorationOptions(PlacedDecoration decoration) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${decoration.emoji} 장식물 옵션',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2723),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.delete_outline,
                    color: Color(0xFFE53935)),
                title: const Text('삭제'),
                subtitle: const Text('이 장식물을 목장에서 제거합니다'),
                onTap: () {
                  _ranchBloc.add(
                      RemoveDecoration(instanceId: decoration.instanceId));
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openShop() {
    final bloc = _ranchBloc;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: const RanchShopScreen(),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _ranchBloc,
      child: BlocBuilder<CollectionBloc, CollectionState>(
        builder: (context, collectionState) {
          // Load collections if not loaded
          if (collectionState is CollectionInitial) {
            context.read<CollectionBloc>().add(const LoadCollections());
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (collectionState is CollectionLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (collectionState is! CollectionLoaded) {
            return const Scaffold(
              body: Center(child: Text('컬렉션을 불러올 수 없습니다')),
            );
          }

          final items = collectionState.items;

          // Empty state
          if (items.isEmpty) {
            return Scaffold(
              body: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF8BC34A), Color(0xFF689F38)],
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🌿', style: TextStyle(fontSize: 64)),
                      SizedBox(height: 16),
                      Text(
                        '아직 수집한 생물이 없어요!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '발견 탭에서 생물을 찾아보세요 🔍',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) Navigator.of(context).pop();
            },
            child: Scaffold(
            body: LayoutBuilder(
              builder: (context, constraints) {
                final screenSize =
                    Size(constraints.maxWidth, constraints.maxHeight);

                // Initialize world once when bounds are known
                if (!_initialized) {
                  _initialized = true;
                  _initializeWorld(screenSize);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _ranchBloc.add(InitializeRanch(
                      collections: items,
                      bounds: _worldSize,
                    ));
                    _ranchBloc.add(LoadRanchDecorations(bounds: _worldSize));
                  });
                }

                return BlocBuilder<RanchBloc, RanchState>(
                  builder: (context, ranchState) {
                    if (ranchState is! RanchReady) {
                      return RanchBackground(worldSize: screenSize);
                    }

                    final creatures = ranchState.creatures;
                    final decorations = ranchState.placedDecorations;
                    final isEditMode = ranchState.isEditMode;
                    final themeId = ranchState.activeThemeId;

                    return Stack(
                      children: [
                        // [0] World layer with camera transform
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapUp: isEditMode
                              ? (details) =>
                                  _onWorldTapInEditMode(details, ranchState)
                              : null,
                          child: SizedBox.expand(
                            child: Stack(
                              clipBehavior: Clip.hardEdge,
                              children: [
                                Positioned(
                                  left: -_cameraOffset.dx,
                                  top: -_cameraOffset.dy,
                                  width: _worldSize.width,
                                  height: _worldSize.height,
                                  child: Stack(
                                    children: [
                                      // Background with theme
                                      RanchBackground(
                                        worldSize: _worldSize,
                                        themeId: themeId,
                                      ),

                                      // Grid overlay in edit mode
                                      if (isEditMode)
                                        Positioned.fill(
                                          child: CustomPaint(
                                            painter: _GridPainter(
                                              cellSize: kGridCellSize,
                                              color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                                            ),
                                          ),
                                        ),

                                      // Placed decorations (viewport-culled)
                                      ...decorations
                                          .where((d) => _isInViewport(
                                              Offset(d.pixelX, d.pixelY)))
                                          .map((d) {
                                        final def = findDecorationById(d.itemId);
                                        final w = (def?.gridWidth ?? 1) * kGridCellSize;
                                        final h = (def?.gridHeight ?? 1) * kGridCellSize;
                                        return Positioned(
                                          left: d.pixelX,
                                          top: d.pixelY,
                                          width: w,
                                          height: h,
                                          child: PlacedDecorationWidget(
                                            decoration: d,
                                            gridWidth: def?.gridWidth ?? 1,
                                            gridHeight: def?.gridHeight ?? 1,
                                            isEditMode: isEditMode,
                                            onLongPress: isEditMode
                                                ? () =>
                                                    _showDecorationOptions(d)
                                                : null,
                                          ),
                                        );
                                      }),

                                      // Creatures (viewport-culled) - hidden in edit mode for clarity
                                      if (!isEditMode)
                                        ...creatures
                                            .where((c) => _isInViewport(
                                                c.currentPosition))
                                            .map((creature) {
                                          final nearPlayer = _isNearPlayer(
                                              creature.currentPosition);
                                          return Positioned(
                                            left: creature.currentPosition.dx -
                                                24,
                                            top: creature.currentPosition.dy -
                                                24,
                                            child: IgnorePointer(
                                              ignoring: !nearPlayer,
                                              child: Column(
                                                mainAxisSize:
                                                    MainAxisSize.min,
                                                children: [
                                                  if (nearPlayer &&
                                                      creature.currentNeed !=
                                                          null)
                                                    Container(
                                                      padding:
                                                          const EdgeInsets
                                                              .all(4),
                                                      decoration:
                                                          BoxDecoration(
                                                        color: Colors.white
                                                            .withValues(
                                                                alpha: 0.9),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    10),
                                                      ),
                                                      child: Text(
                                                        creature.currentNeed!
                                                            .emoji,
                                                        style:
                                                            const TextStyle(
                                                                fontSize:
                                                                    16),
                                                      ),
                                                    )
                                                  else if (nearPlayer)
                                                    const Text(
                                                      '💬',
                                                      style: TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  RanchCreatureWidget(
                                                    creature: creature,
                                                    onTap: () =>
                                                        _showCreatureInfo(
                                                            creature),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }),

                                      // Player character (hidden in edit mode)
                                      if (!isEditMode)
                                        Positioned(
                                          left: _playerPosition.dx - 24,
                                          top: _playerPosition.dy - 24,
                                          child: Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFF176)
                                                  .withValues(alpha: 0.9),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color:
                                                    const Color(0xFFF9A825),
                                                width: 2,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(
                                                          alpha: 0.2),
                                                  blurRadius: 6,
                                                  offset:
                                                      const Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: const Center(
                                              child: Text(
                                                '🧑‍🌾',
                                                style:
                                                    TextStyle(fontSize: 26),
                                              ),
                                            ),
                                          ),
                                        ),

                                      // Heart effect overlay (inside world)
                                      if (ranchState.isFeeding)
                                        HeartEffectOverlay(
                                          creaturePositions: creatures
                                              .map((c) => Offset(
                                                    c.currentPosition.dx - 5,
                                                    c.currentPosition.dy -
                                                        30,
                                                  ))
                                              .toList(),
                                          onComplete: () => _ranchBloc.add(
                                              const FeedingAnimationComplete()),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // [1] Top UI bar (screen-fixed)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.only(
                              top:
                                  MediaQuery.of(context).padding.top + 8,
                              left: 8,
                              right: 8,
                              bottom: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.3),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Row(
                              children: [
                                // Back button
                                IconButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(),
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  ),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.black
                                        .withValues(alpha: 0.3),
                                    shape: const CircleBorder(),
                                  ),
                                ),
                                const Spacer(),
                                // Creature count badge
                                if (!isEditMode)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white
                                          .withValues(alpha: 0.9),
                                      borderRadius:
                                          BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          '🌿',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${creatures.length}마리',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2E7D32),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (isEditMode)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2E7D32),
                                      borderRadius:
                                          BorderRadius.circular(16),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.edit,
                                            size: 14,
                                            color: Colors.white),
                                        SizedBox(width: 4),
                                        Text(
                                          '편집 모드',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                // Edit button
                                if (!isEditMode)
                                  IconButton(
                                    onPressed: () => _ranchBloc
                                        .add(const ToggleEditMode()),
                                    icon: const Text('✏️',
                                        style: TextStyle(fontSize: 20)),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.white
                                          .withValues(alpha: 0.9),
                                      shape: const CircleBorder(),
                                    ),
                                  ),
                                // Shop button
                                if (!isEditMode)
                                  IconButton(
                                    onPressed: _openShop,
                                    icon: const Text('🏪',
                                        style: TextStyle(fontSize: 20)),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.white
                                          .withValues(alpha: 0.9),
                                      shape: const CircleBorder(),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        // [2] Virtual joystick (hidden in edit mode)
                        if (!isEditMode)
                          Positioned(
                            left: 20,
                            bottom: MediaQuery.of(context).padding.bottom +
                                20,
                            child: VirtualJoystick(
                              onDirectionChanged: (direction) {
                                _joystickDirection = direction;
                              },
                            ),
                          ),

                        // [3] Right-side action buttons (hidden in edit mode)
                        if (!isEditMode)
                          Positioned(
                            right: 16,
                            bottom: MediaQuery.of(context).padding.bottom +
                                100,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Need-based action buttons
                                ..._nearCreaturesWithNeed(creatures)
                                    .map((creature) => Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 10),
                                          child: _NeedActionButton(
                                            creature: creature,
                                            onFulfill: () =>
                                                _fulfillNeed(creature),
                                          ),
                                        )),
                                // Feed all button
                                FloatingActionButton(
                                  heroTag: 'feedAll',
                                  onPressed: ranchState.isFeeding
                                      ? null
                                      : _feedAll,
                                  backgroundColor: ranchState.isFeeding
                                      ? Colors.grey
                                      : const Color(0xFFFF7043),
                                  child: const Text(
                                    '🍎',
                                    style: TextStyle(fontSize: 24),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // [4] Edit mode toolbar (bottom)
                        if (isEditMode)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: EditModeToolbar(
                              ownedItemIds: ranchState.ownedItemIds,
                              selectedItemId: ranchState.selectedItemId,
                              onSelectItem: (itemId) => _ranchBloc
                                  .add(SelectInventoryItem(itemId: itemId)),
                              onSave: () {
                                _ranchBloc.add(const SaveDecorations());
                                _ranchBloc.add(const ToggleEditMode());
                              },
                              onCancel: () {
                                _ranchBloc.add(const ToggleEditMode());
                              },
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Need action button widget
// ---------------------------------------------------------------------------

class _GridPainter extends CustomPainter {
  _GridPainter({required this.cellSize, required this.color});

  final double cellSize;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    for (double x = 0; x <= size.width; x += cellSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += cellSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => false;
}

class _NeedActionButton extends StatelessWidget {
  const _NeedActionButton({
    required this.creature,
    required this.onFulfill,
  });

  final RanchCreature creature;
  final VoidCallback onFulfill;

  @override
  Widget build(BuildContext context) {
    final need = creature.currentNeed!;
    return GestureDetector(
      onTap: onFulfill,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: need.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: need.color.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(need.emoji, style: const TextStyle(fontSize: 22)),
            Text(
              creature.emoji,
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
