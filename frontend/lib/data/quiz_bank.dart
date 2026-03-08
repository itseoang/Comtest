import '../models/quiz.dart';

// ──────────────────────────────────────────────
// QuizBank
// 자연도감 앱 퀴즈 문제 은행 (~80문제 + 감정 질문 10개)
// ──────────────────────────────────────────────

class QuizBank {
  QuizBank._();

  // ─── 조회 메서드 ───

  /// 난이도별 학습 문제 목록
  static List<QuizQuestion> getQuestionsForDifficulty(DifficultyLevel difficulty) {
    return _learningQuestions.where((q) => q.difficulty == difficulty).toList();
  }

  /// 특정 종과 관련된 문제
  static List<QuizQuestion> getQuestionsForSpecies(String speciesName) {
    return _learningQuestions
        .where((q) =>
            q.relatedSpecies != null && q.relatedSpecies!.contains(speciesName))
        .toList();
  }

  /// 과목별 문제
  static List<QuizQuestion> getQuestionsForSubject(QuizSubject subject) {
    return _learningQuestions.where((q) => q.subject == subject).toList();
  }

  /// 감정 질문 목록
  static List<EmotionQuestion> get emotionQuestions =>
      List.unmodifiable(_emotionQuestions);

  /// 전체 학습 문제
  static List<QuizQuestion> get allQuestions =>
      List.unmodifiable(_learningQuestions);

  // ─── 학습 문제 데이터 ───

