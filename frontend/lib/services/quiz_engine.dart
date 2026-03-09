import 'dart:math';
import '../config/constants.dart';
import '../models/quiz.dart';
import '../data/quiz_bank.dart';

class QuizEngine {
  QuizEngine._();

  static final _random = Random();

  /// 퀴즈를 보여줄지 확률 판정
  /// 트리거별 확률 + 대시보드 쿨다운/일일 제한 적용
  static bool shouldShowQuiz(String trigger, QuizHistory history) {
    // 첫 퀴즈는 무조건 출제 (온보딩 효과)
    if (history.results.isEmpty) return true;

    // 대시보드 트리거: 쿨다운 + 일일 제한 체크
    if (trigger == 'dashboard') {
      // 일일 최대 횟수 초과
      if (history.todayDashboardQuizCount >= AppConstants.quizDashboardMaxPerDay) {
        return false;
      }
      // 쿨다운 체크
      if (history.lastDashboardQuizTime != null) {
        final elapsed = DateTime.now().difference(history.lastDashboardQuizTime!);
        if (elapsed.inHours < AppConstants.quizDashboardCooldownHours) {
          return false;
        }
      }
    }

    // 트리거별 확률 적용
    final double probability;
    switch (trigger) {
      case 'dashboard':
        probability = AppConstants.quizDashboardProbability;
      case 'identify':
        probability = AppConstants.quizIdentifyProbability;
      case 'diary':
        probability = AppConstants.quizDiaryProbability;
      default:
        probability = 0.15;
    }

    return _random.nextDouble() < probability;
  }

  /// 문제 선택 (70% 학습 / 30% 감정, diary 트리거면 50%:50%)
  /// 오답 문제 30% 확률로 재출제
  static dynamic selectQuestion(
    DifficultyLevel difficulty,
    QuizHistory history, {
    String? species,
    String trigger = 'identify',
  }) {
    // 감정 체크 비율 결정 (diary: 50%, 나머지: 30%)
    final emotionRatio = trigger == 'diary' ? 0.50 : 0.30;

    if (_random.nextDouble() < emotionRatio) {
      // 감정 문제 선택
      final emotions = QuizBank.emotionQuestions;
      return emotions[_random.nextInt(emotions.length)];
    }

    // 학습 문제 선택
    // 1) 오답 재출제 (30%)
    if (history.wrongQuestionIds.isNotEmpty &&
        _random.nextDouble() < 0.30) {
      final allQuestions = QuizBank.getQuestionsForDifficulty(difficulty);
      final wrongOnes = allQuestions
          .where((q) => history.wrongQuestionIds.contains(q.id))
          .toList();
      if (wrongOnes.isNotEmpty) {
        return wrongOnes[_random.nextInt(wrongOnes.length)];
      }
    }

    // 2) 종 관련 문제 우선 (species 전달 시)
    if (species != null) {
      final speciesQuestions = QuizBank.getQuestionsForSpecies(species);
      if (speciesQuestions.isNotEmpty) {
        return speciesQuestions[_random.nextInt(speciesQuestions.length)];
      }
    }

    // 3) 난이도 혼합 문제 (50% 현재 / 30% +1 / 20% +2)
    final questions = _buildMixedPool(difficulty);
    if (questions.isEmpty) {
      // fallback: grade2 난이도
      final allQ =
          QuizBank.getQuestionsForDifficulty(DifficultyLevel.grade2);
      if (allQ.isNotEmpty) return allQ[_random.nextInt(allQ.length)];
      return QuizBank.emotionQuestions.first;
    }

    // 이미 푼 문제 제외 시도
    final unanswered = questions
        .where(
          (q) => !history.results.any((r) => r.questionId == q.id),
        )
        .toList();

    if (unanswered.isNotEmpty) {
      return unanswered[_random.nextInt(unanswered.length)];
    }
    return questions[_random.nextInt(questions.length)];
  }

  /// 난이도 혼합 풀 구성 (50% 현재 / 30% +1 / 20% +2)
  static List<QuizQuestion> _buildMixedPool(DifficultyLevel base) {
    final values = DifficultyLevel.values;
    final baseIdx = values.indexOf(base);
    final maxIdx = values.length - 1;

    // 상위 레벨 계산 (최대값 클램핑)
    final level1 = values[baseIdx + 1 > maxIdx ? maxIdx : baseIdx + 1];
    final level2 = values[baseIdx + 2 > maxIdx ? maxIdx : baseIdx + 2];

    final baseQuestions = QuizBank.getQuestionsForDifficulty(base);
    final level1Questions = QuizBank.getQuestionsForDifficulty(level1);
    final level2Questions = QuizBank.getQuestionsForDifficulty(level2);

    final pool = <QuizQuestion>[];

    // 50/30/20 비율로 선택
    final roll = _random.nextDouble();
    if (roll < 0.50 && baseQuestions.isNotEmpty) {
      pool.addAll(baseQuestions);
    } else if (roll < 0.80 && level1Questions.isNotEmpty) {
      pool.addAll(level1Questions);
    } else if (level2Questions.isNotEmpty) {
      pool.addAll(level2Questions);
    }

    // pool이 비었으면 base 레벨로 fallback
    if (pool.isEmpty) {
      pool.addAll(baseQuestions);
    }

    return pool;
  }

  /// 난이도 조절: 5연속 정답→올림, 3연속 오답→내림
  static DifficultyLevel adjustDifficulty(QuizHistory history) {
    final current = history.currentDifficulty;
    const values = DifficultyLevel.values;
    final currentIdx = values.indexOf(current);

    // 최근 결과 확인 (학습 퀴즈만)
    final recentLearning = history.results
        .where((r) => r.type != QuizType.emotionCheck)
        .toList();

    if (recentLearning.length >= 5) {
      final last5 = recentLearning.sublist(recentLearning.length - 5);
      if (last5.every((r) => r.isCorrect) &&
          currentIdx < values.length - 1) {
        return values[currentIdx + 1]; // 올림
      }
    }
    if (recentLearning.length >= 3) {
      final last3 = recentLearning.sublist(recentLearning.length - 3);
      if (last3.every((r) => !r.isCorrect) && currentIdx > 0) {
        return values[currentIdx - 1]; // 내림
      }
    }
    return current;
  }

  /// 포인트 계산
  static int calculatePoints({
    required bool isCorrect,
    required int streak,
    required bool isRetry,
  }) {
    if (!isCorrect) return 1; // 오답 참여 포인트

    var points = 10; // 기본 정답 포인트
    if (isRetry) points += 3; // 오답 재출제 정답 보너스

    // 연속 정답 보너스
    if (streak >= 10) {
      points += 20;
    } else if (streak >= 5) {
      points += 10;
    } else if (streak >= 3) {
      points += 5;
    }

    return points;
  }
}
