import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/diary/diary_bloc.dart';
import '../../data/species_encyclopedia.dart';
import '../../models/diary.dart';
import '../../services/image_validator.dart';
import '../../services/map_launcher.dart';

class DiaryDetailScreen extends StatefulWidget {
  const DiaryDetailScreen({super.key, required this.entry});

  final DiaryEntry entry;

  @override
  State<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends State<DiaryDetailScreen> {
  bool _showSpeciesInfo = false;
  String? _photoPath;
  late List<GuardianComment> _comments;
  final TextEditingController _commentController = TextEditingController();

  static const _moodEmojis = {
    'happy': '😊',
    'curious': '🤔',
    'surprised': '😮',
    'calm': '😌',
  };

  static const _moodNames = {
    'happy': '기쁨',
    'curious': '호기심',
    'surprised': '놀라움',
    'calm': '평온',
  };

  @override
  void initState() {
    super.initState();
    _comments = List.from(widget.entry.guardianComments);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final emoji = _moodEmojis[entry.mood] ?? '😊';
    final moodName = _moodNames[entry.mood] ?? '';
    final speciesInfo = SpeciesEncyclopedia.getInfo(entry.speciesName);

    final IconData categoryIcon;
    final Color categoryColor;
    switch (entry.speciesCategory) {
      case 'plant':
        categoryIcon = Icons.eco;
        categoryColor = Colors.green;
      case 'bird':
        categoryIcon = Icons.flutter_dash;
        categoryColor = Colors.blue;
      case 'insect':
        categoryIcon = Icons.bug_report;
        categoryColor = Colors.orange;
      case 'mammal':
        categoryIcon = Icons.pets;
        categoryColor = Colors.brown;
      case 'amphibian':
        categoryIcon = Icons.water;
        categoryColor = Colors.teal;
      default:
        categoryIcon = Icons.nature;
        categoryColor = Colors.grey;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(entry.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 사진 헤더 (오버레이 라벨 포함)
            GestureDetector(
              onTap: _pickPhoto,
              child: SizedBox(
                width: double.infinity,
                height: 260,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 배경: 사진 또는 그라데이션
                    if (_photoPath != null)
                      Image.file(
                        File(_photoPath!),
                        fit: BoxFit.cover,
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [categoryColor.withValues(alpha: 0.7), categoryColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(categoryIcon, size: 48, color: Colors.white),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              entry.speciesName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (speciesInfo != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                speciesInfo.scientificName,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    // 하단 그라데이션 오버레이
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 120,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.55),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // 우측 상단: 사진 추가 버튼
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.camera_alt_outlined, size: 16, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              _photoPath != null ? '사진 변경' : '사진 추가',
                              style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // 좌측 하단: 발견 장소
                    Positioned(
                      left: 14,
                      bottom: 14,
                      child: GestureDetector(
                        onTap: entry.location != null ? () => _openMap(entry) : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on, size: 14, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                entry.location ?? '장소 미기록',
                                style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                              ),
                              if (entry.location != null) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.open_in_new, size: 10, color: Colors.white70),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    // 우측 하단: 함께한 사람
                    Positioned(
                      right: 14,
                      bottom: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.people_outline, size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              entry.companion ?? '혼자',
                              style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and mood row
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF8D6E63)),
                      const SizedBox(width: 6),
                      Text(
                        '${entry.createdAt.year}년 ${entry.createdAt.month}월 ${entry.createdAt.day}일',
                        style: const TextStyle(fontSize: 14, color: Color(0xFF8D6E63)),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(emoji, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 4),
                            Text(
                              moodName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: categoryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Diary content
                  const Text(
                    '관찰 내용',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF3E2723)),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFECB3)),
                    ),
                    child: Text(
                      entry.content,
                      style: const TextStyle(fontSize: 15, color: Color(0xFF3E2723), height: 1.8),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Species info button
                  if (speciesInfo != null) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() => _showSpeciesInfo = !_showSpeciesInfo),
                        icon: Icon(
                          _showSpeciesInfo ? Icons.menu_book : Icons.menu_book_outlined,
                          size: 20,
                        ),
                        label: Text(_showSpeciesInfo ? '학술 정보 접기' : '이 생물 알아보기'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: categoryColor,
                          side: BorderSide(color: categoryColor.withValues(alpha: 0.5)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),

                    // Species info section
                    if (_showSpeciesInfo) ...[
                      const SizedBox(height: 16),
                      _buildSpeciesInfoSection(speciesInfo, categoryColor),
                    ],
                  ],

                  const SizedBox(height: 28),

                  // ── 보호자 한마디 섹션 ──
                  _buildGuardianCommentsSection(entry),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuardianCommentsSection(DiaryEntry entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더
        Row(
          children: [
            const Icon(Icons.favorite, size: 18, color: Color(0xFFE91E63)),
            const SizedBox(width: 8),
            const Text(
              '보호자 한마디',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF3E2723),
              ),
            ),
            if (_comments.isNotEmpty) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE91E63),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_comments.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),

        // 댓글 리스트
        if (_comments.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFCE4EC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Text('💝', style: TextStyle(fontSize: 28)),
                SizedBox(height: 8),
                Text(
                  '아직 보호자 한마디가 없어요',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFAD1457),
                  ),
                ),
              ],
            ),
          )
        else
          ..._comments.map((comment) => _buildCommentCard(comment)),

