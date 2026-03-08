import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/quiz/quiz_bloc.dart';
import '../../models/quiz.dart';

/// 감정 체크 바텀시트
class EmotionCheckPopup extends StatefulWidget {
  const EmotionCheckPopup({super.key, required this.question});

  final EmotionQuestion question;

  @override
  State<EmotionCheckPopup> createState() => _EmotionCheckPopupState();
}

class _EmotionCheckPopupState extends State<EmotionCheckPopup> {
  int? _selectedIndex;
  final TextEditingController _followUpController = TextEditingController();
  bool _showFollowUp = false;
  EmotionRecorded? _recordedState;

  // ── 테마 색상 ──
  static const Color _primaryGreen = Color(0xFF2E7D32);
  static const Color _textDarkBrown = Color(0xFF3E2723);

  @override
  void dispose() {
    _followUpController.dispose();
    super.dispose();
  }

  void _onEmotionTap(int index) {
    final choice = widget.question.choices[index];
    setState(() {
      _selectedIndex = index;
      _showFollowUp = choice.followUp != null;
    });

    // 후속 질문 없으면 바로 제출
    if (choice.followUp == null) {
      _submitEmotion(index, null);
    }
  }

  void _submitEmotion(int index, String? followUp) {
    context.read<QuizBloc>().add(
          SubmitEmotion(selectedIndex: index, followUpAnswer: followUp),
        );
  }

  void _onAnswerFollowUp() {
    if (_selectedIndex == null) return;
    _submitEmotion(_selectedIndex!, _followUpController.text.trim());
  }

  void _onSkipFollowUp() {
    if (_selectedIndex == null) return;
    _submitEmotion(_selectedIndex!, null);
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.question;
    final selectedChoice =
        _selectedIndex != null ? question.choices[_selectedIndex!] : null;

    return BlocListener<QuizBloc, QuizState>(
      listener: (context, state) {
        if (state is EmotionRecorded) {
          setState(() => _recordedState = state);
        }
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        child: _recordedState != null
            ? _buildResultView(key: const ValueKey('result'))
            : _buildQuestionView(
                key: const ValueKey('question'),
                question: question,
                selectedChoice: selectedChoice,
              ),
      ),
    );
  }

  Widget _buildResultView({Key? key}) {
    final recorded = _recordedState!;
    return Container(
      key: key,
      decoration: const BoxDecoration(
        color: Color(0xFFE8F5E9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 28,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            recorded.emoji,
            style: const TextStyle(fontSize: 56),
          ),
          const SizedBox(height: 12),
          Text(
            '${recorded.label}!',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _textDarkBrown,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '기분을 알려줘서 고마워요!',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF5D4037),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              color: _primaryGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '+${recorded.points} pt',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                context.read<QuizBloc>().add(const DismissQuiz());
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                '확인',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionView({
    Key? key,
    required EmotionQuestion question,
    required EmotionChoice? selectedChoice,
  }) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 핸들바 ──
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

          // ── 타이틀 행 ──
          Row(
            children: [
              const Text(
                '💭 기분을 알려줘!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _textDarkBrown,
                ),
              ),
              const Spacer(),
              // +5 에코포인트 배지
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                  ),
                ),
                child: const Text(
                  '+5 에코포인트',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _primaryGreen,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.close, size: 22),
                onPressed: () => Navigator.of(context).pop(),
                color: Colors.grey[600],
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── 문제 텍스트 ──
          Text(
            question.questionText,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _textDarkBrown,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // ── 이모지 6개 3x2 그리드 ──
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
            children: List.generate(
              question.choices.length.clamp(0, 6),
              (i) {
                final choice = question.choices[i];
                return _EmotionTile(
                  emoji: choice.emoji,
                  label: choice.label,
                  isSelected: _selectedIndex == i,
                  onTap: () => _onEmotionTap(i),
                );
              },
            ),
          ),

          // ── 후속 질문 ──
          if (_showFollowUp && selectedChoice?.followUp != null) ...[
            const SizedBox(height: 20),
            Text(
              selectedChoice!.followUp!,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _textDarkBrown,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _followUpController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: '자유롭게 적어봐요 (선택)',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _primaryGreen),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _onSkipFollowUp,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      side: BorderSide(color: Colors.grey[300]!),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '건너뛰기',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _onAnswerFollowUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '답변하기',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
      ),
    );
  }
}

// ── 이모지 타일 ──
class _EmotionTile extends StatefulWidget {
  const _EmotionTile({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_EmotionTile> createState() => _EmotionTileState();
}

class _EmotionTileState extends State<_EmotionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  static const Color _primaryGreen = Color(0xFF2E7D32);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(_EmotionTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.isSelected
                ? _primaryGreen.withValues(alpha: 0.1)
                : Colors.grey[100],
            border: Border.all(
              color: widget.isSelected ? _primaryGreen : Colors.grey[200]!,
              width: widget.isSelected ? 2.5 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.emoji,
                style: const TextStyle(fontSize: 36),
              ),
              const SizedBox(height: 2),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: widget.isSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: widget.isSelected ? _primaryGreen : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
