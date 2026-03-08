import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../data/gifticon_data.dart';

class GifticonExchangeScreen extends StatefulWidget {
  const GifticonExchangeScreen({super.key});

  @override
  State<GifticonExchangeScreen> createState() => _GifticonExchangeScreenState();
}

class _GifticonExchangeScreenState extends State<GifticonExchangeScreen> {
  GifticonCategory _selectedCategory = GifticonCategory.all;

  String _categoryLabel(GifticonCategory category) {
    switch (category) {
      case GifticonCategory.all:
        return '전체';
      case GifticonCategory.cafe:
        return '카페 ☕';
      case GifticonCategory.convenience:
        return '편의점 🏪';
      case GifticonCategory.icecream:
        return '아이스크림 🍦';
    }
  }

  void _showExchangeDialog(
      BuildContext context, Gifticon gifticon, int currentPoints) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('${gifticon.emoji} ${gifticon.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${gifticon.name}을(를) 교환하시겠어요?',
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF3E2723),
              ),
            ),
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
                    '${gifticon.requiredPoints}P',
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
                    '${currentPoints - gifticon.requiredPoints}P',
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
                  .add(SpendEcoPoints(points: gifticon.requiredPoints));
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${gifticon.emoji} ${gifticon.name} 교환 완료!'),
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
            child: const Text('교환하기'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF5),
      appBar: AppBar(
        title: const Text('기프티콘 교환'),
        backgroundColor: const Color(0xFFFAFAF5),
        elevation: 0,
        foregroundColor: const Color(0xFF3E2723),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final ecoPoints =
              state is Authenticated ? state.profile.ecoPoints : 0;

          final filteredItems = _selectedCategory == GifticonCategory.all
              ? kGifticons
              : kGifticons
                  .where((g) => g.category == _selectedCategory)
                  .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 내 에코포인트 카드
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
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
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

                // 카테고리 필터 칩
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: GifticonCategory.values.map((category) {
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
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
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF3E2723),
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // 2열 그리드
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final gifticon = filteredItems[index];
                    final canAfford = ecoPoints >= gifticon.requiredPoints;

                    return _GifticonCard(
                      gifticon: gifticon,
                      canAfford: canAfford,
                      onTap: canAfford
                          ? () => _showExchangeDialog(
                              context, gifticon, ecoPoints)
                          : null,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GifticonCard extends StatelessWidget {
  const _GifticonCard({
    required this.gifticon,
    required this.canAfford,
    this.onTap,
  });

  final Gifticon gifticon;
  final bool canAfford;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: canAfford ? 1.0 : 0.5,
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
              // 이모지 영역
              Container(
                height: 100,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5E8),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Text(
                    gifticon.emoji,
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
              ),

              // 정보 영역
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gifticon.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      gifticon.description,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF8D6E63),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.eco,
                          size: 14,
                          color: Color(0xFF2E7D32),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${gifticon.requiredPoints}P',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    if (!canAfford) ...[
                      const SizedBox(height: 4),
                      const Text(
                        '포인트 부족',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFFE53935),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
