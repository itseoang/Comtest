import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../models/collection.dart';

class StatsChart extends StatelessWidget {
  const StatsChart({
    super.key,
    required this.stats,
    this.boostMaxStats,
  });

  final CardStats stats;
  final CardStats? boostMaxStats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatRow('HP', stats.hp, boostMaxStats?.hp, Colors.red),
        const SizedBox(height: 8),
        _buildStatRow('공격', stats.attack, boostMaxStats?.attack, Colors.orange),
        const SizedBox(height: 8),
        _buildStatRow('방어', stats.defense, boostMaxStats?.defense, Colors.blue),
        const SizedBox(height: 8),
        _buildStatRow('속도', stats.speed, boostMaxStats?.speed, Colors.green),
        const SizedBox(height: 8),
        _buildStatRow('매력', stats.charm, boostMaxStats?.charm, Colors.purple),
        const SizedBox(height: 8),
        _buildStatRow('희귀도', stats.rarityScore, null, Colors.amber),
      ],
    );
  }

  Widget _buildStatRow(String label, int value, int? boostMax, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 48,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: boostMax != null && boostMax > value
              ? _buildBoostBar(value, boostMax, color)
              : LinearPercentIndicator(
                  lineHeight: 16,
                  percent: value / 100,
                  backgroundColor: Colors.grey[200],
                  progressColor: color,
                  barRadius: const Radius.circular(8),
                  padding: EdgeInsets.zero,
                  center: Text(
                    '$value',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  /// Stack으로 2개 바를 겹쳐서 boost range를 표시
  Widget _buildBoostBar(int current, int boostMax, Color color) {
    return Stack(
      children: [
        // 뒤쪽: 최대 boost 범위 (반투명)
        LinearPercentIndicator(
          lineHeight: 16,
          percent: boostMax / 100,
          backgroundColor: Colors.grey[200],
          progressColor: color.withOpacity(0.3),
          barRadius: const Radius.circular(8),
          padding: EdgeInsets.zero,
        ),
        // 앞쪽: 현재 값 (진한 색)
        LinearPercentIndicator(
          lineHeight: 16,
          percent: current / 100,
          backgroundColor: Colors.transparent,
          progressColor: color,
          barRadius: const Radius.circular(8),
          padding: EdgeInsets.zero,
          center: Text(
            '$current',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
