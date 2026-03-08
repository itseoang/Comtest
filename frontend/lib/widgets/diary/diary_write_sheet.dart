import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/collection/collection_detail_bloc.dart';
import '../../models/collection.dart';
import '../../utils/stats_calculator.dart';
import '../collection/stats_chart.dart';

class DiaryWriteSheet extends StatefulWidget {
  const DiaryWriteSheet({
    super.key,
    required this.item,
  });

  final CollectionItem item;

  @override
  State<DiaryWriteSheet> createState() => _DiaryWriteSheetState();
}

class _DiaryWriteSheetState extends State<DiaryWriteSheet> {
  final _whereController = TextEditingController();
  final _whatController = TextEditingController();
  final _lookController = TextEditingController();
  final _specialController = TextEditingController();
  String _selectedMood = 'happy';

  static const _moods = [
    ('happy', '😊', '기쁨'),
    ('curious', '🤔', '호기심'),
    ('surprised', '😮', '놀라움'),
    ('calm', '😌', '평온'),
  ];

  @override
  void dispose() {
    _whereController.dispose();
    _whatController.dispose();
    _lookController.dispose();
    _specialController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    final where = _whereController.text.trim();
    final what = _whatController.text.trim();
    final look = _lookController.text.trim();
    final special = _specialController.text.trim();

    if (where.isEmpty || what.isEmpty || look.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('질문에 답을 적어주세요')),
      );
      return;
    }

    final speciesName = widget.item.speciesName;
    final title = '$speciesName 관찰일기';

    final buffer = StringBuffer();
    buffer.writeln('$where 에서 $speciesName 을(를) 만났어요.');
    buffer.writeln('$speciesName 은(는) $what.');
    buffer.writeln('생김새는 $look.');
    if (special.isNotEmpty) {
      buffer.write('신기했던 점: $special');
    }
    final content = buffer.toString().trimRight();

    context.read<CollectionDetailBloc>().add(
      WriteDiary(
        title: title,
        textContent: content,
        mood: _selectedMood,
        collectionId: widget.item.id,
      ),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final maxBoost = StatsCalculator.getMaxBoostStats(widget.item.stats);

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 핸들바
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 타이틀 + 닫기 버튼
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${widget.item.speciesName} 관찰일기',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 18, color: Color(0xFF5D4037)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '일기를 쓰면 능력치가 10~30% 상승합니다!',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            // 능력치 프리뷰 (boost range 표시)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '능력치 상승 미리보기',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  StatsChart(stats: widget.item.stats, boostMaxStats: maxBoost),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // 질문 1: 어디에서
            _QuestionField(
              question: '이 ${widget.item.speciesName}는 어디에서 만났어?',
              hint: '공원, 산, 학교 운동장...',
              controller: _whereController,
            ),
            const SizedBox(height: 16),
            // 질문 2: 뭘 하고 있었어
            _QuestionField(
              question: '이 ${widget.item.speciesName}는 뭘 하고 있었어?',
              hint: '꽃 위에 앉아있었어, 나무를 오르고 있었어...',
              controller: _whatController,
            ),
            const SizedBox(height: 16),
            // 질문 3: 생김새
            _QuestionField(
              question: '이 ${widget.item.speciesName}의 생김새를 알려줘!',
              hint: '빨간색이고 동그란 점이 있었어...',
              controller: _lookController,
            ),
            const SizedBox(height: 16),
            // 질문 4: 특별히 신기했던 점 (선택)
            _QuestionField(
              question: '특별히 신기했던 점은?',
              hint: '날개를 펼치니까 무늬가 보였어!',
              controller: _specialController,
              isOptional: true,
            ),
            const SizedBox(height: 16),
            // 기분 선택
            Text(
              '오늘의 기분',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: _moods.map((mood) {
                final isSelected = _selectedMood == mood.$1;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedMood = mood.$1),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF4CAF50).withOpacity(0.1)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF4CAF50)
                              : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(mood.$2, style: const TextStyle(fontSize: 24)),
                          const SizedBox(height: 2),
                          Text(
                            mood.$3,
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected
                                  ? const Color(0xFF4CAF50)
                                  : Colors.grey[600],
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // 작성 완료 버튼
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _onSubmit,
                icon: const Icon(Icons.edit_note),
                label: const Text(
                  '관찰일기 작성 완료',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionField extends StatelessWidget {
  const _QuestionField({
    required this.question,
    required this.hint,
    required this.controller,
    this.isOptional = false,
  });

  final String question;
  final String hint;
  final TextEditingController controller;
  final bool isOptional;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              question,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            if (isOptional) ...[
              const SizedBox(width: 6),
              Text(
                '(선택)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
