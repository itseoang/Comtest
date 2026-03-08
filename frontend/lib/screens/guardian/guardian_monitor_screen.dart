import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/quiz/quiz_bloc.dart';
import '../../models/quiz.dart';
import 'guardian_quiz_report_section.dart';
import 'guardian_emotion_report_section.dart';
import 'guardian_comparison_section.dart';

class GuardianMonitorScreen extends StatelessWidget {
  const GuardianMonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF5),
      appBar: AppBar(
        title: const Text(
          '활동 모니터링',
          style: TextStyle(
            color: Color(0xFF3E2723),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFFAFAF5),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF3E2723)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ChildProfileCard(),
            const SizedBox(height: 16),
            const _GradeSettingCard(),
            const SizedBox(height: 20),
            _ActivitySummarySection(),
            const SizedBox(height: 20),
            const GuardianQuizReportSection(),
            const SizedBox(height: 20),
            const GuardianComparisonSection(),
            const SizedBox(height: 20),
            const GuardianEmotionReportSection(),
            const SizedBox(height: 20),
            _RecentActivitySection(),
          ],
        ),
      ),
    );
  }
}

class _GradeSettingCard extends StatelessWidget {
  const _GradeSettingCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final gradeLevel =
            state is Authenticated ? state.profile.gradeLevel : 2;
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
          child: Row(
            children: [
              const Icon(Icons.school, color: Color(0xFF2E7D32), size: 24),
              const SizedBox(width: 12),
              const Text(
                '자녀 학년 설정',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3E2723),
                ),
              ),
              const Spacer(),
              DropdownButton<int>(
                value: gradeLevel,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('유아 (4세)')),
                  DropdownMenuItem(value: 1, child: Text('유아 (5세)')),
                  DropdownMenuItem(value: 2, child: Text('유아 (6세)')),
                  DropdownMenuItem(value: 3, child: Text('초등 1학년')),
                  DropdownMenuItem(value: 4, child: Text('초등 2학년')),
                  DropdownMenuItem(value: 5, child: Text('초등 3학년')),
                  DropdownMenuItem(value: 6, child: Text('초등 4학년')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    context
                        .read<AuthBloc>()
                        .add(UpdateGradeLevel(gradeLevel: value));
                    context.read<QuizBloc>().updateDifficulty(
                          DifficultyLevel.fromGradeLevel(value),
                        );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChildProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.child_care,
              size: 36,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '테스트탐험가',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Lv.5 자연탐험가',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '오늘 활동 시간: 42분',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivitySummarySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '오늘의 활동 요약',
          style: TextStyle(
            color: Color(0xFF3E2723),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.camera_alt,
                iconColor: const Color(0xFF2E7D32),
                value: '3',
                label: '관찰 횟수',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                icon: Icons.auto_stories,
                iconColor: const Color(0xFF1565C0),
                value: '1',
                label: '일기 작성',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                icon: Icons.collections_bookmark,
                iconColor: const Color(0xFF6A1B9A),
                value: '2',
                label: '도감 등록',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF3E2723),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9E9E9E),
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RecentActivitySection extends StatelessWidget {
  static const List<_ActivityItem> _mockActivities = [
    _ActivityItem(
      icon: '🌿',
      time: '오후 4:32',
      description: '산책로에서 단풍나무 관찰',
      detail: '도감에 등록됨',
    ),
    _ActivityItem(
      icon: '📝',
      time: '오후 4:15',
      description: '관찰일기 작성',
      detail: '오늘 본 단풍나무에 대해',
    ),
    _ActivityItem(
      icon: '🦋',
      time: '오후 3:50',
      description: '호랑나비 발견 및 촬영',
      detail: '도감에 등록됨',
    ),
    _ActivityItem(
      icon: '📷',
      time: '오후 3:30',
      description: '민들레 종 식별',
      detail: 'AI 식별 성공',
    ),
    _ActivityItem(
      icon: '🌸',
      time: '오후 2:10',
      description: '진달래꽃 관찰',
      detail: '사진 3장 촬영',
    ),
    _ActivityItem(
      icon: '🏆',
      time: '오전 10:05',
      description: '앱 접속',
      detail: '오늘 첫 번째 탐험 시작',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '최근 활동',
          style: TextStyle(
            color: Color(0xFF3E2723),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
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
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _mockActivities.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              indent: 60,
              endIndent: 16,
            ),
            itemBuilder: (context, index) {
              final activity = _mockActivities[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5E8),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          activity.icon,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.description,
                            style: const TextStyle(
                              color: Color(0xFF3E2723),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            activity.detail,
                            style: const TextStyle(
                              color: Color(0xFF9E9E9E),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      activity.time,
                      style: const TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ActivityItem {
  const _ActivityItem({
    required this.icon,
    required this.time,
    required this.description,
    required this.detail,
  });

  final String icon;
  final String time;
  final String description;
  final String detail;
}
