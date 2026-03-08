import 'package:equatable/equatable.dart';

// ──────────────────────────────────────────────
// Enums
// ──────────────────────────────────────────────

enum QuizSubject { math, science, english, korean }

enum QuizType { multipleChoice, oxQuiz, emotionCheck }

enum DifficultyLevel {
  age4,
  age5,
  age6,
  age7,
  grade1,
  grade2,
  grade3,
  grade4,
  grade5,
  grade6;

  /// gradeLevel 정수값 → DifficultyLevel 변환
  /// 0→age4, 1→age5, 2→age6, 3→age7, 4→grade1, 5→grade2, 6→grade3
  /// 그 이상은 grade4~grade6으로 클램프
  factory DifficultyLevel.fromGradeLevel(int gradeLevel) {
    switch (gradeLevel) {
      case 0:
        return DifficultyLevel.age4;
      case 1:
        return DifficultyLevel.age5;
      case 2:
        return DifficultyLevel.age6;
      case 3:
        return DifficultyLevel.age7;
      case 4:
        return DifficultyLevel.grade1;
      case 5:
        return DifficultyLevel.grade2;
      case 6:
        return DifficultyLevel.grade3;
      case 7:
        return DifficultyLevel.grade4;
      case 8:
        return DifficultyLevel.grade5;
      case 9:
        return DifficultyLevel.grade6;
      default:
        if (gradeLevel < 0) return DifficultyLevel.age4;
        return DifficultyLevel.grade6;
    }
  }
}

// ──────────────────────────────────────────────
// QuizQuestion
// ──────────────────────────────────────────────

class QuizQuestion extends Equatable {
  const QuizQuestion({
    required this.id,
    required this.type,
    required this.difficulty,
    required this.questionText,
    required this.choices,
    required this.correctIndex,
    this.subject,
    this.hint,
    this.explanation,
    this.relatedSpecies,
    this.basePoints = 10,
  });

  final String id;
  final QuizType type; // multipleChoice or oxQuiz
  final QuizSubject? subject;
  final DifficultyLevel difficulty;
  final String questionText;
  final List<String> choices; // 4지선다 또는 ["O", "X"]
  final int correctIndex;
  final String? hint;
  final String? explanation;
  final String? relatedSpecies; // 자연 연계 종 이름
  final int basePoints;

  QuizQuestion copyWith({
    String? id,
    QuizType? type,
    QuizSubject? subject,
    DifficultyLevel? difficulty,
    String? questionText,
    List<String>? choices,
    int? correctIndex,
    String? hint,
    String? explanation,
    String? relatedSpecies,
    int? basePoints,
  }) {
    return QuizQuestion(
      id: id ?? this.id,
      type: type ?? this.type,
      subject: subject ?? this.subject,
      difficulty: difficulty ?? this.difficulty,
      questionText: questionText ?? this.questionText,
      choices: choices ?? this.choices,
      correctIndex: correctIndex ?? this.correctIndex,
      hint: hint ?? this.hint,
      explanation: explanation ?? this.explanation,
      relatedSpecies: relatedSpecies ?? this.relatedSpecies,
      basePoints: basePoints ?? this.basePoints,
    );
  }

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String,
      type: QuizType.values.firstWhere(
        (e) => e.name == json['type'] as String,
      ),
      subject: json['subject'] != null
          ? QuizSubject.values.firstWhere(
              (e) => e.name == json['subject'] as String,
            )
          : null,
      difficulty: DifficultyLevel.values.firstWhere(
        (e) => e.name == json['difficulty'] as String,
      ),
      questionText: json['question_text'] as String,
      choices: List<String>.from(json['choices'] as List),
      correctIndex: json['correct_index'] as int,
      hint: json['hint'] as String?,
      explanation: json['explanation'] as String?,
      relatedSpecies: json['related_species'] as String?,
      basePoints: json['base_points'] as int? ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'subject': subject?.name,
      'difficulty': difficulty.name,
      'question_text': questionText,
      'choices': choices,
      'correct_index': correctIndex,
      'hint': hint,
      'explanation': explanation,
      'related_species': relatedSpecies,
      'base_points': basePoints,
    };
  }

  @override
  List<Object?> get props => [
        id,
        type,
        subject,
        difficulty,
        questionText,
        choices,
        correctIndex,
        hint,
        explanation,
        relatedSpecies,
        basePoints,
      ];
}