  static const List<QuizQuestion> _learningQuestions = [
    // ════════════════════════════════════════
    // 유아 (age4)
    // ════════════════════════════════════════

    // age4 — 수학
    QuizQuestion(
      id: 'math_age4_01',
      type: QuizType.multipleChoice,
      subject: QuizSubject.math,
      difficulty: DifficultyLevel.age4,
      questionText: '나비 날개는 모두 몇 개일까요?',
      choices: ['2개', '4개', '6개', '8개'],
      correctIndex: 1,
      hint: '양쪽에 2개씩 있어요',
      explanation: '나비는 앞날개 2개, 뒷날개 2개로 총 4개의 날개를 가지고 있어요.',
      relatedSpecies: '나비',
      basePoints: 10,
    ),

    // age4 — 과학
    QuizQuestion(
      id: 'sci_age4_01',
      type: QuizType.multipleChoice,
      subject: QuizSubject.science,
      difficulty: DifficultyLevel.age4,
      questionText: '이 중에서 식물은 무엇일까요?',
      choices: ['강아지', '나비', '민들레', '참새'],
      correctIndex: 2,
      hint: '땅에 뿌리를 내리고 사는 것은 무엇일까요?',
      explanation: '민들레는 식물이에요. 강아지, 나비, 참새는 모두 동물이랍니다.',
      relatedSpecies: '민들레',
      basePoints: 10,
    ),

    // age4 — 영어
    QuizQuestion(
      id: 'eng_age4_01',
      type: QuizType.multipleChoice,
      subject: QuizSubject.english,
      difficulty: DifficultyLevel.age4,
      questionText: "'Butterfly'는 어떤 동물일까요?",
      choices: ['새', '나비', '물고기', '개구리'],
      correctIndex: 1,
      hint: '꽃밭에서 날아다니는 예쁜 곤충이에요',
      explanation: 'Butterfly는 나비예요. 꽃의 꿀을 먹으며 꽃가루를 옮겨줘요!',
      relatedSpecies: '나비',
      basePoints: 10,
    ),

    // age4 — 국어
    QuizQuestion(
      id: 'kor_age4_01',
      type: QuizType.multipleChoice,
      subject: QuizSubject.korean,
      difficulty: DifficultyLevel.age4,
      questionText: "'동물'과 같은 종류의 말은 무엇일까요?",
      choices: ['자동차', '식물', '연필', '컴퓨터'],
      correctIndex: 1,
      hint: '살아있는 것끼리 묶어보세요',
      explanation: "'동물'과 '식물'은 모두 살아있는 생물이에요. 둘 다 자연의 일부랍니다!",
      basePoints: 10,
    ),

    // ════════════════════════════════════════
    // 유아 (age5)
    // ════════════════════════════════════════

    // age5 — 수학
    QuizQuestion(
      id: 'math_age5_01',
      type: QuizType.multipleChoice,
      subject: QuizSubject.math,
      difficulty: DifficultyLevel.age5,
      questionText: '꽃잎이 5장인 꽃이 2송이 있으면 꽃잎은 모두 몇 장일까요?',
      choices: ['8장', '10장', '12장', '15장'],
      correctIndex: 1,
      hint: '5 + 5를 해보세요',
      explanation: '꽃잎 5장 × 2송이 = 10장이에요. 벚꽃도 꽃잎이 5장이랍니다!',
      relatedSpecies: '벚꽃',
      basePoints: 10,
    ),

    // age5 — 과학
    QuizQuestion(
      id: 'sci_age5_01',
      type: QuizType.multipleChoice,
      subject: QuizSubject.science,
      difficulty: DifficultyLevel.age5,
      questionText: '나무는 무엇을 마시고 자랄까요?',
      choices: ['우유', '물', '주스', '콜라'],
      correctIndex: 1,
      hint: '비가 오면 나무에게 좋은 것은 무엇일까요?',
      explanation: '나무는 뿌리로 물을 흡수해서 자라요. 물은 식물에게 꼭 필요해요!',
      basePoints: 10,
    ),

    // age5 — 영어
    QuizQuestion(
      id: 'eng_age5_01',
      type: QuizType.multipleChoice,
      subject: QuizSubject.english,
      difficulty: DifficultyLevel.age5,
      questionText: "'Flower'는 무슨 뜻일까요?",
      choices: ['나무', '꽃', '풀', '열매'],
      correctIndex: 1,
      hint: '봄에 활짝 피는 예쁜 것이에요',
      explanation: 'Flower는 꽃이에요. 꽃은 식물이 씨앗을 만들기 위해 피운답니다!',
      basePoints: 10,
    ),

    // age5 — 국어 (OX 퀴즈)
    QuizQuestion(
      id: 'kor_age5_01',
      type: QuizType.oxQuiz,
      subject: QuizSubject.korean,
      difficulty: DifficultyLevel.age5,
      questionText: '장미꽃은 빨간색이다. (O/X)',
      choices: ['O', 'X'],
      correctIndex: 0,
      hint: '꽃집에서 자주 보이는 빨간 꽃을 떠올려보세요',
      explanation: '장미는 빨간색, 분홍색, 노란색 등 다양하지만 가장 대표적인 색은 빨간색이에요.',
      relatedSpecies: '장미',
      basePoints: 10,
    ),

    // ════════════════════════════════════════
    // 유아 (age6)
    // ════════════════════════════════════════

    // age6 — 수학
    QuizQuestion(
      id: 'math_age6_01',
      type: QuizType.multipleChoice,
      subject: QuizSubject.math,
      difficulty: DifficultyLevel.age6,
      questionText: '개구리의 다리는 몇 개일까요?',
      choices: ['2개', '4개', '6개', '8개'],
      correctIndex: 1,
      hint: '앞다리와 뒷다리를 세어보세요',
      explanation: '개구리는 앞다리 2개, 뒷다리 2개로 총 4개의 다리를 가지고 있어요.',
      relatedSpecies: '개구리',
      basePoints: 10,
    ),

    // age6 — 과학
    QuizQuestion(
      id: 'sci_age6_01',
      type: QuizType.multipleChoice,
      subject: QuizSubject.science,
      difficulty: DifficultyLevel.age6,
      questionText: '겨울에 잠을 자는 동물은 어떤 것일까요?',
      choices: ['참새', '개구리', '고양이', '닭'],
      correctIndex: 1,
      hint: '날씨가 추워지면 숨어서 봄까지 기다리는 동물이에요',
      explanation: '개구리는 변온동물이라 겨울에는 땅속이나 돌 밑에서 겨울잠을 자요.',
      relatedSpecies: '개구리',
      basePoints: 10,
    ),

    // age6 — 영어
    QuizQuestion(
      id: 'eng_age6_01',
      type: QuizType.multipleChoice,
      subject: QuizSubject.english,
      difficulty: DifficultyLevel.age6,
      questionText: "'Frog'은 어떤 동물일까요?",
      choices: ['개구리', '토끼', '거북이', '뱀'],
      correctIndex: 0,
      hint: '연못에서 "개굴개굴" 소리를 내는 동물이에요',
      explanation: 'Frog는 개구리예요. 물과 땅 모두에서 살 수 있는 양서류랍니다!',
      relatedSpecies: '개구리',
      basePoints: 10,
    ),

    // age6 — 국어
    QuizQuestion(
      id: 'kor_age6_01',
      type: QuizType.multipleChoice,
      subject: QuizSubject.korean,
      difficulty: DifficultyLevel.age6,
      questionText: "'나무가 크다'에서 '크다'는 무엇을 나타내는 말일까요?",
      choices: ['이름', '모습', '행동', '소리'],
      correctIndex: 1,
      hint: '나무의 어떤 점을 말해주는 걸까요?',
      explanation: "'크다'는 나무의 모습(형태)을 나타내는 말이에요. 이런 말을 형용사라고 해요.",
      basePoints: 10,
    ),

    // ════════════════════════════════════════
    // 초등 1학년 (grade1)
    // ════════════════════════════════════════

    // grade1 — 수학
    QuizQuestion(
      id: 'math_g1_01',
      type: QuizType.multipleChoice,
      subject: QuizSubject.math,
      difficulty: DifficultyLevel.grade1,
      questionText: '꽃잎이 5장인 꽃이 3송이 있어요. 꽃잎은 모두 몇 장일까요?',
      choices: ['10장', '15장', '20장', '25장'],
      correctIndex: 1,
      hint: '5장씩 3번 더해보세요',
      explanation: '5장 × 3송이 = 15장이에요. 벚꽃처럼 꽃잎이 5장인 꽃이 많아요!',
      relatedSpecies: '벚꽃',
      basePoints: 10,
    ),

    QuizQuestion(
      id: 'math_g1_02',
      type: QuizType.multipleChoice,
      subject: QuizSubject.math,
      difficulty: DifficultyLevel.grade1,
      questionText: '나뭇가지에 새가 4마리 앉아 있었는데 3마리가 더 날아왔어요. 모두 몇 마리일까요?',
      choices: ['5마리', '6마리', '7마리', '8마리'],
      correctIndex: 2,
      hint: '4에서 3을 더해보세요',
      explanation: '4 + 3 = 7마리예요. 덧셈은 두 수를 합치는 것이에요!',
      basePoints: 10,
    ),

    // grade1 — 과학
    QuizQuestion(
      id: 'sci_g1_01',
      type: QuizType.multipleChoice,
      subject: QuizSubject.science,
      difficulty: DifficultyLevel.grade1,
      questionText: '식물이 자라는 데 필요하지 않은 것은 무엇일까요?',
      choices: ['물', '햇빛', '사탕', '흙'],
      correctIndex: 2,
      hint: '사람이 먹는 것은 식물에겐 필요 없어요',
      explanation: '식물은 물, 햇빛, 흙(영양분)이 필요해요. 사탕은 사람이 먹는 것이랍니다!',
      basePoints: 10,
    ),

    QuizQuestion(
      id: 'sci_g1_02',
      type: QuizType.multipleChoice,
      subject: QuizSubject.science,
      difficulty: DifficultyLevel.grade1,
      questionText: '씨앗을 심으면 가장 먼저 나오는 것은 무엇일까요?',
      choices: ['꽃', '열매', '뿌리', '잎'],
      correctIndex: 2,
      hint: '땅속으로 먼저 내려가는 것을 생각해보세요',
      explanation: '씨앗이 발아할 때 뿌리가 가장 먼저 나와요. 뿌리는 물과 영양분을 흡수해요!',
      basePoints: 10,
    ),

    // grade1 — 영어
    QuizQuestion(
      id: 'eng_g1_01',
      type: QuizType.multipleChoice,
      subject: QuizSubject.english,
      difficulty: DifficultyLevel.grade1,
      questionText: "'Tree'의 뜻은 무엇일까요?",
      choices: ['꽃', '나무', '풀', '숲'],
      correctIndex: 1,
      hint: '키가 크고 줄기가 굵은 식물이에요',
      explanation: 'Tree는 나무예요. 나무는 오랜 시간 자라면서 우리에게 공기와 그늘을 줘요!',
      basePoints: 10,
    ),

    // grade1 — 국어
    QuizQuestion(
      id: 'kor_g1_01',
      type: QuizType.multipleChoice,
      subject: QuizSubject.korean,
      difficulty: DifficultyLevel.grade1,
      questionText: "'예쁜 꽃이 피었다'에서 꽃을 꾸며주는 말은 무엇일까요?",
      choices: ['예쁜', '꽃이', '피었다', '없음'],
      correctIndex: 0,
      hint: '꽃이 어떻다고 말해주는 단어를 찾아보세요',
      explanation: "'예쁜'은 꽃의 모습을 꾸며주는 말(꾸미는 말)이에요. 이런 말을 관형어라고 해요!",
      basePoints: 10,
    ),

    // ════════════════════════════════════════
    // 초등 2학년 (grade2)
    // ════════════════════════════════════════

    // grade2 — 수학
    QuizQuestion(
      id: 'math_g2_01',
      type: QuizType.multipleChoice,
      subject: QuizSubject.math,
      difficulty: DifficultyLevel.grade2,
      questionText: '자연 도감에 식물 8종과 동물 7종이 기록되어 있어요. 모두 몇 종일까요?',
      choices: ['13종', '14종', '15종', '16종'],
      correctIndex: 2,
      hint: '8과 7을 더해보세요',
      explanation: '8 + 7 = 15종이에요. 도감에 담긴 생물이 많을수록 더 풍성해져요!',
      basePoints: 10,
    ),

    QuizQuestion(
      id: 'math_g2_02',
      type: QuizType.multipleChoice,
      subject: QuizSubject.math,
      difficulty: DifficultyLevel.grade2,
      questionText: '나뭇잎 24장을 6명이 똑같이 나누면 한 명이 몇 장씩 가질 수 있을까요?',
      choices: ['3장', '4장', '5장', '6장'],
      correctIndex: 1,
      hint: '24를 6으로 나누어 보세요',
      explanation: '24 ÷ 6 = 4장이에요. 나눗셈은 똑같이 나눌 때 사용해요!',
      basePoints: 10,
    ),

    // grade2 — 과학
    QuizQuestion(
      id: 'sci_g2_01',
      type: QuizType.multipleChoice,
      subject: QuizSubject.science,
      difficulty: DifficultyLevel.grade2,
      questionText: '곤충의 다리는 몇 개일까요?',
      choices: ['4개', '6개', '8개', '10개'],
      correctIndex: 1,
      hint: '무당벌레를 자세히 보면 알 수 있어요',
      explanation: '모든 곤충은 다리가 6개예요. 무당벌레, 개미, 나비 모두 다리가 6개랍니다!',
      relatedSpecies: '무당벌레',
      basePoints: 10,
    ),

    QuizQuestion(
      id: 'sci_g2_02',
      type: QuizType.multipleChoice,
      subject: QuizSubject.science,
      difficulty: DifficultyLevel.grade2,
      questionText: '다음 중 포유류가 아닌 동물은 무엇일까요?',
      choices: ['고양이', '개구리', '토끼', '강아지'],
      correctIndex: 1,
      hint: '포유류는 새끼를 낳고 젖을 먹여 키워요',
      explanation: '개구리는 양서류예요. 고양이, 토끼, 강아지는 새끼를 낳는 포유류랍니다!',
      relatedSpecies: '개구리',
      basePoints: 10,
    ),

    // grade2 — 영어
    QuizQuestion(
      id: 'eng_g2_01',
      type: QuizType.multipleChoice,
      subject: QuizSubject.english,
      difficulty: DifficultyLevel.grade2,
      questionText: "'Bird'와 'Butterfly'의 공통점은 무엇일까요?",
      choices: ['날 수 있다', '헤엄칠 수 있다', '다리가 4개다', '겨울잠을 잔다'],
      correctIndex: 0,
      hint: '두 동물 모두 하늘에서 볼 수 있어요',
      explanation: '새(Bird)와 나비(Butterfly)는 모두 날 수 있어요. 하지만 새는 척추동물, 나비는 곤충이랍니다!',
      basePoints: 10,
    ),

    // grade2 — 국어
    QuizQuestion(
      id: 'kor_g2_01',
      type: QuizType.multipleChoice,
      subject: QuizSubject.korean,
      difficulty: DifficultyLevel.grade2,
      questionText: "'숲'과 비슷한 뜻을 가진 말은 무엇일까요?",
      choices: ['바다', '산림', '하늘', '강'],
      correctIndex: 1,
      hint: '나무가 많이 모여 있는 곳을 다른 말로 뭐라고 할까요?',
      explanation: "숲과 산림은 비슷한 말이에요. 이렇게 뜻이 비슷한 말을 '유의어'라고 해요!",
      basePoints: 10,
    ),

    // ════════════════════════════════════════
    // 초등 3학년 (grade3)
    // ════════════════════════════════════════

    // grade3 — 수학
    QuizQuestion(
      id: 'math_g3_01',
      type: QuizType.multipleChoice,
      subject: QuizSubject.math,
      difficulty: DifficultyLevel.grade3,
      questionText: '나무의 나이테가 12개라면 이 나무의 나이는 몇 살일까요?',
      choices: ['6살', '10살', '12살', '24살'],
      correctIndex: 2,
      hint: '나이테 1개 = 1년이에요',
      explanation: '나이테는 나무가 1년에 한 개씩 만들어요. 나이테가 12개면 12년 된 나무예요!',
      basePoints: 10,
    ),

    QuizQuestion(
      id: 'math_g3_02',
      type: QuizType.multipleChoice,
      subject: QuizSubject.math,
      difficulty: DifficultyLevel.grade3,
      questionText: '꽃밭의 가로가 5m, 세로가 3m라면 넓이는 몇 ㎡일까요?',
      choices: ['8㎡', '12㎡', '15㎡', '20㎡'],
      correctIndex: 2,
      hint: '넓이 = 가로 × 세로',
      explanation: '5m × 3m = 15㎡예요. 직사각형의 넓이는 가로와 세로를 곱해서 구해요!',
      basePoints: 10,
    ),

    QuizQuestion(
      id: 'math_g3_03',
      type: QuizType.multipleChoice,
      subject: QuizSubject.math,
      difficulty: DifficultyLevel.grade3,
      questionText: '자연 공원의 정사각형 코스에서 한 변이 400m라면 총 몇 m를 걸을까요?',
      choices: ['800m', '1200m', '1600m', '2000m'],
      correctIndex: 2,
      hint: '정사각형의 둘레 = 한 변 × 4',
      explanation: '400m × 4 = 1600m예요. 정사각형은 네 변의 길이가 모두 같아요!',
      basePoints: 10,
    ),

    // grade3 — 과학
    QuizQuestion(
      id: 'sci_g3_01',
      type: QuizType.multipleChoice,
      subject: QuizSubject.science,
      difficulty: DifficultyLevel.grade3,
      questionText: '다음 중 양서류가 아닌 동물은 무엇일까요?',
      choices: ['개구리', '도롱뇽', '두꺼비', '도마뱀'],
      correctIndex: 3,
      hint: '양서류는 물과 땅 모두에서 살 수 있어야 해요',
      explanation: '도마뱀은 파충류예요. 개구리, 도롱뇽, 두꺼비는 물과 육지 모두에서 사는 양서류랍니다!',
      basePoints: 10,
    ),

    QuizQuestion(
      id: 'sci_g3_02',
      type: QuizType.multipleChoice,
      subject: QuizSubject.science,
      difficulty: DifficultyLevel.grade3,
      questionText: '식물의 뿌리가 하는 일이 아닌 것은 무엇일까요?',
      choices: ['물 흡수', '양분 저장', '광합성', '지지'],
      correctIndex: 2,
      hint: '광합성은 햇빛이 있어야 가능해요',
      explanation: '광합성은 잎에서 이루어져요. 뿌리는 물과 무기 양분을 흡수하고, 양분을 저장하며, 식물을 지지해요!',
      basePoints: 10,
    ),

    QuizQuestion(
      id: 'sci_g3_03',
      type: QuizType.multipleChoice,
      subject: QuizSubject.science,
      difficulty: DifficultyLevel.grade3,
      questionText: '다음 중 척추동물이 아닌 것은 무엇일까요?',
      choices: ['참새', '붕어', '거미', '뱀'],
      correctIndex: 2,
      hint: '등뼈(척추)가 없는 동물이에요',
      explanation: '거미는 절지동물로 척추가 없는 무척추동물이에요. 참새(조류), 붕어(어류), 뱀(파충류)은 모두 척추동물이랍니다!',
      relatedSpecies: '거미',
      basePoints: 10,
    ),

    // grade3 — 영어
    QuizQuestion(
      id: 'eng_g3_01',
      type: QuizType.multipleChoice,
      subject: QuizSubject.english,
      difficulty: DifficultyLevel.grade3,
      questionText: "'Photosynthesis(광합성)'와 가장 관련이 깊은 것은 무엇일까요?",
      choices: ['동물', '식물', '바위', '구름'],
      correctIndex: 1,
      hint: '햇빛을 받아 양분을 만드는 것이에요',
      explanation: 'Photosynthesis(광합성)은 식물이 햇빛, 물, 이산화탄소로 포도당을 만드는 과정이에요!',
      basePoints: 10,
    ),

    QuizQuestion(
      id: 'eng_g3_02',
      type: QuizType.multipleChoice,
      subject: QuizSubject.english,
      difficulty: DifficultyLevel.grade3,
      questionText: '개구리의 영어 이름과 분류를 바르게 짝지은 것은 무엇일까요?',
      choices: ['Frog - 양서류', 'Frog - 파충류', 'Frog - 포유류', 'Frog - 조류'],
      correctIndex: 0,
      hint: 'Frog는 물과 땅에서 모두 사는 동물이에요',
      explanation: 'Frog(개구리)는 양서류(Amphibian)예요. Amphi(양쪽) + bios(생물)의 뜻처럼 물과 땅 양쪽에서 살아요!',
      relatedSpecies: '개구리',
      basePoints: 10,
    ),

    // grade3 — 국어
    QuizQuestion(
      id: 'kor_g3_01',
      type: QuizType.multipleChoice,
      subject: QuizSubject.korean,
      difficulty: DifficultyLevel.grade3,
      questionText: "'나무가 하늘을 찌른다'는 어떤 표현 방법일까요?",
      choices: ['비유', '의인', '과장', '반복'],
      correctIndex: 2,
      hint: '실제보다 훨씬 크게 표현하는 것이에요',
      explanation: "나무가 실제로 하늘을 찌를 수는 없어요. 이처럼 사실을 부풀려 표현하는 것을 '과장법'이라고 해요!",
      basePoints: 10,
    ),

    // ════════════════════════════════════════
    // 초등 4학년 (grade4)
    // ════════════════════════════════════════

    // grade4 — 수학
    QuizQuestion(
      id: 'math_g4_01',
      type: QuizType.multipleChoice,
      subject: QuizSubject.math,
      difficulty: DifficultyLevel.grade4,
      questionText: '나비 30마리 중 2/5가 호랑나비라면 호랑나비는 몇 마리일까요?',
      choices: ['6마리', '10마리', '12마리', '15마리'],
      correctIndex: 2,
      hint: '30을 5로 나눈 뒤 2를 곱해보세요',
      explanation: '30 × 2/5 = 12마리예요. 분수의 곱셈은 전체에서 분수만큼을 구하는 것이에요!',
      relatedSpecies: '호랑나비',
      basePoints: 10,
    ),

    QuizQuestion(
      id: 'math_g4_02',
      type: QuizType.multipleChoice,
      subject: QuizSubject.math,
      difficulty: DifficultyLevel.grade4,
      questionText: '철새 240마리 중 3/8이 제비라면 제비는 몇 마리일까요?',
      choices: ['60마리', '80마리', '90마리', '120마리'],
      correctIndex: 2,
      hint: '240을 8로 나눈 뒤 3을 곱해보세요',
      explanation: '240 × 3/8 = 90마리예요. 분수를 이용하면 전체에서 일부를 쉽게 구할 수 있어요!',
      relatedSpecies: '제비',
      basePoints: 10,
    ),

    // grade4 — 과학
    QuizQuestion(
      id: 'sci_g4_01',
      type: QuizType.multipleChoice,
      subject: QuizSubject.science,
      difficulty: DifficultyLevel.grade4,
      questionText: '곤충의 몸은 어떤 순서로 이루어져 있을까요?',
      choices: ['머리-가슴-배', '머리-배-가슴', '가슴-머리-배', '배-가슴-머리'],
      correctIndex: 0,
      hint: '사람처럼 위에서 아래로 생각해보세요',
      explanation: '곤충의 몸은 머리-가슴-배의 3부분으로 나뉘어요. 다리 6개는 가슴에 붙어있답니다!',
      relatedSpecies: '무당벌레',
      basePoints: 10,
    ),

    // grade4 — 영어
    QuizQuestion(
      id: 'eng_g4_01',
      type: QuizType.multipleChoice,
      subject: QuizSubject.english,
      difficulty: DifficultyLevel.grade4,
      questionText: "'Ecosystem'의 뜻은 무엇일까요?",
      choices: ['생태계', '우주', '화학', '물리'],
      correctIndex: 0,
      hint: '생물과 환경이 서로 영향을 주고받는 체계예요',
      explanation: 'Ecosystem은 생태계예요. 생물과 그 주변 환경이 어우러진 시스템을 뜻해요!',
      basePoints: 10,
    ),

    // grade4 — 국어
    QuizQuestion(
      id: 'kor_g4_01',
      type: QuizType.multipleChoice,
      subject: QuizSubject.korean,
      difficulty: DifficultyLevel.grade4,
      questionText: "'꽃이 웃는다'에 사용된 수사법은 무엇일까요?",
      choices: ['비유', '의인', '과장', '열거'],
      correctIndex: 1,
      hint: '사람이 하는 행동을 사물에 빗댄 표현이에요',
      explanation: "꽃은 실제로 웃을 수 없어요. 사람의 감정이나 행동을 사물에 적용한 것을 '의인법'이라고 해요!",
      basePoints: 10,
    ),

    QuizQuestion(
      id: 'kor_g4_02',
      type: QuizType.multipleChoice,
      subject: QuizSubject.korean,
      difficulty: DifficultyLevel.grade4,
      questionText: "'나비처럼 가벼운 발걸음'에 사용된 수사법은 무엇일까요?",
      choices: ['은유', '직유', '의인', '과장'],
      correctIndex: 1,
      hint: "'~처럼', '~같이'를 사용한 비유예요",
      explanation: "직유법은 '~처럼', '~같이'를 써서 두 대상을 비교해요. '나비처럼'은 직유, '나비 발걸음'이라면 은유예요!",
      relatedSpecies: '나비',
      basePoints: 10,
    ),

    // ════════════════════════════════════════
    // 초등 5학년 (grade5)
    // ════════════════════════════════════════

    // grade5 — 수학
    QuizQuestion(
      id: 'math_g5_01',
      type: QuizType.multipleChoice,
      subject: QuizSubject.math,
      difficulty: DifficultyLevel.grade5,
      questionText: '정육각형 벌집 한 칸의 내각의 합은 몇 도일까요?',
      choices: ['360°', '540°', '720°', '1080°'],
      correctIndex: 2,
      hint: '다각형의 내각의 합 = (변의 수 - 2) × 180°',
      explanation: '정육각형: (6 - 2) × 180° = 720°예요. 벌집이 정육각형인 이유는 공간을 가장 효율적으로 쓸 수 있기 때문이에요!',
      basePoints: 10,
    ),

    // grade5 — 과학
    QuizQuestion(
      id: 'sci_g5_01',
      type: QuizType.multipleChoice,
      subject: QuizSubject.science,
      difficulty: DifficultyLevel.grade5,
      questionText: '식물이 광합성을 할 때 필요한 기체는 무엇일까요?',
      choices: ['산소', '이산화탄소', '질소', '수소'],
      correctIndex: 1,
      hint: '우리가 숨을 내쉴 때 나오는 기체를 식물이 사용해요',
      explanation: '식물은 광합성 시 이산화탄소(CO₂)와 물(H₂O)을 원료로 포도당과 산소를 만들어요. 사람과 식물은 서로 도와줘요!',
      basePoints: 10,
    ),

    QuizQuestion(
      id: 'sci_g5_02',
      type: QuizType.multipleChoice,
      subject: QuizSubject.science,
      difficulty: DifficultyLevel.grade5,
      questionText: '식물 세포에만 있고 동물 세포에는 없는 것은 무엇일까요?',
      choices: ['핵', '세포벽', '미토콘드리아', '리보솜'],
      correctIndex: 1,
      hint: '식물 세포의 모양이 일정하게 유지되도록 돕는 구조예요',
      explanation: '식물 세포에는 세포벽, 엽록체, 액포가 있지만 동물 세포에는 없어요. 세포벽은 식물 세포를 보호하고 형태를 유지해요!',
      basePoints: 10,
    ),

    QuizQuestion(
      id: 'sci_g5_03',
      type: QuizType.multipleChoice,
      subject: QuizSubject.science,
      difficulty: DifficultyLevel.grade5,
      questionText: '먹이 사슬에서 생산자에 해당하는 것은 무엇일까요?',
      choices: ['사자', '토끼', '풀', '독수리'],
      correctIndex: 2,
      hint: '햇빛을 이용해 스스로 양분을 만드는 것이에요',
      explanation: '식물(풀)은 광합성으로 스스로 양분을 만드는 생산자예요. 토끼나 사자는 다른 생물을 먹는 소비자랍니다!',
      basePoints: 10,
    ),

    // grade5 — 영어
    QuizQuestion(
      id: 'eng_g5_01',
      type: QuizType.multipleChoice,
      subject: QuizSubject.english,
      difficulty: DifficultyLevel.grade5,
      questionText: "'Endangered species'는 무슨 뜻일까요?",
      choices: ['멸종 위기 종', '외래 종', '토착 종', '이동 종'],
      correctIndex: 0,
      hint: '지구에서 사라질 위험에 처한 생물이에요',
      explanation: 'Endangered species는 멸종 위기 종이에요. 환경 파괴로 사라져가는 생물들을 보호해야 해요!',
      basePoints: 10,
    ),

    QuizQuestion(
      id: 'eng_g5_02',
      type: QuizType.multipleChoice,
      subject: QuizSubject.english,
      difficulty: DifficultyLevel.grade5,
      questionText: "'Habitat'은 무슨 뜻일까요?",
      choices: ['습관', '서식지', '먹이', '계절'],
      correctIndex: 1,
      hint: '동물이 살고 있는 자연 환경이에요',
      explanation: 'Habitat은 서식지예요. 생물이 살아가는 자연 환경을 뜻하며, 서식지 파괴가 멸종의 주요 원인이에요!',
      basePoints: 10,
    ),

    // grade5 — 국어
    QuizQuestion(
      id: 'kor_g5_01',
      type: QuizType.multipleChoice,
      subject: QuizSubject.korean,
      difficulty: DifficultyLevel.grade5,
      questionText: "'살아있는 화석'이라는 표현에 사용된 수사법은 무엇일까요?",
      choices: ['직유', '은유', '의인', '과장'],
      correctIndex: 1,
      hint: "'~처럼', '~같이' 없이 직접 A는 B다 형태로 비유한 것이에요",
      explanation: "'살아있는 화석'은 은유법이에요. '은행나무는 화석이다'처럼 두 대상을 직접 동일시하는 표현이랍니다!",
      basePoints: 10,
    ),

    QuizQuestion(
      id: 'kor_g5_02',
      type: QuizType.multipleChoice,
      subject: QuizSubject.korean,
      difficulty: DifficultyLevel.grade5,
      questionText: "'봄이 오면 꽃들이 춤을 춘다'는 어떤 표현일까요?",
      choices: ['과장', '반복', '의인', '직유'],
      correctIndex: 2,
      hint: '꽃이 사람처럼 행동하는 것으로 표현했어요',
      explanation: "'꽃들이 춤을 춘다'는 사람의 행동을 꽃에 적용한 의인법이에요. 자연을 생동감 있게 표현하는 방법이랍니다!",
      basePoints: 10,
    ),

    // ════════════════════════════════════════
    // 초등 6학년 (grade6)
    // ════════════════════════════════════════

    // grade6 — 수학
    QuizQuestion(
      id: 'math_g6_01',
      type: QuizType.multipleChoice,
      subject: QuizSubject.math,
      difficulty: DifficultyLevel.grade6,
      questionText: '나무의 그림자 길이가 6m이고, 1m 막대기의 그림자가 0.5m일 때 나무의 높이는?',
      choices: ['3m', '6m', '12m', '18m'],
      correctIndex: 2,
      hint: '비례식으로 풀어보세요: 나무 높이 / 6 = 1 / 0.5',
      explanation: '비례식: 나무 높이 / 6m = 1m / 0.5m → 나무 높이 = 6 × 2 = 12m예요. 수학으로 나무 높이를 잴 수 있어요!',
      basePoints: 10,
    ),

    // grade6 — 과학
    QuizQuestion(
      id: 'sci_g6_01',
      type: QuizType.multipleChoice,
      subject: QuizSubject.science,
      difficulty: DifficultyLevel.grade6,
      questionText: "'살아있는 화석'이라 불리는 식물은 무엇일까요?",
      choices: ['은행나무', '소나무', '벚나무', '단풍나무'],
      correctIndex: 0,
      hint: '공룡이 살던 시대부터 지금까지 거의 그 모습 그대로 살아있는 나무예요',
      explanation: '은행나무는 약 2억 7천만 년 전부터 존재한 고대 식물이에요. 화석과 모습이 거의 같아 살아있는 화석이라 불려요!',
      relatedSpecies: '은행나무',
      basePoints: 10,
    ),

    QuizQuestion(
      id: 'sci_g6_02',
      type: QuizType.multipleChoice,
      subject: QuizSubject.science,
      difficulty: DifficultyLevel.grade6,
      questionText: '다음 중 외래종(침입종)으로 생태계를 위협하는 생물은 무엇일까요?',
      choices: ['민들레', '참개구리', '황소개구리', '청개구리'],
      correctIndex: 2,
      hint: '다른 나라에서 들어와 토종 생물을 위협하는 종이에요',
      explanation: '황소개구리는 북미 원산의 외래종으로 국내 토종 개구리와 물고기를 잡아먹어 생태계를 교란해요!',
      relatedSpecies: '황소개구리',
      basePoints: 10,
    ),

    // grade6 — 영어
    QuizQuestion(
      id: 'eng_g6_01',
      type: QuizType.multipleChoice,
      subject: QuizSubject.english,
      difficulty: DifficultyLevel.grade6,
      questionText: "'Biodiversity'의 뜻은 무엇일까요?",
      choices: ['생물 다양성', '광합성', '진화론', '유전학'],
      correctIndex: 0,
      hint: '지구상의 다양한 생물과 그 다양성을 뜻해요',
      explanation: 'Biodiversity는 생물 다양성이에요. Bio(생물) + Diversity(다양성)의 합성어로, 지구의 건강한 생태계를 위해 꼭 필요해요!',
      basePoints: 10,
    ),

    QuizQuestion(
      id: 'eng_g6_02',
      type: QuizType.multipleChoice,
      subject: QuizSubject.english,
      difficulty: DifficultyLevel.grade6,
      questionText: "'Photosynthesis'를 영어로 바르게 설명한 것은 무엇일까요?",
      choices: [
        'Plants make food using sunlight',
        'Animals breathe oxygen',
        'Rocks form over millions of years',
        'Water evaporates in heat',
      ],
      correctIndex: 0,
      hint: '식물이 햇빛을 이용해서 하는 것을 떠올려보세요',
      explanation: '광합성(Photosynthesis)은 식물이 햇빛(sunlight), 물(water), 이산화탄소(CO₂)를 이용해 양분을 만드는 과정이에요!',
      basePoints: 10,
    ),

    // grade6 — 국어
    QuizQuestion(
      id: 'kor_g6_01',
      type: QuizType.multipleChoice,
      subject: QuizSubject.korean,
      difficulty: DifficultyLevel.grade6,
      questionText: '생태계 보호의 필요성을 주장하는 글은 어떤 종류의 글일까요?',
      choices: ['설명문', '논설문', '수필', '일기'],
      correctIndex: 1,
      hint: '자신의 의견과 주장을 논리적으로 내세우는 글이에요',
      explanation: "'논설문'은 주장, 근거, 결론의 구조로 자신의 의견을 논리적으로 펼치는 글이에요. 설명문은 정보 전달, 수필은 감상을 담아요!",
      basePoints: 10,
    ),

    QuizQuestion(
      id: 'kor_g6_02',
      type: QuizType.multipleChoice,
      subject: QuizSubject.korean,
      difficulty: DifficultyLevel.grade6,
      questionText: '자연 현상을 관찰하고 느낀 점을 자유롭게 적은 글은 어떤 종류일까요?',
      choices: ['논설문', '보고서', '수필', '편지'],
      correctIndex: 2,
      hint: '형식에 얽매이지 않고 감상과 생각을 자유롭게 쓰는 글이에요',
      explanation: "'수필'은 형식 없이 자신의 경험, 감상, 생각을 자유롭게 쓰는 글이에요. 자연 관찰 일기도 수필의 한 형태랍니다!",
      basePoints: 10,
    ),

    // ════════════════════════════════════════
    // 추가 보충 문제 (age7 / grade1~6 혼합)
    // ════════════════════════════════════════

    // age7 — 과학
    QuizQuestion(
      id: 'sci_age7_01',
      type: QuizType.multipleChoice,
      subject: QuizSubject.science,
      difficulty: DifficultyLevel.age7,
      questionText: '곤충의 몸은 몇 부분으로 나뉘나요?',
      choices: ['2부분', '3부분(머리·가슴·배)', '4부분', '5부분'],
      correctIndex: 1,
      hint: '머리, 가슴, 배를 세어보세요',
      explanation: '곤충의 몸은 머리, 가슴, 배 3부분으로 나뉘고 다리가 6개예요.',
      basePoints: 10,
    ),

    QuizQuestion(
      id: 'sci_age7_02',
      type: QuizType.multipleChoice,
      subject: QuizSubject.science,
      difficulty: DifficultyLevel.age7,
      questionText: '나무의 나이를 알 수 있는 것은 무엇일까요?',
      choices: ['나이테', '잎의 색', '가지의 수', '꽃의 색'],
      correctIndex: 0,
      hint: '나무를 자르면 볼 수 있는 동그란 무늬예요',
      explanation: '나이테를 세면 나무의 나이를 알 수 있어요. 나무는 1년에 나이테 1개씩 만들어요.',
      basePoints: 10,
    ),

    // age7 — 수학
    QuizQuestion(
      id: 'math_age7_01',
      type: QuizType.multipleChoice,
      subject: QuizSubject.math,
      difficulty: DifficultyLevel.age7,
      questionText: '연못에 개구리가 8마리 있다가 3마리가 뛰어나갔어요. 남은 개구리는 몇 마리일까요?',
      choices: ['4마리', '5마리', '6마리', '7마리'],
      correctIndex: 1,
      hint: '8에서 3을 빼보세요',
      explanation: '8 - 3 = 5마리예요. 빼기는 있던 것에서 떠나는 것을 나타내요!',
      relatedSpecies: '개구리',
      basePoints: 10,
    ),

    // age7 — 영어
    QuizQuestion(
      id: 'eng_age7_01',
      type: QuizType.multipleChoice,
      subject: QuizSubject.english,
      difficulty: DifficultyLevel.age7,
      questionText: "'Leaf'의 뜻은 무엇일까요?",
      choices: ['뿌리', '꽃', '잎', '열매'],
      correctIndex: 2,
      hint: '나무에서 초록색으로 달려 있는 것이에요',
      explanation: 'Leaf는 잎이에요. 식물의 잎은 광합성을 해서 양분을 만들어요!',
      basePoints: 10,
    ),

    // age7 — 국어
    QuizQuestion(
      id: 'kor_age7_01',
      type: QuizType.multipleChoice,
      subject: QuizSubject.korean,
      difficulty: DifficultyLevel.age7,
      questionText: "'새가 날아간다'에서 '날아간다'는 어떤 말일까요?",
      choices: ['이름', '모습', '행동', '소리'],
      correctIndex: 2,
      hint: '새가 무엇을 하는지 알려주는 말이에요',
      explanation: "'날아간다'는 새의 행동을 나타내는 말이에요. 이런 말을 동사라고 해요!",
      basePoints: 10,
    ),

    // grade1 — 과학 (보충)
    QuizQuestion(
      id: 'sci_g1_03',
      type: QuizType.oxQuiz,
      subject: QuizSubject.science,
      difficulty: DifficultyLevel.grade1,
      questionText: '나비는 알→애벌레→번데기→나비 순서로 자라요. (O/X)',
      choices: ['O', 'X'],
      correctIndex: 0,
      hint: '나비가 어떻게 변해가는지 생각해보세요',
      explanation: '나비는 알에서 애벌레, 번데기를 거쳐 나비가 되는 완전변태를 해요!',
      relatedSpecies: '나비',
      basePoints: 10,
    ),

    // grade2 — 수학 (보충)
    QuizQuestion(
      id: 'math_g2_03',
      type: QuizType.multipleChoice,
      subject: QuizSubject.math,
      difficulty: DifficultyLevel.grade2,
      questionText: '꽃밭에 나비가 12마리, 꿀벌이 9마리 있어요. 나비는 꿀벌보다 몇 마리 더 많을까요?',
      choices: ['2마리', '3마리', '4마리', '5마리'],
      correctIndex: 1,
      hint: '12에서 9를 빼보세요',
      explanation: '12 - 9 = 3마리예요. 차이를 구할 때는 빼기를 사용해요!',
      relatedSpecies: '나비',
      basePoints: 10,
    ),

    // grade3 — 국어 (보충)
    QuizQuestion(
      id: 'kor_g3_02',
      type: QuizType.multipleChoice,
      subject: QuizSubject.korean,
      difficulty: DifficultyLevel.grade3,
      questionText: '다음 중 자연을 주제로 한 시에서 자주 쓰이는 표현 방법은 무엇일까요?',
      choices: ['의인법', '열거법', '인용법', '통계법'],
      correctIndex: 0,
      hint: '꽃이 웃고, 바람이 속삭이는 것처럼 자연을 사람처럼 표현해요',
      explanation: '의인법은 자연을 사람처럼 표현하는 방법이에요. 시에서 자연에 생명력을 불어넣을 때 많이 써요!',
      basePoints: 10,
    ),

    // grade4 — 과학 (보충)
    QuizQuestion(
      id: 'sci_g4_02',
      type: QuizType.multipleChoice,
      subject: QuizSubject.science,
      difficulty: DifficultyLevel.grade4,
      questionText: '생태계에서 분해자의 역할은 무엇일까요?',
      choices: ['죽은 생물을 분해하여 양분으로 되돌림', '광합성으로 양분 생산', '다른 동물을 사냥', '씨앗을 퍼뜨림'],
      correctIndex: 0,
      hint: '세균이나 곰팡이처럼 썩게 만드는 역할이에요',
      explanation: '분해자(세균, 곰팡이 등)는 죽은 생물을 분해해 무기물로 되돌려 생태계 순환에 기여해요.',
      basePoints: 10,
    ),

    // grade5 — 수학 (보충)
    QuizQuestion(
      id: 'math_g5_02',
      type: QuizType.multipleChoice,
      subject: QuizSubject.math,
      difficulty: DifficultyLevel.grade5,
      questionText: '원형 연못의 반지름이 7m라면 둘레는 약 몇 m일까요? (원주율 = 3.14)',
      choices: ['21.98m', '43.96m', '87.92m', '153.86m'],
      correctIndex: 1,
      hint: '원의 둘레 = 지름 × 원주율 = 2 × 반지름 × 3.14',
      explanation: '2 × 7 × 3.14 = 43.96m예요. 원의 둘레 공식은 지름 × 원주율이에요!',
      basePoints: 10,
    ),

    // grade6 — 수학 (보충)
    QuizQuestion(
      id: 'math_g6_02',
      type: QuizType.multipleChoice,
      subject: QuizSubject.math,
      difficulty: DifficultyLevel.grade6,
      questionText: '자연보호 구역의 넓이가 1800㎡이고 전체 공원의 60%라면 전체 공원의 넓이는?',
      choices: ['1080㎡', '2400㎡', '3000㎡', '4500㎡'],
      correctIndex: 2,
      hint: '1800은 전체의 60%이므로, 전체 = 1800 ÷ 0.6',
      explanation: '1800 ÷ 0.6 = 3000㎡예요. 비율 문제는 전체를 1로 놓고 생각해요!',
      basePoints: 10,
    ),

    // grade6 — 과학 (보충)
    QuizQuestion(
      id: 'sci_g6_03',
      type: QuizType.multipleChoice,
      subject: QuizSubject.science,
      difficulty: DifficultyLevel.grade6,
      questionText: '지구 온난화가 생태계에 미치는 영향으로 옳지 않은 것은?',
      choices: [
        '모든 생물의 개체 수 증가',
        '빙하 감소로 북극곰 서식지 위협',
        '해수면 상승으로 해안 생태계 변화',
        '꽃 개화 시기 변화로 수분 불일치',
      ],
      correctIndex: 0,
      hint: '지구 온난화로 사라져가는 생물이 많아요',
      explanation: '지구 온난화로 일부 생물은 증가하지만 많은 생물은 감소하며, 모든 생물이 증가하지는 않아요.',
      basePoints: 10,
    ),

    // grade5 — 영어 (보충)
    QuizQuestion(
      id: 'eng_g5_03',
      type: QuizType.multipleChoice,
      subject: QuizSubject.english,
      difficulty: DifficultyLevel.grade5,
      questionText: "'Migration'은 무슨 뜻일까요?",
      choices: ['먹이', '이동·이주', '서식지', '번식'],
      correctIndex: 1,
      hint: '철새가 계절에 따라 이동하는 것이에요',
      explanation: 'Migration은 이동·이주예요. 철새의 계절 이동(bird migration)처럼 생물이 이동하는 것을 뜻해요!',
      basePoints: 10,
    ),

    // grade6 — 영어 (보충)
    QuizQuestion(
      id: 'eng_g6_03',
      type: QuizType.multipleChoice,
      subject: QuizSubject.english,
      difficulty: DifficultyLevel.grade6,
      questionText: "'Carbon footprint'의 뜻은 무엇일까요?",
      choices: ['탄소 발자국(탄소 배출량)', '산소 소비량', '식물의 성장량', '물의 순환량'],
      correctIndex: 0,
      hint: '우리가 일상에서 얼마나 많은 탄소를 배출하는지 나타내요',
      explanation: 'Carbon footprint는 탄소 발자국이에요. 개인이나 활동이 배출하는 이산화탄소의 총량을 뜻해요!',
      basePoints: 10,
    ),
  ];

