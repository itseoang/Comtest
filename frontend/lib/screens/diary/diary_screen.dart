import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/diary/diary_bloc.dart';
import '../../models/diary.dart';

class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DiaryBloc()..add(const LoadDiaries()),
      child: const _DiaryView(),
    );
  }
}

class _DiaryView extends StatelessWidget {
  const _DiaryView();

  static const _moodEmojis = {
    'happy': '😊',
    'curious': '🤔',
    'surprised': '😮',
    'calm': '😌',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<DiaryBloc, DiaryState>(
          builder: (context, state) {
            final count = state is DiaryLoaded ? state.entries.length : 0;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('관찰일기'),
                if (count > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
      body: BlocBuilder<DiaryBloc, DiaryState>(
        builder: (context, state) {
          if (state is DiaryLoaded) {
            if (state.entries.isEmpty) {
              return _buildEmptyState();
            }
            return _buildList(state.entries);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_stories_outlined, size: 64, color: Color(0xFFBCAAA4)),
          const SizedBox(height: 16),
          const Text(
            '아직 관찰일기가 없어요',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3E2723),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '도감에서 생물을 선택하고\n관찰일기를 써보세요!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF3E2723).withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<DiaryEntry> entries) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = entries[index];
        final emoji = _moodEmojis[entry.mood] ?? '😊';
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3E2723),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${entry.createdAt.year}.${entry.createdAt.month.toString().padLeft(2, '0')}.${entry.createdAt.day.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8D6E63),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAF5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    entry.content,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF3E2723),
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