// ──────────────────────────────────────────────
// EmotionChoice
// ──────────────────────────────────────────────

class EmotionChoice extends Equatable {
  const EmotionChoice({
    required this.emoji,
    required this.label,
    this.followUp,
  });

  final String emoji;
  final String label;
  final String? followUp; // 후속 질문 (nullable)

  EmotionChoice copyWith({
    String? emoji,
    String? label,
    String? followUp,
  }) {
    return EmotionChoice(
      emoji: emoji ?? this.emoji,
      label: label ?? this.label,
      followUp: followUp ?? this.followUp,
    );
  }

  factory EmotionChoice.fromJson(Map<String, dynamic> json) {
    return EmotionChoice(
      emoji: json['emoji'] as String,
      label: json['label'] as String,
      followUp: json['follow_up'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emoji': emoji,
      'label': label,
      'follow_up': followUp,
    };
  }

  @override
  List<Object?> get props => [emoji, label, followUp];
}

// ──────────────────────────────────────────────
// EmotionQuestion
// ──────────────────────────────────────────────

class EmotionQuestion extends Equatable {
  const EmotionQuestion({
    required this.id,
    required this.questionText,
    required this.choices,
    this.basePoints = 5,
  });

  final String id;
  final String questionText;
  final List<EmotionChoice> choices; // 6개 이모지
  final int basePoints;

  EmotionQuestion copyWith({
    String? id,
    String? questionText,
    List<EmotionChoice>? choices,
    int? basePoints,
  }) {
    return EmotionQuestion(
      id: id ?? this.id,
      questionText: questionText ?? this.questionText,
      choices: choices ?? this.choices,
      basePoints: basePoints ?? this.basePoints,
    );
  }

  factory EmotionQuestion.fromJson(Map<String, dynamic> json) {
    return EmotionQuestion(
      id: json['id'] as String,
      questionText: json['question_text'] as String,
      choices: (json['choices'] as List)
          .map((e) => EmotionChoice.fromJson(e as Map<String, dynamic>))
          .toList(),
      basePoints: json['base_points'] as int? ?? 5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_text': questionText,
      'choices': choices.map((e) => e.toJson()).toList(),
      'base_points': basePoints,
    };
  }

  @override
  List<Object?> get props => [id, questionText, choices, basePoints];
}

// ──────────────────────────────────────────────
// QuizResult
// ──────────────────────────────────────────────

class QuizResult extends Equatable {
  const QuizResult({
    required this.id,
    required this.questionId,
    required this.type,
    required this.isCorrect,
    required this.earnedPoints,
    required this.streakBonus,
    required this.answeredAt,
    required this.triggerSource,
    this.subject,
  });

  final String id;
  final String questionId;
  final QuizType type;
  final QuizSubject? subject;
  final bool isCorrect;
  final int earnedPoints;
  final int streakBonus;
  final DateTime answeredAt;
  final String triggerSource; // 'identify', 'dashboard', 'diary'