  // ─── 감정 질문 데이터 ───

  static const List<EmotionQuestion> _emotionQuestions = [
    // emo_01: 현재 기분
    EmotionQuestion(
      id: 'emo_01',
      questionText: '지금 기분이 어때요?',
      choices: [
        EmotionChoice(emoji: '😊', label: '행복해요'),
        EmotionChoice(emoji: '😢', label: '슬퍼요', followUp: '무엇이 슬프게 했나요?'),
        EmotionChoice(emoji: '😠', label: '화나요', followUp: '어떤 일이 있었나요?'),
        EmotionChoice(emoji: '😰', label: '걱정돼요', followUp: '무엇이 걱정되나요?'),
        EmotionChoice(emoji: '😌', label: '편안해요'),
        EmotionChoice(emoji: '🤗', label: '신나요'),
      ],
      basePoints: 5,
    ),

    // emo_02: 자연을 보며
    EmotionQuestion(
      id: 'emo_02',
      questionText: '자연을 보면서 어떤 느낌이 들어요?',
      choices: [
        EmotionChoice(emoji: '😊', label: '기분 좋아요'),
        EmotionChoice(emoji: '🤩', label: '신기해요'),
        EmotionChoice(emoji: '😌', label: '편안해요'),
        EmotionChoice(emoji: '🥱', label: '지루해요', followUp: '어떤 활동을 하고 싶나요?'),
        EmotionChoice(emoji: '😢', label: '슬퍼요', followUp: '왜 슬픈 느낌이 드나요?'),
        EmotionChoice(emoji: '🤗', label: '감사해요'),
      ],
      basePoints: 5,
    ),

    // emo_03: 오늘 탐험
    EmotionQuestion(
      id: 'emo_03',
      questionText: '오늘 탐험은 어땠어요?',
      choices: [
        EmotionChoice(emoji: '🥳', label: '정말 즐거웠어요'),
        EmotionChoice(emoji: '😊', label: '좋았어요'),
        EmotionChoice(emoji: '😐', label: '그저 그랬어요', followUp: '어떤 점이 아쉬웠나요?'),
        EmotionChoice(emoji: '😥', label: '힘들었어요', followUp: '어떤 점이 힘들었나요?'),
        EmotionChoice(emoji: '🤩', label: '새로운 것을 발견해서 신났어요'),
        EmotionChoice(emoji: '😴', label: '피곤했어요', followUp: '충분히 쉬었나요?'),
      ],
      basePoints: 5,
    ),

    // emo_04: 친구와 함께
    EmotionQuestion(
      id: 'emo_04',
      questionText: '친구와 함께하는 자연 관찰은 어때요?',
      choices: [
        EmotionChoice(emoji: '🤗', label: '더 재미있어요'),
        EmotionChoice(emoji: '😊', label: '즐거워요'),
        EmotionChoice(emoji: '🙂', label: '혼자가 더 좋아요', followUp: '혼자만의 탐험의 어떤 점이 좋나요?'),
        EmotionChoice(emoji: '🥰', label: '친구가 더 좋아져요'),
        EmotionChoice(emoji: '😤', label: '친구랑 의견이 달라요', followUp: '어떤 부분에서 달랐나요?'),
        EmotionChoice(emoji: '😌', label: '함께라서 든든해요'),
      ],
      basePoints: 5,
    ),

    // emo_05: 새로운 생물 발견
    EmotionQuestion(
      id: 'emo_05',
      questionText: '새로운 생물을 발견했을 때 기분은 어때요?',
      choices: [
        EmotionChoice(emoji: '🤩', label: '너무 신기해요'),
        EmotionChoice(emoji: '😊', label: '기뻐요'),
        EmotionChoice(emoji: '😮', label: '깜짝 놀랐어요'),
        EmotionChoice(emoji: '🥰', label: '사랑스러워요'),
        EmotionChoice(emoji: '😱', label: '무서웠어요', followUp: '어떤 생물이 무서웠나요?'),
        EmotionChoice(emoji: '🔍', label: '더 알고 싶어요'),
      ],
      basePoints: 5,
    ),

    // emo_06: 일기 쓰기 후
    EmotionQuestion(
      id: 'emo_06',
      questionText: '관찰 일기를 쓰고 나니 기분이 어때요?',
      choices: [
        EmotionChoice(emoji: '😌', label: '뿌듯해요'),
        EmotionChoice(emoji: '😊', label: '기분이 좋아요'),
        EmotionChoice(emoji: '🤔', label: '더 알아보고 싶어요'),
        EmotionChoice(emoji: '😅', label: '어려웠어요', followUp: '어떤 점이 어려웠나요?'),
        EmotionChoice(emoji: '😴', label: '힘들었어요'),
        EmotionChoice(emoji: '🥳', label: '내일도 쓰고 싶어요'),
      ],
      basePoints: 5,
    ),

    // emo_07: 아침 기분
    EmotionQuestion(
      id: 'emo_07',
      questionText: '오늘 아침 기분은 어때요?',
      choices: [
        EmotionChoice(emoji: '☀️', label: '상쾌해요'),
        EmotionChoice(emoji: '😴', label: '아직 졸려요', followUp: '몇 시에 잤나요?'),
        EmotionChoice(emoji: '😊', label: '기분 좋아요'),
        EmotionChoice(emoji: '😐', label: '보통이에요'),
        EmotionChoice(emoji: '🤗', label: '오늘 탐험이 기대돼요'),
        EmotionChoice(emoji: '😟', label: '걱정되는 일이 있어요', followUp: '무엇이 걱정되나요?'),
      ],
      basePoints: 5,
    ),

    // emo_08: 날씨 기분
    EmotionQuestion(
      id: 'emo_08',
      questionText: '지금 밖의 날씨를 보면 기분이 어때요?',
      choices: [
        EmotionChoice(emoji: '☀️', label: '맑아서 기분 좋아요'),
        EmotionChoice(emoji: '🌧️', label: '비가 와서 아쉬워요', followUp: '비 오는 날 실내에서 뭘 하고 싶나요?'),
        EmotionChoice(emoji: '🌈', label: '비 온 뒤 무지개가 기대돼요'),
        EmotionChoice(emoji: '❄️', label: '추워서 실내에 있고 싶어요'),
        EmotionChoice(emoji: '🌬️', label: '바람이 시원해서 좋아요'),
        EmotionChoice(emoji: '☁️', label: '구름이 예뻐서 바라보고 싶어요'),
      ],
      basePoints: 5,
    ),

    // emo_09: 자연에서 좋아하는 순간
    EmotionQuestion(
      id: 'emo_09',
      questionText: '자연에서 가장 좋아하는 순간은 언제예요?',
      choices: [
        EmotionChoice(emoji: '🌸', label: '봄꽃이 필 때'),
        EmotionChoice(emoji: '🦋', label: '나비를 발견했을 때'),
        EmotionChoice(emoji: '🌅', label: '노을이 질 때'),
        EmotionChoice(emoji: '🌿', label: '풀밭에 누워 있을 때'),
        EmotionChoice(emoji: '🐸', label: '개구리 소리를 들을 때'),
        EmotionChoice(emoji: '⭐', label: '밤에 별을 볼 때'),
      ],
      basePoints: 5,
    ),

    // emo_10: 오늘 하루를 동물로 표현하면
    EmotionQuestion(
      id: 'emo_10',
      questionText: '오늘 하루를 동물로 표현한다면 어떤 동물일까요?',
      choices: [
        EmotionChoice(emoji: '🦁', label: '사자 — 활기차고 용감했어요'),
        EmotionChoice(emoji: '🐢', label: '거북이 — 느리지만 꾸준했어요'),
        EmotionChoice(emoji: '🦋', label: '나비 — 자유롭고 즐거웠어요'),
        EmotionChoice(emoji: '🦔', label: '고슴도치 — 조금 움츠러들었어요', followUp: '무슨 일이 있었나요?'),
        EmotionChoice(emoji: '🐝', label: '꿀벌 — 열심히 바빴어요'),
        EmotionChoice(emoji: '🦉', label: '올빼미 — 생각이 많았어요', followUp: '어떤 생각을 했나요?'),
      ],
      basePoints: 5,
    ),
  ];
}
