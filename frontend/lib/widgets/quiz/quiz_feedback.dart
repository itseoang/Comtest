import 'package:flutter/material.dart';

// ──────────────────────────────────────────────
// QuizFeedback
// ──────────────────────────────────────────────

/// 정답/오답 피드백 위젯
class QuizFeedback extends StatelessWidget {
  const QuizFeedback({
    super.key,
    required this.isCorrect,
    required this.points,
    required this.streak,
    this.explanation,
    required this.correctIndex,
    required this.choices,
    required this.onDismiss,
    this.streakBonus = 0,
  });

  final bool isCorrect;
  final int points;
  final int streak;
  final String? explanation;
  final int correctIndex;
  final List<String> choices;
  final VoidCallback onDismiss;
  final int streakBonus;

  // ── 테마 색상 ──
  static const Color _primaryGreen = Color(0xFF2E7D32);
  static const Color _textDarkBrown = Color(0xFF3E2723);

  @override
  Widget build(BuildContext context) {
    return isCorrect ? _buildCorrect(context) : _buildWrong(context);
  }

  // ── 정답 피드백 ──
  Widget _buildCorrect(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFE8F5E9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 체크 아이콘
          Container(
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
          const SizedBox(height: 14),

          const Text(
            '정답이에요!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _primaryGreen,
            ),
          ),
          const SizedBox(height: 12),

          // 포인트 배지
          _PointBadge(points: points, color: _primaryGreen),
          const SizedBox(height: 8),

          // 연속 정답
          if (streak >= 3) ...[
            Text(
              '🔥 $streak연속 정답!',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFFE65100),
              ),
            ),
            if (streakBonus > 0) ...[
              const SizedBox(height: 4),
              Text(
                '+$streakBonus pt 연속 보너스!',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE65100),
                ),
              ),
            ],
            const SizedBox(height: 8),
          ],

          const SizedBox(height: 16),
          _DismissButton(onDismiss: onDismiss),
        ],
      ),
    );
  }

  // ── 오답 피드백 ──
  Widget _buildWrong(BuildContext context) {
    const wrongRed = Color(0xFFE53935);
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFCE4EC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 아쉬움 이모지
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: wrongRed.withValues(alpha: 0.1),
            ),
            child: const Center(
              child: Text('🤔', style: TextStyle(fontSize: 38)),
            ),
          ),
          const SizedBox(height: 14),

          const Text(
            '아쉽지만 괜찮아요!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: wrongRed,
            ),
          ),
          const SizedBox(height: 12),

          // 정답 표시
          if (choices.isNotEmpty && correctIndex < choices.length)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: wrongRed.withValues(alpha: 0.3)),
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
                    choices[correctIndex],
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
          if (explanation != null)
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
                    explanation!,
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

          // 참여 포인트
          const Text(
            '+1pt 참여 포인트',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
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
          _DismissButton(onDismiss: onDismiss),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// EmotionFeedback
// ──────────────────────────────────────────────

/// 감정 기록 완료 피드백
class EmotionFeedback extends StatelessWidget {
  const EmotionFeedback({
    super.key,
    required this.emoji,
    required this.label,
    required this.points,
    required this.onDismiss,
  });

  final String emoji;
  final String label;
  final int points;
  final VoidCallback onDismiss;

  static const Color _primaryGreen = Color(0xFF2E7D32);
  static const Color _textDarkBrown = Color(0xFF3E2723);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFF8E1),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 큰 이모지
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),

          // 기분 메시지
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 18, color: _textDarkBrown),
              children: [
                const TextSpan(text: "'"),
                TextSpan(
                  text: label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _primaryGreen,
                  ),
                ),
                const TextSpan(text: "' 기분이군요!"),
              ],
            ),
          ),
          const SizedBox(height: 8),

          const Text(
            '기분을 알려줘서 고마워요!',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF5D4037),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),

          // 포인트 배지
          _PointBadge(points: points, color: _primaryGreen),
          const SizedBox(height: 24),

          _DismissButton(onDismiss: onDismiss),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// 공통 위젯
// ──────────────────────────────────────────────

class _PointBadge extends StatelessWidget {
  const _PointBadge({required this.points, required this.color});

  final int points;
  final Color color;

  @override
  Widget build(BuildContext context) {
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
}

class _DismissButton extends StatelessWidget {
  const _DismissButton({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onDismiss,
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
}
