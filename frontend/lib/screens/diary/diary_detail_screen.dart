import 'package:flutter/material.dart';
import '../../data/species_encyclopedia.dart';
import '../../models/diary.dart';

class DiaryDetailScreen extends StatefulWidget {
  const DiaryDetailScreen({super.key, required this.entry});

  final DiaryEntry entry;

  @override
  State<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends State<DiaryDetailScreen> {
  bool _showSpeciesInfo = false;

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
            // Species image header
            Container(
              width: double.infinity,
              height: 200,
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

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
