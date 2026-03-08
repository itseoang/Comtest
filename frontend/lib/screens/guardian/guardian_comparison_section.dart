import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../blocs/quiz/quiz_bloc.dart';
import '../../models/quiz.dart';

// ──────────────────────────────────────────────
// Mock Peer Data Helper
// ──────────────────────────────────────────────

class _MockPeerData {
  _MockPeerData._();

  static final _random = Random(42);

  static int calculatePercentile(double accuracy) {
    if (accuracy >= 0.80) {
      return 5 + _random.nextInt(6); // 5~10
    } else if (accuracy >= 0.60) {
      return 15 + _random.nextInt(11); // 15~25
    } else if (accuracy >= 0.40) {
      return 30 + _random.nextInt(16); // 30~45
    } else {
      return 50 + _random.nextInt(16); // 50~65
    }
  }

  static double getPeerAccuracy(double childAccuracy) {
    final reduction = 0.10 + _random.nextDouble() * 0.10;
    return (childAccuracy - reduction).clamp(0.05, 1.0);
  }

  static double getPeerSubjectAccuracy(double childAccuracy) {
    final reduction = 0.05 + _random.nextDouble() * 0.10;
    return (childAccuracy - reduction).clamp(0.05, 1.0);
  }

  static List<double> getWeeklyGrowth(List<QuizResult> results) {
    // 최근 4주 데이터 계산
    final now = DateTime.now();
    final weeklyAccuracies = <double>[];

    for (int weekOffset = 3; weekOffset >= 0; weekOffset--) {
      final weekEnd = now.subtract(Duration(days: weekOffset * 7));
      final weekStart = weekEnd.subtract(const Duration(days: 7));
      final weekResults = results
          .where(
            (r) =>
                r.answeredAt.isAfter(weekStart) &&
                r.answeredAt.isBefore(weekEnd),
          )
          .toList();

      if (weekResults.isNotEmpty) {
        final correct = weekResults.where((r) => r.isCorrect).length;
        weeklyAccuracies.add(correct / weekResults.length);
      } else {
        weeklyAccuracies.add(-1.0); // 데이터 없음 표시
      }
    }

    // 데이터가 부족하면 점진적 상승 mock으로 채움
    const mockBase = [0.55, 0.62, 0.68, 0.75];
    int mockIndex = 0;
    for (int i = 0; i < 4; i++) {
      if (weeklyAccuracies[i] < 0) {
        weeklyAccuracies[i] = mockBase[mockIndex];
      }
      mockIndex++;
    }

    return weeklyAccuracies;
  }
}

// ──────────────────────────────────────────────
// GuardianComparisonSection
// ──────────────────────────────────────────────

class GuardianComparisonSection extends StatelessWidget {
  const GuardianComparisonSection({super.key});

  @override
  Widget build(BuildContext context) {
    final quizBloc = context.read<QuizBloc>();
    final history = quizBloc.history;
    final results = history.results;

    // 전체 정답률 계산
    final totalCount = results.length;
    final correctCount = results.where((r) => r.isCorrect).length;
    final childAccuracy =
        totalCount > 0 ? correctCount / totalCount : 0.0;

    // 결과가 없으면 기본 상위 20%
    final percentile = totalCount > 0
        ? _MockPeerData.calculatePercentile(childAccuracy)
        : 20;

    final peerAccuracy = _MockPeerData.getPeerAccuracy(
      totalCount > 0 ? childAccuracy : 0.60,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '또래 비교 분석',
          style: TextStyle(
            color: Color(0xFF3E2723),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        // 2-1: 상위 N% 뱃지
        _PercentileBadgeCard(percentile: percentile),
        const SizedBox(height: 12),
        // 2-2: 전체 정답률 비교
        _OverallAccuracyCard(
          childAccuracy: childAccuracy,
          peerAccuracy: peerAccuracy,
        ),
        const SizedBox(height: 12),
        // 2-3: 과목별 비교
        _SubjectComparisonCard(results: results),
        const SizedBox(height: 12),
        // 2-4: 주간 성장 추이
        _WeeklyGrowthCard(results: results),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// 2-1: 상위 N% 뱃지 카드
// ──────────────────────────────────────────────

class _PercentileBadgeCard extends StatelessWidget {
  const _PercentileBadgeCard({required this.percentile});

  final int percentile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.emoji_events,
            color: Color(0xFFFFC107),
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            '상위 $percentile%',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2723),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '같은 나이 어린이 중',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF8D6E63),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// 2-2: 전체 정답률 비교 카드
// ──────────────────────────────────────────────

class _OverallAccuracyCard extends StatelessWidget {
  const _OverallAccuracyCard({
    required this.childAccuracy,
    required this.peerAccuracy,
  });

  final double childAccuracy;
  final double peerAccuracy;

  @override
  Widget build(BuildContext context) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '전체 정답률 비교',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3E2723),
            ),
          ),
          const SizedBox(height: 16),
          _AccuracyRow(
            label: '내 아이',
            accuracy: childAccuracy,
            color: const Color(0xFF2E7D32),
          ),
          const SizedBox(height: 12),
          _AccuracyRow(
            label: '또래 평균',
            accuracy: peerAccuracy,
            color: const Color(0xFF9E9E9E),
          ),
        ],
      ),
    );
  }
}

