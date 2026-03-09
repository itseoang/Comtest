import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/ranch/ranch_bloc.dart';
import '../../blocs/pet/pet_bloc.dart';
import '../../blocs/collection/collection_bloc.dart';
import '../../data/ranch_decoration_catalog.dart';
import '../../models/ranch_decoration.dart';

class RanchShopScreen extends StatefulWidget {
  const RanchShopScreen({super.key});

  @override
  State<RanchShopScreen> createState() => _RanchShopScreenState();
}

class _RanchShopScreenState extends State<RanchShopScreen> {
  DecorationCategory? _selectedCategory;

  String _categoryLabel(DecorationCategory? category) {
    if (category == null) return '전체';
    return '${category.label} ${category.emoji}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF5),
      appBar: AppBar(
        title: const Text('목장 상점'),
        backgroundColor: const Color(0xFFFAFAF5),
        elevation: 0,
        foregroundColor: const Color(0xFF3E2723),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final ecoPoints =
              authState is Authenticated ? authState.profile.ecoPoints : 0;

          return BlocBuilder<RanchBloc, RanchState>(
            builder: (context, ranchState) {
              final ownedIds = ranchState is RanchReady
                  ? ranchState.ownedItemIds
                  : <String>{};
              final activeThemeId = ranchState is RanchReady
                  ? ranchState.activeThemeId
                  : 'theme_summer';

              // Get pet level
              final petState = context.watch<PetBloc>().state;
              final petLevel = petState is PetLoaded ? petState.pet.level : 1;

              // Get collection count
              final collectionState =
                  context.watch<CollectionBloc>().state;
              final collectionCount = collectionState is CollectionLoaded
                  ? collectionState.items.length
                  : 0;

              final filteredItems = _selectedCategory == null
                  ? kDecorationCatalog
                  : kDecorationCatalog
                      .where((d) => d.category == _selectedCategory)
                      .toList();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Eco-points card
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF2E7D32).withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          const Icon(Icons.eco, color: Colors.white, size: 32),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '내 에코포인트',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${ecoPoints}P',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Category filter chips
                    SizedBox(
                      height: 50,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildCategoryChip(null),
                          ...DecorationCategory.values
                              .map((c) => _buildCategoryChip(c)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 2-column grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        final isOwned = ownedIds.contains(item.id);
                        final isActiveTheme = item.category ==
                                DecorationCategory.theme &&
                            activeThemeId == item.id;
                        final levelLocked = item.requiredPetLevel > petLevel;
                        final collectionLocked =
                            item.requiredCollections > collectionCount;
                        final isLocked = levelLocked || collectionLocked;
                        final canAfford =
                            ecoPoints >= item.price && !isLocked;

                        return _DecorationCard(
                          item: item,
                          isOwned: isOwned,
                          isActiveTheme: isActiveTheme,
                          isLocked: isLocked,
                          levelLocked: levelLocked,
                          requiredLevel: item.requiredPetLevel,
                          requiredCollections: item.requiredCollections,
                          canAfford: canAfford,
                          onTap: () {
                            if (isLocked) return;
                            if (isOwned) {
                              if (item.category == DecorationCategory.theme) {
                                _applyTheme(context, item);
                              } else {
                                _showOwnedSnackBar(context, item);
                              }
                            } else if (canAfford) {
                              _showPurchaseDialog(
                                  context, item, ecoPoints);
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(DecorationCategory? category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategory = category),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF2E7D32)
                : const Color(0xFFF5F5E8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              _categoryLabel(category),
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF3E2723),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _applyTheme(BuildContext context, DecorationItemDef item) {
    context.read<RanchBloc>().add(ChangeTheme(themeId: item.id));
    context.read<RanchBloc>().add(const SaveDecorations());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.emoji} ${item.name} 적용!'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
    );
  }

  void _showOwnedSnackBar(BuildContext context, DecorationItemDef item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${item.emoji} ${item.name}은(는) 편집 모드에서 배치할 수 있어요!'),
        backgroundColor: const Color(0xFF795548),
      ),
    );
  }

  void _showPurchaseDialog(
      BuildContext context, DecorationItemDef item, int currentPoints) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('${item.emoji} ${item.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${item.name}을(를) 구매하시겠어요?',
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF3E2723),
              ),
            ),
            if (item.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                item.description,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF8D6E63),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5E8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '필요 포인트',
                    style: TextStyle(color: Color(0xFF8D6E63)),
                  ),
                  Text(
                    '${item.price}P',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5E8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '잔여 포인트',
                    style: TextStyle(color: Color(0xFF8D6E63)),
                  ),
                  Text(
                    '${currentPoints - item.price}P',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              '취소',
              style: TextStyle(color: Color(0xFF8D6E63)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context
                  .read<AuthBloc>()
                  .add(SpendEcoPoints(points: item.price));
              context
                  .read<RanchBloc>()
                  .add(PurchaseDecorationItem(itemId: item.id));
              context.read<RanchBloc>().add(const SaveDecorations());
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${item.emoji} ${item.name} 구매 완료!'),
                  backgroundColor: const Color(0xFF2E7D32),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('구매하기'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Decoration card
// ---------------------------------------------------------------------------

class _DecorationCard extends StatelessWidget {
  const _DecorationCard({
    required this.item,
    required this.isOwned,
    required this.isActiveTheme,
    required this.isLocked,
    required this.levelLocked,
    required this.requiredLevel,
    required this.requiredCollections,
    required this.canAfford,
    required this.onTap,
  });

  final DecorationItemDef item;
  final bool isOwned;
  final bool isActiveTheme;
  final bool isLocked;
  final bool levelLocked;
  final int requiredLevel;
  final int requiredCollections;
  final bool canAfford;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isLocked ? 0.45 : (isOwned || canAfford ? 1.0 : 0.6),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji area
              Container(
                height: 90,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5E8),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        isLocked ? '🔒' : item.emoji,
                        style: TextStyle(
                            fontSize: isLocked ? 36 : 44),
                      ),
                    ),
                    if (isOwned)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isActiveTheme
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFF795548),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            isActiveTheme ? '적용중' : '보유중',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Info area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3E2723),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.description,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF8D6E63),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      if (isLocked) ...[
                        Text(
                          levelLocked
                              ? '레벨 $requiredLevel 필요'
                              : '$requiredCollections종 수집 필요',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFE53935),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ] else if (item.price == 0) ...[
                        const Row(
                          children: [
                            Icon(Icons.eco, size: 13, color: Color(0xFF2E7D32)),
                            SizedBox(width: 4),
                            Text(
                              '무료',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Row(
                          children: [
                            const Icon(Icons.eco,
                                size: 13, color: Color(0xFF2E7D32)),
                            const SizedBox(width: 4),
                            Text(
                              '${item.price}P',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        if (!isOwned && !canAfford) ...[
                          const SizedBox(height: 2),
                          const Text(
                            '포인트 부족',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFFE53935),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
