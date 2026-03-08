import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/quiz/quiz_bloc.dart';
import '../../models/quiz.dart';

/// 학습 퀴즈 바텀시트
class QuizPopup extends StatefulWidget {
  const QuizPopup({super.key, required this.question});

  final QuizQuestion question;

  @override
  State<QuizPopup> createState() => _QuizPopupState();
}

class _QuizPopupState extends State<QuizPopup>
    with TickerProviderStateMixin {
  int? _selectedIndex;
  bool _showFeedback = false;
  QuizAnswered? _answeredState;

  // 애니메이션 컨트롤러
  late final AnimationController _checkController;
  late final AnimationController _pointBadgeController;
  late final AnimationController _feedbackFadeController;

  late final Animation<double> _checkScale;
  late final Animation<Offset> _pointSlide;
  late final Animation<double> _feedbackFade;

  // ── 테마 색상 ──
  static const Color _textDarkBrown = Color(0xFF3E2723);
  static const Color _primaryGreen = Color(0xFF2E7D32);
  static const Color _wrongRed = Color(0xFFE53935);

  // ── 과목 배지 색상 ──
  static const Map<QuizSubject, Color> _subjectColors = {
    QuizSubject.math: Colors.blue,
    QuizSubject.science: Colors.green,
    QuizSubject.english: Colors.purple,
    QuizSubject.korean: Colors.orange,
  };

  // ── 과목 한국어 이름 ──
  static const Map<QuizSubject, String> _subjectNames = {
    QuizSubject.math: '수학',
    QuizSubject.science: '과학',
    QuizSubject.english: '영어',
    QuizSubject.korean: '국어',
  };

  @override
  void initState() {
    super.initState();

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _pointBadgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _feedbackFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _checkScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 40,
      ),
    ]).animate(_checkController);

    _pointSlide = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _pointBadgeController,
      curve: Curves.easeOutCubic,
    ));

    _feedbackFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _feedbackFadeController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _checkController.dispose();
    _pointBadgeController.dispose();
    _feedbackFadeController.dispose();
    super.dispose();
  }

  void _onChoiceTap(int index) {
    if (_selectedIndex != null) return; // 이미 선택됨
    setState(() => _selectedIndex = index);
    context.read<QuizBloc>().add(SubmitAnswer(selectedIndex: index));
  }

  void _playFeedbackAnimations() {
    _feedbackFadeController.forward();
    _checkController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _pointBadgeController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<QuizBloc, QuizState>(
      listener: (context, state) {
        if (state is QuizAnswered) {
          setState(() => _answeredState = state);
          final delay = state.isCorrect ? 500 : 800;
          Future.delayed(Duration(milliseconds: delay), () {
            if (mounted) {
              setState(() => _showFeedback = true);
              _playFeedbackAnimations();
            }
          });
        }
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: _showFeedback && _answeredState != null
            ? _buildFeedbackView(key: const ValueKey('feedback'))
            : _buildQuestionView(key: const ValueKey('question')),
      ),
    );
  }

  // ─── 문제 화면 ───────────────────────────────

  Widget _buildQuestionView({Key? key}) {
    final question = widget.question;
    final isOX = question.type == QuizType.oxQuiz;

    return Container(
      key: key,
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
                '🧠 돌발 퀴즈!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _textDarkBrown,
                ),
              ),
              const SizedBox(width: 8),
              if (question.subject != null) _buildSubjectBadge(question.subject!),
              const Spacer(),
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _textDarkBrown,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),

          // ── 힌트 ──
          if (question.hint != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFE082)),
              ),
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '힌트: ${question.hint}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6D4C00),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ] else
            const SizedBox(height: 4),

          // ── 선택지 ──
          isOX
              ? _buildOXChoices()
              : _buildGridChoices(question.choices),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ─── 피드백 화면 ────────────────────────────

  Widget _buildFeedbackView({Key? key}) {
    final answered = _answeredState!;
    final isCorrect = answered.isCorrect;

    return FadeTransition(
      opacity: _feedbackFade,
      child: Container(
        key: key,
        decoration: BoxDecoration(
          color: isCorrect
              ? const Color(0xFFE8F5E9)
              : const Color(0xFFFCE4EC),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 28,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: isCorrect
              ? _buildCorrectContent(answered)
              : _buildWrongContent(answered),
        ),
      ),
    );
  }

  List<Widget> _buildCorrectContent(QuizAnswered answered) {
    return [
      // 체크 아이콘 (scale 애니메이션)
      ScaleTransition(
        scale: _checkScale,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _primaryGreen.withValues(alpha: 0.15),
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 44,
            color: _primaryGreen,
          ),
        ),
      ),
      const SizedBox(height: 14),

      // "정답이에요!" 텍스트
      const Text(
        '정답이에요!',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: _primaryGreen,
        ),
      ),
      const SizedBox(height: 16),

      // 포인트 배지 (아래에서 올라오는 slide)
      SlideTransition(
        position: _pointSlide,
        child: _buildPointBadge(answered.points, _primaryGreen),
      ),
      const SizedBox(height: 8),

      // 연속 정답 표시
      if (answered.streak >= 3) ...[
        const SizedBox(height: 4),
        Text(
          '🔥 ${answered.streak}연속 정답!',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFFE65100),
          ),
        ),
        const SizedBox(height: 4),
      ],

      const SizedBox(height: 16),
      _buildDismissButton(),
    ];
  }

  List<Widget> _buildWrongContent(QuizAnswered answered) {
    final question = widget.question;
    return [
      // 아쉬움 아이콘 (scale 애니메이션)
      ScaleTransition(
        scale: _checkScale,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _wrongRed.withValues(alpha: 0.1),
          ),
          child: const Center(
            child: Text('🤔', style: TextStyle(fontSize: 38)),
          ),
        ),
      ),
      const SizedBox(height: 14),

      // "아쉽지만 괜찮아요!"
      const Text(
        '아쉽지만 괜찮아요!',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: _wrongRed,
        ),
      ),
      const SizedBox(height: 12),

      // 정답 표시
      if (question.choices.isNotEmpty &&
          answered.correctIndex < question.choices.length)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _wrongRed.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '정답은: ',
                style: TextStyle(
                  fontSize: 14,
                  color: _textDarkBrown,
                ),
              ),
              Text(
                question.choices[answered.correctIndex],
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _primaryGreen,
                ),
              ),
            ],
          ),
        ),
      const SizedBox(height: 12),

      // 해설 박스
      if (answered.explanation != null)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '해설',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                answered.explanation!,
                style: const TextStyle(
                  fontSize: 14,
                  color: _textDarkBrown,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

      const SizedBox(height: 10),

      // 참여 포인트 슬라이드
      SlideTransition(
        position: _pointSlide,
        child: const Text(
          '+1pt 참여 포인트',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      const SizedBox(height: 4),
      const Text(
        '다음에 다시 도전해봐요!',
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF5D4037),
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 20),
      _buildDismissButton(),
    ];
  }

  Widget _buildPointBadge(int points, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '+$points pt',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDismissButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          context.read<QuizBloc>().add(const DismissQuiz());
          Navigator.of(context).pop();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
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
    );
  }

  Widget _buildSubjectBadge(QuizSubject subject) {
    final color = _subjectColors[subject] ?? Colors.grey;
    final name = _subjectNames[subject] ?? subject.name;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // ── 4지선다 2x2 그리드 ──
  Widget _buildGridChoices(List<String> choices) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.8,
      children: List.generate(choices.length, (i) {
        final isSelected = _selectedIndex == i;
        final isDisabled = _selectedIndex != null;
        final correctIdx = _answeredState?.correctIndex;
        final isCorrectTile = correctIdx != null && i == correctIdx;
        final isWrongSelected = _answeredState != null &&
            !_answeredState!.isCorrect &&
            isSelected;

        return _ChoiceTile(
          text: choices[i],
          index: i,
          isSelected: isSelected,
          isDisabled: isDisabled,
          isCorrectTile: isCorrectTile,
          isWrongSelected: isWrongSelected,
          onTap: () => _onChoiceTap(i),
        );
      }),
    );
  }

  // ── OX 선택지 ──
  Widget _buildOXChoices() {
    final correctIdx = _answeredState?.correctIndex;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _OXButton(
          label: 'O',
          color: const Color(0xFF1565C0),
          isSelected: _selectedIndex == 0,
          isDisabled: _selectedIndex != null,
          isCorrectTile: correctIdx != null && 0 == correctIdx,
          isWrongSelected: _answeredState != null &&
              !_answeredState!.isCorrect &&
              _selectedIndex == 0,
          onTap: () => _onChoiceTap(0),
        ),
        _OXButton(
          label: 'X',
          color: const Color(0xFFC62828),
          isSelected: _selectedIndex == 1,
          isDisabled: _selectedIndex != null,
          isCorrectTile: correctIdx != null && 1 == correctIdx,
          isWrongSelected: _answeredState != null &&
              !_answeredState!.isCorrect &&
              _selectedIndex == 1,
          onTap: () => _onChoiceTap(1),
        ),
      ],
    );
  }
}