class _AccuracyRow extends StatelessWidget {
  const _AccuracyRow({
    required this.label,
    required this.accuracy,
    required this.color,
  });

  final String label;
  final double accuracy;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF3E2723),
            ),
          ),
        ),
        Expanded(
          child: LinearPercentIndicator(
            percent: accuracy.clamp(0.0, 1.0),
            lineHeight: 18,
            barRadius: const Radius.circular(9),
            progressColor: color,
            backgroundColor: const Color(0xFFE0E0E0),
            padding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 36,
          child: Text(
            '${(accuracy * 100).round()}%',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// 2-3: 과목별 비교 카드
// ──────────────────────────────────────────────

class _SubjectComparisonCard extends StatelessWidget {
  const _SubjectComparisonCard({required this.results});

  final List<QuizResult> results;

  static const _subjectLabels = {
    QuizSubject.math: '수학',
    QuizSubject.science: '과학',
    QuizSubject.english: '영어',
    QuizSubject.korean: '국어',
  };

  double _subjectAccuracy(QuizSubject subject) {
    final subjectResults =
        results.where((r) => r.subject == subject).toList();
    if (subjectResults.isEmpty) return 0.60; // 기본값
    final correct = subjectResults.where((r) => r.isCorrect).length;
    return correct / subjectResults.length;
  }

  @override
  Widget build(BuildContext context) {
    final subjects = [
      QuizSubject.math,
      QuizSubject.science,
      QuizSubject.english,
      QuizSubject.korean,
    ];

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '과목별 비교',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3E2723),
            ),
          ),
          const SizedBox(height: 16),
          ...subjects.map((subject) {
            final childAcc = _subjectAccuracy(subject);
            final peerAcc =
                _MockPeerData.getPeerSubjectAccuracy(childAcc);
            final childLeading = childAcc >= peerAcc;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _subjectLabels[subject] ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF3E2723),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (childLeading)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '우수',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '노력 중',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFFE65100),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const SizedBox(
                        width: 52,
                        child: Text(
                          '내 아이',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF757575),
                          ),
                        ),
                      ),
                      Expanded(
                        child: LinearPercentIndicator(
                          percent: childAcc.clamp(0.0, 1.0),
                          lineHeight: 12,
                          barRadius: const Radius.circular(6),
                          progressColor: const Color(0xFF2E7D32),
                          backgroundColor: const Color(0xFFE0E0E0),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 32,
                        child: Text(
                          '${(childAcc * 100).round()}%',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E7D32),
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const SizedBox(
                        width: 52,
                        child: Text(
                          '또래 평균',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF757575),
                          ),
                        ),
                      ),
                      Expanded(
                        child: LinearPercentIndicator(
                          percent: peerAcc.clamp(0.0, 1.0),
                          lineHeight: 12,
                          barRadius: const Radius.circular(6),
                          progressColor: const Color(0xFF9E9E9E),
                          backgroundColor: const Color(0xFFE0E0E0),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 32,
                        child: Text(
                          '${(peerAcc * 100).round()}%',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9E9E9E),
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// 2-4: 주간 성장 추이 카드
// ──────────────────────────────────────────────

class _WeeklyGrowthCard extends StatelessWidget {
  const _WeeklyGrowthCard({required this.results});

  final List<QuizResult> results;

  @override
  Widget build(BuildContext context) {
    final weeklyData = _MockPeerData.getWeeklyGrowth(results);
    const maxBarHeight = 120.0;
    final weekLabels = ['1주차', '2주차', '3주차', '4주차'];

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '주간 성장 추이',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3E2723),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: maxBarHeight + 48,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (i) {
                final accuracy = weeklyData[i].clamp(0.0, 1.0);
                final barHeight = accuracy * maxBarHeight;
                final pct = (accuracy * 100).round();

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '$pct%',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: barHeight,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2E7D32),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        weekLabels[i],
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF757575),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
