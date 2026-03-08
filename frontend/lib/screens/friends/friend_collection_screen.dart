import 'package:flutter/material.dart';
import '../../models/friend.dart';
import '../../models/collection.dart';
import '../../widgets/collection/stats_chart.dart';

class FriendCollectionScreen extends StatelessWidget {
  const FriendCollectionScreen({super.key, required this.friend});

  final Friend friend;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('${friend.nickname}의 도감'),
      ),
      body: friend.collections.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.collections_bookmark_outlined, size: 48, color: Color(0xFFBCAAA4)),
                  SizedBox(height: 12),
                  Text('아직 도감이 비어있어요', style: TextStyle(fontSize: 15, color: Color(0xFF8D6E63))),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: friend.collections.length,
              itemBuilder: (context, index) {
                final item = friend.collections[index];
                return _buildCollectionCard(context, item);
              },
            ),
    );
  }

  Widget _buildCollectionCard(BuildContext context, CollectionItem item) {
    final IconData categoryIcon;
    final Color categoryColor;
    switch (item.speciesCategory) {
      case 'plant':
        categoryIcon = Icons.eco;
        categoryColor = Colors.green;
      case 'bird':
        categoryIcon = Icons.flutter_dash;
        categoryColor = Colors.blue;
      case 'insect':
        categoryIcon = Icons.bug_report;
        categoryColor = Colors.orange;
      case 'mammal':
        categoryIcon = Icons.pets;
        categoryColor = Colors.brown;
      case 'amphibian':
        categoryIcon = Icons.water;
        categoryColor = Colors.teal;
      default:
        categoryIcon = Icons.nature;
        categoryColor = Colors.grey;
    }

    return GestureDetector(
      onTap: () => _showCardDetail(context, item, categoryIcon, categoryColor),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 카테고리 헤더
            Container(
              width: double.infinity,
              height: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [categoryColor.withValues(alpha: 0.7), categoryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Icon(categoryIcon, size: 40, color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.speciesName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (item.locationName != null)
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF8D6E63)),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            item.locationName!,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF8D6E63)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCardDetail(BuildContext context, CollectionItem item, IconData categoryIcon, Color categoryColor) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 핸들바
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // 헤더
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(categoryIcon, size: 32, color: categoryColor),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.speciesName,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF3E2723)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${friend.nickname}의 도감',
                            style: const TextStyle(fontSize: 13, color: Color(0xFF8D6E63)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // 능력치
                const Text('능력치', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF3E2723))),
                const SizedBox(height: 12),
                StatsChart(stats: item.stats),
                const SizedBox(height: 20),
                // 발견 정보
                if (item.locationName != null) ...[
                  _detailRow(Icons.location_on_outlined, '발견 장소', item.locationName!),
                  const SizedBox(height: 10),
                ],
                if (item.discoveredAt != null) ...[
                  _detailRow(
                    Icons.calendar_today_outlined,
                    '발견 날짜',
                    '${item.discoveredAt!.year}년 ${item.discoveredAt!.month}월 ${item.discoveredAt!.day}일${item.weather != null ? '  ${item.weather}' : ''}',
                  ),
                  const SizedBox(height: 10),
                ],
                if (item.notes != null && item.notes!.isNotEmpty) ...[
                  _detailRow(Icons.note_outlined, '메모', item.notes!),
                ],
                const SizedBox(height: 16),
                // 일기 비공개 안내
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE0D8D0)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lock_outline, size: 16, color: Color(0xFFBCAAA4)),
                      SizedBox(width: 8),
                      Text(
                        '관찰일기는 본인만 볼 수 있어요',
                        style: TextStyle(fontSize: 13, color: Color(0xFF8D6E63)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF8D6E63)),
        const SizedBox(width: 8),
        Text('$label  ', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF5D4037))),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 13, color: Color(0xFF5D4037))),
        ),
      ],
    );
  }
}
