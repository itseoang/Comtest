import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../../models/quiz.dart';
import '../../services/quiz_engine.dart';

// ─── Events ───────────────────────────────────

abstract class QuizEvent extends Equatable {
  const QuizEvent();
  @override
  List<Object?> get props => [];
}

/// 퀴즈 트리거 체크 (화면 진입 등)
class CheckQuizTrigger extends QuizEvent {
  const CheckQuizTrigger({required this.trigger, this.species});

  /// 트리거 종류: 'identify', 'dashboard', 'diary'
  final String trigger;

  /// 관련 종 이름 (선택)
  final String? species;

  @override
  List<Object?> get props => [trigger, species];
}

/// 학습 퀴즈 답변 제출
class SubmitAnswer extends QuizEvent {
  const SubmitAnswer({required this.selectedIndex});

  final int selectedIndex;

  @override
  List<Object?> get props => [selectedIndex];
}

/// 감정 체크 답변 제출
class SubmitEmotion extends QuizEvent {
  const SubmitEmotion({required this.selectedIndex, this.followUpAnswer});

  final int selectedIndex;
  final String? followUpAnswer;

  @override
  List<Object?> get props => [selectedIndex, followUpAnswer];
}

/// 퀴즈 닫기
class DismissQuiz extends QuizEvent {
  const DismissQuiz();
}

// ─── States ───────────────────────────────────

abstract class QuizState extends Equatable {
  const QuizState();
  @override
  List<Object?> get props => [];
}

/// 퀴즈 비활성 상태 (초기 및 닫힘)
class QuizIdle extends QuizState {
  const QuizIdle();
}

/// 퀴즈 문제 표시 준비 완료
class QuizReady extends QuizState {
  const QuizReady({
    required this.question,
    required this.isEmotion,
    required this.trigger,
  });

  /// QuizQuestion 또는 EmotionQuestion
  final dynamic question;
  final bool isEmotion;

  /// 트리거 종류: 'identify', 'dashboard', 'diary'
  final String trigger;

  @override
  List<Object?> get props => [question, isEmotion, trigger];
}

/// 학습 퀴즈 답변 완료
class QuizAnswered extends QuizState {
  const QuizAnswered({
    required this.isCorrect,
    required this.points,
    required this.streak,
    required this.correctIndex,
    this.explanation,
  });

  final bool isCorrect;
  final int points;
  final int streak;
  final String? explanation;
  final int correctIndex;

  @override
  List<Object?> get props => [
        isCorrect,
        points,
        streak,
        explanation,
        correctIndex,
      ];
}

/// 감정 체크 완료
class EmotionRecorded extends QuizState {
  const EmotionRecorded({
    required this.points,
    required this.emoji,
    required this.label,
  });

  final int points;
  final String emoji;
  final String label;

  @override
  List<Object?> get props => [points, emoji, label];
}

// ─── BLoC ─────────────────────────────────────

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  QuizBloc({DifficultyLevel initialDifficulty = DifficultyLevel.grade2})
      : _history = QuizHistory(currentDifficulty: initialDifficulty),
        super(const QuizIdle()) {
    on<CheckQuizTrigger>(_onCheckTrigger);
    on<SubmitAnswer>(_onSubmitAnswer);
    on<SubmitEmotion>(_onSubmitEmotion);
    on<DismissQuiz>(_onDismiss);
  }

  final QuizHistory _history;

  /// 현재 출제된 문제 (QuizQuestion 또는 EmotionQuestion)
  dynamic _currentQuestion;

  String _currentTrigger = '';

  /// 퀴즈 이력 (읽기 전용 노출)
  QuizHistory get history => _history;

  /// 감정 기록 목록
  List<EmotionReport> emotionReports = [];

  /// 외부에서 난이도 직접 조정 (프로필 설정 등)
  void updateDifficulty(DifficultyLevel level) {
    _history.currentDifficulty = level;
  }

  Future<void> _onCheckTrigger(
    CheckQuizTrigger event,
    Emitter<QuizState> emit,
  ) async {
    debugPrint('[QuizBloc] CheckQuizTrigger: ${event.trigger}, history empty: ${_history.results.isEmpty}');
    if (!QuizEngine.shouldShowQuiz(event.trigger, _history)) {
      debugPrint('[QuizBloc] shouldShowQuiz returned false');
      return;
    }
    debugPrint('[QuizBloc] shouldShowQuiz returned true, selecting question...');

    _currentTrigger = event.trigger;
    final question = QuizEngine.selectQuestion(
      _history.currentDifficulty,
      _history,
      species: event.species,
      trigger: event.trigger,
    );
    _currentQuestion = question;

    if (event.trigger == 'dashboard') {
      _history.lastDashboardQuizTime = DateTime.now();
      _history.todayDashboardQuizCount++;
    }

    final isEmotion = question is EmotionQuestion;
    debugPrint('[QuizBloc] Emitting QuizReady: isEmotion=$isEmotion, trigger=${event.trigger}');
    emit(QuizReady(
      question: question,
      isEmotion: isEmotion,
      trigger: event.trigger,
    ));
  }

  Future<void> _onSubmitAnswer(
    SubmitAnswer event,
    Emitter<QuizState> emit,
  ) async {
    if (_currentQuestion is! QuizQuestion) return;
    final q = _currentQuestion as QuizQuestion;

    final isCorrect = event.selectedIndex == q.correctIndex;
    final isRetry = _history.wrongQuestionIds.contains(q.id);

    if (isCorrect) {
      _history.currentStreak++;
      _history.wrongQuestionIds.remove(q.id);
    } else {
      _history.currentStreak = 0;
      _history.wrongQuestionIds.add(q.id);
    }

    final points = QuizEngine.calculatePoints(
      isCorrect: isCorrect,
      streak: _history.currentStreak,
      isRetry: isRetry,
    );

    // streakBonus: 정답 + 연속 3회 이상인 경우에만 보너스 존재
    final streakBonus = isCorrect && _history.currentStreak >= 3
        ? (points - 10 - (isRetry ? 3 : 0))
        : 0;

    final result = QuizResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      questionId: q.id,
      type: q.type,
      subject: q.subject,
      isCorrect: isCorrect,
      earnedPoints: points,
      streakBonus: streakBonus,
      answeredAt: DateTime.now(),
      triggerSource: _currentTrigger,
    );
    _history.addResult(result);

    // 난이도 자동 조절
    _history.currentDifficulty = QuizEngine.adjustDifficulty(_history);

    emit(QuizAnswered(
      isCorrect: isCorrect,
      points: points,
      streak: _history.currentStreak,
      explanation: q.explanation,
      correctIndex: q.correctIndex,
    ));
  }

  Future<void> _onSubmitEmotion(
    SubmitEmotion event,
    Emitter<QuizState> emit,
  ) async {
    if (_currentQuestion is! EmotionQuestion) return;
    final q = _currentQuestion as EmotionQuestion;

    final choice = q.choices[event.selectedIndex];

    emotionReports.add(EmotionReport(
      date: DateTime.now(),
      emoji: choice.emoji,
      label: choice.label,
      followUpAnswer: event.followUpAnswer,
      triggerSource: _currentTrigger,
    ));

    emit(EmotionRecorded(
      points: q.basePoints,
      emoji: choice.emoji,
      label: choice.label,
    ));
  }

  Future<void> _onDismiss(
    DismissQuiz event,
    Emitter<QuizState> emit,
  ) async {
    emit(const QuizIdle());
  }
}
