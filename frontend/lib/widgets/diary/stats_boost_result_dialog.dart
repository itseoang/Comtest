import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../utils/stats_calculator.dart';

class StatsBoostResultDialog extends StatelessWidget {
  const StatsBoostResultDialog({
    super.key,
    required this.result,
    required this.speciesName,
    required this.onDismiss,
  });

  final StatsBoostResult result;
  final String speciesName;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, size: 48, color: Colors.amber),
            const SizedBox(height: 12),
            const Text(
              '능력치 상승!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '$speciesName의 능력치가 올랐습니다',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            _buildStatResult(
              'HP',
              result.beforeStats.hp,
              result.afterStats.hp,
              result.boostAmounts['hp'] ?? 0,
              Colors.red,
            ),
            const SizedBox(height: 10),
            _buildStatResult(
              '공격',
              result.beforeStats.attack,
              result.afterStats.attack,
              result.boostAmounts['attack'] ?? 0,
              Colors.orange,
            ),
            const SizedBox(height: 10),
            _buildStatResult(
              '방어',
              result.beforeStats.defense,
              result.afterStats.defense,
              result.boostAmounts['defense'] ?? 0,
              Colors.blue,
            ),
            const SizedBox(height: 10),
            _buildStatResult(
              '속도',
              result.beforeStats.speed,
              result.afterStats.speed,
              result.boostAmounts['speed'] ?? 0,
              Colors.green,
            ),
            const SizedBox(height: 10),
            _buildStatResult(
              '매력',
              result.beforeStats.charm,
              result.afterStats.charm,
              result.boostAmounts['charm'] ?? 0,
              Colors.purple,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onDismiss,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '확인',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatResult(
    String label,
    int before,
    int after,
    int boost,
    Color color,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: LinearPercentIndicator(
            lineHeight: 14,
            percent: after / 100,
            backgroundColor: Colors.grey[200],
            progressColor: color,
            barRadius: const Radius.circular(7),
            padding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(
            '$before → $after',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 36,
          child: Text(
            boost > 0 ? '+$boost' : '0',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: boost > 0 ? const Color(0xFF4CAF50) : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
