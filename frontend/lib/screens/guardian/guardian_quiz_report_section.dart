import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../blocs/quiz/quiz_bloc.dart';
import '../../models/quiz.dart';

class GuardianQuizReportSection extends StatelessWidget {
  const GuardianQuizReportSection({super.key});

  @override
  Widget build(BuildContext context) {
    final quizBloc = context.read<QuizBloc>();
    final history = quizBloc.history;
    final results = history.results;

    // 이번 주 결과 필터
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekResults =
        results.where((r) => r.answeredAt.isAfter(weekStart)).toList();

    final totalCount = weekResults.length;
    final correctCount = weekResults.where((r) => r.isCorrect).length;
    final accuracy = totalCount > 0 ? correctCount / totalCount : 0.0;

    // 과목별 정답률
    final subjectAccuracy = <QuizSubject, double>{};
    for (final subject in QuizSubject.values) {
      final subjectResults =
          weekResults.where((r) => r.subject == subject).toList();
      if (subjectResults.isNotEmpty) {
        subjectAccuracy[subject] =
            subjectResults.where((r) => r.isCorrect).length /
                subjectResults.length;
      }
    }

    // 최장 연속 정답
    int maxStreak = 0;
    int currentStreak = 0;
    for (final r in results) {
      if (r.isCorrect) {
        currentStreak++;
        if (currentStreak > maxStreak) maxStreak = currentStreak;
      } else {
        currentStreak = 0;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '퀴즈 성적',
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
              // 이번 주 요약
              Row(
                children: [
                  Expanded(
                    child: _StatBox(
                      label: '풀이 수',
                      value: '$totalCount문제',
                      icon: Icons.quiz,
                      color: const Color(0xFF2196F3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatBox(
                      label: '정답률',
                      value: '${(accuracy * 100).toStringAsFixed(0)}%',
                      icon: Icons.check_circle,
                      color: const Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatBox(
                      label: '최장 연속',
                      value: '$maxStreak연속',
                      icon: Icons.local_fire_department,
                      color: const Color(0xFFFF9800),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              // 과목별 바
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '과목별 정답률',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5D4037),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _SubjectBar(
                label: '수학',
                ratio: subjectAccuracy[QuizSubject.math] ?? 0,
                color: Colors.blue,
              ),
              _SubjectBar(
                label: '과학',
                ratio: subjectAccuracy[QuizSubject.science] ?? 0,
                color: Colors.green,
              ),
              _SubjectBar(
                label: '영어',
                ratio: subjectAccuracy[QuizSubject.english] ?? 0,
                color: Colors.purple,
              ),
              _SubjectBar(
                label: '국어',
                ratio: subjectAccuracy[QuizSubject.korean] ?? 0,
                color: Colors.orange,
              ),
              const SizedBox(height: 12),
              // 현재 난이도
              Row(
                children: [
                  const Icon(
                    Icons.trending_up,
                    size: 16,
                    color: Color(0xFF8D6E63),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '현재 난이도: ${_difficultyLabel(history.currentDifficulty)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8D6E63),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _difficultyLabel(DifficultyLevel d) {
    return switch (d) {
      DifficultyLevel.age4 => '유아 4세',
      DifficultyLevel.age5 => '유아 5세',
      DifficultyLevel.age6 => '유아 6세',
      DifficultyLevel.age7 => '유아 7세',
      DifficultyLevel.grade1 => '초등 1학년',
      DifficultyLevel.grade2 => '초등 2학년',
      DifficultyLevel.grade3 => '초등 3학년',
      DifficultyLevel.grade4 => '초등 4학년',
      DifficultyLevel.grade5 => '초등 5학년',
      DifficultyLevel.grade6 => '초등 6학년',
    };
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF9E9E9E),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectBar extends StatelessWidget {
  const _SubjectBar({
    required this.label,
    required this.ratio,
    required this.color,
  });

  final String label;
  final double ratio;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF5D4037),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LinearPercentIndicator(
              lineHeight: 14,
              percent: ratio.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[200],
              progressColor: color,
              barRadius: const Radius.circular(7),
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 36,
            child: Text(
              '${(ratio * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
