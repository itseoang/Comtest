import 'package:flutter/material.dart';
import '../../data/species_encyclopedia.dart';

class LifecycleTimeline extends StatelessWidget {
  const LifecycleTimeline({super.key, required this.stages});

  final List<LifecycleStage> stages;

  @override
  Widget build(BuildContext context) {
    final sorted = List<LifecycleStage>.from(stages)..sort((a, b) => a.order.compareTo(b.order));

    return Column(
      children: [
        for (int i = 0; i < sorted.length; i++)
          _TimelineItem(
            stage: sorted[i],
            isFirst: i == 0,
            isLast: i == sorted.length - 1,
          ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.stage,
    required this.isFirst,
    required this.isLast,
  });

  final LifecycleStage stage;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 왼쪽: 연결선 + 노드
          SizedBox(
            width: 56,
            child: Column(
              children: [
                // 상단 연결선
                if (!isFirst)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: const Color(0xFFAED581),
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
                // 이모지 노드
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF4CAF50),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      stage.emoji,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                // 하단 연결선
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: const Color(0xFFAED581),
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // 오른쪽: 카드
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          stage.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3E2723),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F8E9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            stage.duration,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF558B2F),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      stage.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF5D4037),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
