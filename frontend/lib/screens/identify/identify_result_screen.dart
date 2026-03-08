import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/quiz/quiz_bloc.dart';
import '../../data/species_encyclopedia.dart';
import '../../services/species_classifier.dart';

class IdentifyResultScreen extends StatelessWidget {
  const IdentifyResultScreen({
    super.key,
    required this.imageFile,
    required this.results,
  });

  final File imageFile;
  final List<ClassificationResult> results;

  @override
  Widget build(BuildContext context) {
    final topResult = results.isNotEmpty ? results.first : null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('식별 결과'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo
            SizedBox(
              width: double.infinity,
              height: 260,
              child: Image.file(imageFile, fit: BoxFit.cover),
            ),

            if (topResult != null) ...[
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top result
                    _buildTopResult(topResult),
                    const SizedBox(height: 20),

                    // Other candidates
                    if (results.length > 1) ...[
                      const Text(
                        '다른 후보',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...results.skip(1).map(_buildCandidateRow),
                      const SizedBox(height: 24),
                    ],

                    // Species encyclopedia info
                    if (topResult.info != null) ...[
                      _buildEncyclopediaSection(
                        topResult.info!,
                        _getCategoryColor(topResult.category),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Add to collection button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('도감에 추가되었습니다!')),
                          );
                          // 퀴즈 트리거 (종 이름 전달)
                          context.read<QuizBloc>().add(
                                CheckQuizTrigger(
                                  trigger: 'identify',
                                  species: topResult.speciesName,
                                ),
                              );
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text(
                          '내 도감에 추가하기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTopResult(ClassificationResult result) {
    final color = _getCategoryColor(result.category);
    final confidencePercent = (result.confidence * 100).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getCategoryIcon(result.category), color: color, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.speciesName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    if (result.info != null)
                      Text(
                        result.info!.scientificName,
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFF3E2723).withValues(alpha: 0.6),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Confidence bar
          Row(
            children: [
              const Text(
                '일치도',
                style: TextStyle(fontSize: 13, color: Color(0xFF8D6E63)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: result.confidence,
                    minHeight: 8,
                    backgroundColor: color.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$confidencePercent%',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateRow(ClassificationResult result) {
    final confidencePercent = (result.confidence * 100).toStringAsFixed(1);
    final color = _getCategoryColor(result.category);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(_getCategoryIcon(result.category), size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              result.speciesName,
              style: const TextStyle(fontSize: 14, color: Color(0xFF3E2723)),
            ),
          ),
          Text(
            '$confidencePercent%',
            style: const TextStyle(fontSize: 13, color: Color(0xFF8D6E63)),
          ),
        ],
      ),
    );
  }

  Widget _buildEncyclopediaSection(SpeciesInfo info, Color accentColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD7CCC8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book_outlined, size: 20, color: accentColor),
              const SizedBox(width: 8),
              Text(
                '${info.name} 도감 정보',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _infoRow('분류', info.classification),
          const SizedBox(height: 8),
          _infoRow('서식지', info.habitat),
          const SizedBox(height: 8),
          _infoRow('크기', info.size),
          const SizedBox(height: 14),
          // Fun fact
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      '알고 있나요?',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  info.funFact,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF3E2723),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
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
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF3E2723),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'plant':
        return Colors.green;
      case 'bird':
        return Colors.blue;
      case 'insect':
        return Colors.orange;
      case 'mammal':
        return Colors.brown;
      case 'amphibian':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'plant':
        return Icons.eco;
      case 'bird':
        return Icons.flutter_dash;
      case 'insect':
        return Icons.bug_report;
      case 'mammal':
        return Icons.pets;
      case 'amphibian':
        return Icons.water;
      default:
        return Icons.nature;
    }
  }
}