        const SizedBox(height: 16),

        // 보호자 전용 댓글 입력
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is! Authenticated) return const SizedBox.shrink();
            if (!authState.profile.isGuardian) return const SizedBox.shrink();
            return _buildCommentInput(context, authState.profile.nickname);
          },
        ),
      ],
    );
  }

  Widget _buildCommentCard(GuardianComment comment) {
    final hour = comment.createdAt.hour.toString().padLeft(2, '0');
    final minute = comment.createdAt.minute.toString().padLeft(2, '0');
    final dateStr =
        '${comment.createdAt.year}.${comment.createdAt.month.toString().padLeft(2, '0')}.${comment.createdAt.day.toString().padLeft(2, '0')} $hour:$minute';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFCE4EC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFF8BBD0),
                child: Text('💝', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.authorName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF880E4F),
                    ),
                  ),
                  Text(
                    dateStr,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFAD1457),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment.content,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF3E2723),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(BuildContext context, String authorName) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF8BBD0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E63).withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_outlined, size: 16, color: Color(0xFFE91E63)),
              const SizedBox(width: 6),
              Text(
                '$authorName님의 한마디',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE91E63),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _commentController,
            maxLines: 3,
            minLines: 2,
            style: const TextStyle(fontSize: 14, color: Color(0xFF3E2723)),
            decoration: InputDecoration(
              hintText: '아이에게 칭찬 한마디를 남겨주세요',
              hintStyle: TextStyle(
                fontSize: 14,
                color: const Color(0xFF3E2723).withValues(alpha: 0.4),
              ),
              filled: true,
              fillColor: const Color(0xFFFCE4EC).withValues(alpha: 0.4),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFF8BBD0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE91E63), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _submitComment(context, authorName),
              icon: const Icon(Icons.favorite, size: 16),
              label: const Text(
                '칭찬 남기기',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitComment(BuildContext context, String authorName) {
    final text = _commentController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('한마디를 입력해주세요'),
          backgroundColor: const Color(0xFFE91E63),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final newComment = GuardianComment(
      id: 'gc-${DateTime.now().millisecondsSinceEpoch}',
      authorName: authorName,
      content: text,
      createdAt: DateTime.now(),
    );

    // 로컬 상태 즉시 업데이트 (UI 반영)
    setState(() {
      _comments = List.from(_comments)..add(newComment);
    });
    _commentController.clear();

    // DiaryBloc에도 영속 업데이트
    context.read<DiaryBloc>().add(
          AddGuardianComment(
            diaryId: widget.entry.id,
            authorName: authorName,
            content: text,
          ),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.favorite, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text('칭찬을 남겼어요!'),
          ],
        ),
        backgroundColor: const Color(0xFFE91E63),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _openMap(DiaryEntry entry) async {
    await MapLauncher.openNaverMap(
      placeName: entry.location!,
      latitude: entry.latitude,
      longitude: entry.longitude,
    );
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final file = File(picked.path);

      // EXIF 검증
      final result = await ImageValidator.validate(file);
      if (!result.isLikelyDirectPhoto && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text('직접 촬영한 사진을 추천해요!'),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF8D6E63),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }

      setState(() => _photoPath = picked.path);
    }
  }

  Widget _buildSpeciesInfoSection(SpeciesInfo info, Color accentColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD7CCC8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.science_outlined, size: 20, color: accentColor),
              const SizedBox(width: 8),
              Text(
                '${info.name} 학술 정보',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Scientific name
          _infoRow('학명', info.scientificName, isItalic: true),
          const SizedBox(height: 12),

          // Classification
          _infoRow('분류', info.classification),
          const SizedBox(height: 12),

          // Habitat
          _infoRow('서식지', info.habitat),
          const SizedBox(height: 12),

          // Size
          _infoRow('크기', info.size),
          const SizedBox(height: 16),

          // Features
          const Text(
            '주요 특징',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF5D4037),
            ),
          ),
          const SizedBox(height: 8),
          ...info.features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 7),
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    f,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF3E2723), height: 1.5),
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 16),

          // Fun fact
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accentColor.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      '재미있는 사실',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  info.funFact,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF3E2723), height: 1.6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Conservation status
          Row(
            children: [
              const Icon(Icons.shield_outlined, size: 16, color: Color(0xFF8D6E63)),
              const SizedBox(width: 6),
              const Text(
                '보전 상태: ',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF5D4037)),
              ),
              Expanded(
                child: Text(
                  info.conservationStatus,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF8D6E63)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isItalic = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 48,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF5D4037),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF3E2723),
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