  QuizResult copyWith({
    String? id,
    String? questionId,
    QuizType? type,
    QuizSubject? subject,
    bool? isCorrect,
    int? earnedPoints,
    int? streakBonus,
    DateTime? answeredAt,
    String? triggerSource,
  }) {
    return QuizResult(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      type: type ?? this.type,
      subject: subject ?? this.subject,
      isCorrect: isCorrect ?? this.isCorrect,
      earnedPoints: earnedPoints ?? this.earnedPoints,
      streakBonus: streakBonus ?? this.streakBonus,
      answeredAt: answeredAt ?? this.answeredAt,
      triggerSource: triggerSource ?? this.triggerSource,
    );
  }

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      id: json['id'] as String,
      questionId: json['question_id'] as String,
      type: QuizType.values.firstWhere(
        (e) => e.name == json['type'] as String,
      ),
      subject: json['subject'] != null
          ? QuizSubject.values.firstWhere(
              (e) => e.name == json['subject'] as String,
            )
          : null,
      isCorrect: json['is_correct'] as bool,
      earnedPoints: json['earned_points'] as int,
      streakBonus: json['streak_bonus'] as int,
      answeredAt: DateTime.parse(json['answered_at'] as String),
      triggerSource: json['trigger_source'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'type': type.name,
      'subject': subject?.name,
      'is_correct': isCorrect,
      'earned_points': earnedPoints,
      'streak_bonus': streakBonus,
      'answered_at': answeredAt.toIso8601String(),
      'trigger_source': triggerSource,
    };
  }

  @override
  List<Object?> get props => [
        id,
        questionId,
        type,
        subject,
        isCorrect,
        earnedPoints,
        streakBonus,
        answeredAt,
        triggerSource,
      ];
}

// ──────────────────────────────────────────────
// QuizHistory (in-memory, not Equatable)
// ──────────────────────────────────────────────

class QuizHistory {
  QuizHistory({
    DifficultyLevel? currentDifficulty,
  }) : currentDifficulty = currentDifficulty ?? DifficultyLevel.age6;

  List<QuizResult> results = [];
  int currentStreak = 0;
  Set<String> wrongQuestionIds = {};
  DifficultyLevel currentDifficulty;
  DateTime? lastDashboardQuizTime;
  int todayDashboardQuizCount = 0;
  DateTime? _lastCountDate;

  /// 결과 추가 후 streak·wrongIds 갱신
  void addResult(QuizResult result) {
    results.add(result);
    if (result.isCorrect) {
      currentStreak++;
      wrongQuestionIds.remove(result.questionId);
    } else {
      currentStreak = 0;
      wrongQuestionIds.add(result.questionId);
    }
    if (result.triggerSource == 'dashboard') {
      resetDailyCountIfNeeded();
      todayDashboardQuizCount++;
      lastDashboardQuizTime = result.answeredAt;
    }
  }

  /// 날짜가 바뀌면 일별 카운트 리셋
  void resetDailyCountIfNeeded() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (_lastCountDate == null || _lastCountDate!.isBefore(today)) {
      todayDashboardQuizCount = 0;
      _lastCountDate = today;
    }
  }
}

// ──────────────────────────────────────────────
// EmotionReport
// ──────────────────────────────────────────────

class EmotionReport extends Equatable {
  const EmotionReport({
    required this.date,
    required this.emoji,
    required this.label,
    required this.triggerSource,
    this.followUpAnswer,
  });

  final DateTime date;
  final String emoji;
  final String label;
  final String? followUpAnswer;
  final String triggerSource;

  EmotionReport copyWith({
    DateTime? date,
    String? emoji,
    String? label,
    String? followUpAnswer,
    String? triggerSource,
  }) {
    return EmotionReport(
      date: date ?? this.date,
      emoji: emoji ?? this.emoji,
      label: label ?? this.label,
      followUpAnswer: followUpAnswer ?? this.followUpAnswer,
      triggerSource: triggerSource ?? this.triggerSource,
    );
  }

  factory EmotionReport.fromJson(Map<String, dynamic> json) {
    return EmotionReport(
      date: DateTime.parse(json['date'] as String),
      emoji: json['emoji'] as String,
      label: json['label'] as String,
      followUpAnswer: json['follow_up_answer'] as String?,
      triggerSource: json['trigger_source'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'emoji': emoji,
      'label': label,
      'follow_up_answer': followUpAnswer,
      'trigger_source': triggerSource,
    };
  }

  @override
  List<Object?> get props => [date, emoji, label, followUpAnswer, triggerSource];
}