// ── 선택지 타일 ──
class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.text,
    required this.index,
    required this.isSelected,
    required this.isDisabled,
    required this.isCorrectTile,
    required this.isWrongSelected,
    required this.onTap,
  });

  final String text;
  final int index;
  final bool isSelected;
  final bool isDisabled;
  final bool isCorrectTile;
  final bool isWrongSelected;
  final VoidCallback onTap;

  static const Color _primaryGreen = Color(0xFF2E7D32);
  static const Color _wrongRed = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    Color textColor;
    Widget? trailingIcon;

    if (isCorrectTile) {
      bgColor = _primaryGreen.withValues(alpha: 0.15);
      borderColor = _primaryGreen;
      textColor = _primaryGreen;
      trailingIcon = const Icon(Icons.check_circle, size: 16, color: _primaryGreen);
    } else if (isWrongSelected) {
      bgColor = _wrongRed.withValues(alpha: 0.12);
      borderColor = _wrongRed;
      textColor = _wrongRed;
      trailingIcon = const Icon(Icons.cancel, size: 16, color: _wrongRed);
    } else if (isSelected) {
      bgColor = _primaryGreen.withValues(alpha: 0.12);
      borderColor = _primaryGreen;
      textColor = _primaryGreen;
      trailingIcon = null;
    } else {
      bgColor = Colors.grey[100]!;
      borderColor = Colors.grey[300]!;
      textColor = const Color(0xFF3E2723);
      trailingIcon = null;
    }

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: isSelected || isCorrectTile || isWrongSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected || isCorrectTile || isWrongSelected
                      ? FontWeight.bold
                      : FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 4),
              trailingIcon,
            ],
          ],
        ),
      ),
    );
  }
}

// ── OX 버튼 ──
class _OXButton extends StatelessWidget {
  const _OXButton({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.isDisabled,
    required this.isCorrectTile,
    required this.isWrongSelected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool isSelected;
  final bool isDisabled;
  final bool isCorrectTile;
  final bool isWrongSelected;
  final VoidCallback onTap;

  static const Color _primaryGreen = Color(0xFF2E7D32);
  static const Color _wrongRed = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    Color effectiveColor;
    Color bgColor;

    if (isCorrectTile) {
      effectiveColor = _primaryGreen;
      bgColor = _primaryGreen.withValues(alpha: 0.15);
    } else if (isWrongSelected) {
      effectiveColor = _wrongRed;
      bgColor = _wrongRed.withValues(alpha: 0.15);
    } else if (isSelected) {
      effectiveColor = color;
      bgColor = color.withValues(alpha: 0.15);
    } else {
      effectiveColor = Colors.grey[400]!;
      bgColor = Colors.grey[100]!;
    }

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bgColor,
          border: Border.all(
            color: effectiveColor,
            width: isSelected || isCorrectTile || isWrongSelected ? 3 : 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: effectiveColor,
            ),
          ),
        ),
      ),
    );
  }
}
