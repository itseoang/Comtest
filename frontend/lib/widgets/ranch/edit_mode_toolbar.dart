import 'package:flutter/material.dart';
import '../../models/ranch_decoration.dart';
import '../../data/ranch_decoration_catalog.dart';

class EditModeToolbar extends StatelessWidget {
  const EditModeToolbar({
    super.key,
    required this.ownedItemIds,
    required this.selectedItemId,
    required this.onSelectItem,
    required this.onSave,
    required this.onCancel,
  });

  final Set<String> ownedItemIds;
  final String? selectedItemId;
  final ValueChanged<String?> onSelectItem;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    // Get owned items excluding themes
    final ownedItems = kDecorationCatalog
        .where((d) =>
            d.category != DecorationCategory.theme &&
            ownedItemIds.contains(d.id))
        .toList();

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 8,
        top: 8,
        left: 8,
        right: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hint text
          if (selectedItemId != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '화면을 탭하여 장식물을 배치하세요!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          // Action buttons row
          Row(
            children: [
              const Text(
                '장식 배치',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF3E2723),
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.close, size: 18),
                label: const Text('취소'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF8D6E63),
                ),
              ),
              const SizedBox(width: 4),
              ElevatedButton.icon(
                onPressed: onSave,
                icon: const Icon(Icons.check, size: 18),
                label: const Text('저장'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Inventory horizontal scroll
          SizedBox(
            height: 72,
            child: ownedItems.isEmpty
                ? const Center(
                    child: Text(
                      '상점에서 장식물을 구매하세요!',
                      style: TextStyle(
                        color: Color(0xFF8D6E63),
                        fontSize: 13,
                      ),
                    ),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: ownedItems.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final item = ownedItems[index];
                      final isSelected = item.id == selectedItemId;
                      return GestureDetector(
                        onTap: () {
                          if (isSelected) {
                            onSelectItem(null);
                          } else {
                            onSelectItem(item.id);
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 64,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF2E7D32).withValues(alpha: 0.15)
                                : const Color(0xFFF5F5E8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF2E7D32)
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item.emoji,
                                style: const TextStyle(fontSize: 28),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFF3E2723),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
