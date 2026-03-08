import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/quiz/quiz_bloc.dart';

class GuardianEmotionReportSection extends StatelessWidget {
  const GuardianEmotionReportSection({super.key});

  @override
  Widget build(BuildContext context) {
    final quizBloc = context.read<QuizBloc>();
    final reports = quizBloc.emotionReports;

    // 최근 2주 필터
    final twoWeeksAgo = DateTime.now().subtract(const Duration(days: 14));
    final recentReports =
        reports.where((r) => r.date.isAfter(twoWeeksAgo)).toList();

    // 가장 많은 감정
    final emojiCounts = <String, int>{};
    for (final r in recentReports) {
      emojiCounts[r.emoji] = (emojiCounts[r.emoji] ?? 0) + 1;
    }
    final sortedEmojis = emojiCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // 주의 필요 감정 (슬픔/화남)
    final alertEmojis =
        recentReports.where((r) => r.emoji == '😢' || r.emoji == '😠').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '감정 추이',
          style: TextStyle(
            color: Color(0xFF3E2723),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              if (recentReports.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    '아직 감정 기록이 없습니다',
                    style: TextStyle(color: Color(0xFF9E9E9E)),
                  ),
                )
              else ...[
                // 감정 통계 요약
                if (sortedEmojis.isNotEmpty) ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '가장 많은 감정',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5D4037),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: sortedEmojis.take(3).map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${entry.value}회',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF5D4037),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],
                const Divider(),
                const SizedBox(height: 8),
                // 주의 필요 표시
                if (alertEmojis.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber,
                          color: Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '슬픔/화남 감정이 ${alertEmojis.length}회 기록되었습니다',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF5D4037),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                // 최근 기록 타임라인
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '최근 기록',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                ...recentReports.reversed.take(10).map(
                      (r) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Text(
                          r.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                        title: Text(
                          r.label,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF3E2723),
                          ),
                        ),
                        subtitle: Text(
                          '${r.date.month}/${r.date.day} ${r.date.hour}:${r.date.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                        trailing: Text(
                          r.triggerSource,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                      ),
                    ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
