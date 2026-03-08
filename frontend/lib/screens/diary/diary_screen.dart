import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../blocs/diary/diary_bloc.dart';
import '../../models/diary.dart';
import '../../services/map_launcher.dart';

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

class _DiaryView extends StatefulWidget {
  const _DiaryView();

  @override
  State<_DiaryView> createState() => _DiaryViewState();
}

class _DiaryViewState extends State<_DiaryView> {
  late DateTime _currentMonth;
  DateTime? _selectedDate;

  static const _moodEmojis = {
    'happy': '😊',
    'curious': '🤔',
    'surprised': '😮',
    'calm': '😌',
  };

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(2026, 2); // mock 데이터 기준
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('관찰일기'),
      ),
      body: BlocBuilder<DiaryBloc, DiaryState>(
        builder: (context, state) {
          if (state is DiaryLoaded) {
            if (state.entries.isEmpty) {
              return _buildEmptyState();
            }
            return _buildCalendarView(state.entries);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildCalendarView(List<DiaryEntry> entries) {
    // Build mood map: date -> mood emoji
    final moodMap = <String, String>{};
    for (final entry in entries) {
      final key = '${entry.createdAt.year}-${entry.createdAt.month}-${entry.createdAt.day}';
      moodMap[key] = _moodEmojis[entry.mood] ?? '😊';
    }

    // Filter entries for selected date
    final filteredEntries = _selectedDate != null
        ? entries.where((e) =>
            e.createdAt.year == _selectedDate!.year &&
            e.createdAt.month == _selectedDate!.month &&
            e.createdAt.day == _selectedDate!.day).toList()
        : entries;

    return Column(
      children: [
        // Calendar
        _buildCalendar(moodMap),
        const Divider(height: 1),
        // Entry list
        Expanded(
          child: filteredEntries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.event_note_outlined, size: 48, color: Color(0xFFBCAAA4)),
                      const SizedBox(height: 12),
                      Text(
                        _selectedDate != null
                            ? '이 날의 일기가 없어요'
                            : '일기를 선택해보세요',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF8D6E63),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredEntries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      _buildDiaryCard(context, filteredEntries[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildCalendar(Map<String, String> moodMap) {
    final year = _currentMonth.year;
    final month = _currentMonth.month;
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    final startWeekday = firstDay.weekday % 7; // Sun=0
    final totalDays = lastDay.day;

    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    final today = DateTime.now();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Column(
        children: [
          // Month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Color(0xFF5D4037)),
                onPressed: () {
                  setState(() {
                    _currentMonth = DateTime(year, month - 1);
                    _selectedDate = null;
                  });
                },
              ),
              GestureDetector(
                onTap: () {
                  setState(() => _selectedDate = null);
                },
                child: Text(
                  '$year년 $month월',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3E2723),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Color(0xFF5D4037)),
                onPressed: () {
                  setState(() {
                    _currentMonth = DateTime(year, month + 1);
                    _selectedDate = null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Weekday headers
          Row(
            children: weekdays.map((d) {
              final color = d == '일'
                  ? const Color(0xFFE53935)
                  : d == '토'
                      ? const Color(0xFF1565C0)
                      : const Color(0xFF8D6E63);
              return Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 6),
          // Day grid
          ...List.generate(
            ((startWeekday + totalDays + 6) ~/ 7),
            (week) {
              return Row(
                children: List.generate(7, (weekday) {
                  final dayIndex = week * 7 + weekday - startWeekday + 1;
                  if (dayIndex < 1 || dayIndex > totalDays) {
                    return const Expanded(child: SizedBox(height: 48));
                  }

                  final date = DateTime(year, month, dayIndex);
                  final dateKey = '$year-$month-$dayIndex';
                  final moodEmoji = moodMap[dateKey];
                  final isSelected = _selectedDate != null &&
                      _selectedDate!.year == year &&
                      _selectedDate!.month == month &&
                      _selectedDate!.day == dayIndex;
                  final isToday = today.year == year &&
                      today.month == month &&
                      today.day == dayIndex;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedDate = null;
                          } else {
                            _selectedDate = date;
                          }
                        });
                      },
                      child: Container(
                        height: 48,
                        margin: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF2E7D32).withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: isToday
                              ? Border.all(
                                  color: const Color(0xFF2E7D32),
                                  width: 1.5,
                                )
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$dayIndex',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected || isToday
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                                color: isSelected
                                    ? const Color(0xFF2E7D32)
                                    : weekday == 0
                                        ? const Color(0xFFE53935)
                                        : weekday == 6
                                            ? const Color(0xFF1565C0)
                                            : const Color(0xFF3E2723),
                              ),
                            ),
                            if (moodEmoji != null)
                              Text(
                                moodEmoji,
                                style: const TextStyle(fontSize: 14),
                              )
                            else
                              const SizedBox(height: 14),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }

  static const _categoryColors = {
    'plant': Color(0xFF388E3C),
    'bird': Color(0xFF1565C0),
    'insect': Color(0xFFE65100),
    'mammal': Color(0xFF5D4037),
    'amphibian': Color(0xFF00695C),
  };

  static const _categoryIcons = {
    'plant': Icons.eco,
    'bird': Icons.air,
    'insect': Icons.bug_report,
    'mammal': Icons.pets,
    'amphibian': Icons.water,
  };

  Future<void> _openMap(BuildContext context, DiaryEntry entry) async {
    await MapLauncher.openNaverMap(
      placeName: entry.location!,
      latitude: entry.latitude,
      longitude: entry.longitude,
    );
  }

  Future<void> _pickImage(BuildContext context, DiaryEntry entry) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null && context.mounted) {
      context.read<DiaryBloc>().add(
            AddDiaryImage(diaryId: entry.id, imagePath: picked.path),
          );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이미지가 추가되었습니다'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildDiaryCard(BuildContext context, DiaryEntry entry) {
    final emoji = _moodEmojis[entry.mood] ?? '😊';
    final categoryColor =
        _categoryColors[entry.speciesCategory] ?? const Color(0xFF388E3C);
    final categoryIcon =
        _categoryIcons[entry.speciesCategory] ?? Icons.eco;

    return GestureDetector(
      onTap: () => context.push('/diary/detail', extra: entry),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 Row: 무드이모지 + 제목/날짜 | 이미지 버튼
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(width: 8),
                  // 우측 상단 이미지 영역
                  GestureDetector(
                    onTap: () => _pickImage(context, entry),
                    child: entry.imagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(entry.imagePath!),
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F0),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFD7CCC8),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              size: 22,
                              color: Color(0xFFBCAAA4),
                            ),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 중간: 내용
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
              const SizedBox(height: 10),
              // 장소 정보 (위치 탭 가능)
              if (entry.location != null) ...[
                GestureDetector(
                  onTap: () => _openMap(context, entry),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Color(0xFF8D6E63)),
                      const SizedBox(width: 4),
                      Text(
                        entry.location!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8D6E63),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.open_in_new, size: 11, color: Color(0xFFBCAAA4)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
              // 하단: 종 이름 라벨 + 보호자 댓글 인디케이터
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: categoryColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          categoryIcon,
                          size: 13,
                          color: categoryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          entry.speciesName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: categoryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (entry.guardianComments.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCE4EC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.favorite, size: 12, color: Color(0xFFE91E63)),
                          SizedBox(width: 3),
                          Text(
                            '보호자 💬',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFFE91E63),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
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
}
