import '../models/challenge.dart';

const _challenges = [
  // Week 1
  Challenge(
    id: 'challenge-w1',
    title: '봄맞이 자연 탐험',
    description: '봄을 맞아 다양한 자연을 관찰해보세요!',
    weekNumber: 0,
    rewardPoints: 50,
    rewardPetExp: 30,
    tasks: [
      ChallengeTask(
        id: 'w1-t1',
        type: ChallengeTaskType.discoverCategory,
        title: '식물 2종 발견하기',
        description: '주변의 식물을 관찰하고 도감에 등록해보세요',
        emoji: '🌿',
        targetCount: 2,
        targetCategory: 'plant',
      ),
      ChallengeTask(
        id: 'w1-t2',
        type: ChallengeTaskType.writeDiary,
        title: '관찰 일기 1편 작성',
        description: '오늘 관찰한 자연을 일기로 기록해보세요',
        emoji: '📝',
        targetCount: 1,
      ),
      ChallengeTask(
        id: 'w1-t3',
        type: ChallengeTaskType.quizCorrect,
        title: '퀴즈 3문제 맞히기',
        description: '자연 퀴즈에 도전해보세요',
        emoji: '🧠',
        targetCount: 3,
      ),
      ChallengeTask(
        id: 'w1-t4',
        type: ChallengeTaskType.petCare,
        title: '펫 돌봄 2회',
        description: '나의 펫을 돌봐주세요',
        emoji: '🐾',
        targetCount: 2,
      ),
    ],
  ),
  // Week 2
  Challenge(
    id: 'challenge-w2',
    title: '곤충 박사 되기',
    description: '작은 곤충 친구들을 찾아보세요!',
    weekNumber: 1,
    rewardPoints: 50,
    rewardPetExp: 30,
    tasks: [
      ChallengeTask(
        id: 'w2-t1',
        type: ChallengeTaskType.discoverCategory,
        title: '곤충 1종 발견하기',
        description: '주변에서 곤충을 찾아 도감에 등록해보세요',
        emoji: '🐛',
        targetCount: 1,
        targetCategory: 'insect',
      ),
      ChallengeTask(
        id: 'w2-t2',
        type: ChallengeTaskType.discoverSpecies,
        title: '무당벌레 찾기',
        description: '행운의 무당벌레를 찾아보세요',
        emoji: '🐞',
        targetCount: 1,
        targetSpecies: '무당벌레',
      ),
      ChallengeTask(
        id: 'w2-t3',
        type: ChallengeTaskType.writeDiary,
        title: '관찰 일기 2편 작성',
        description: '곤충 관찰 일기를 써보세요',
        emoji: '📝',
        targetCount: 2,
      ),
      ChallengeTask(
        id: 'w2-t4',
        type: ChallengeTaskType.quizCorrect,
        title: '퀴즈 5문제 맞히기',
        description: '곤충 박사가 되어보세요',
        emoji: '🧠',
        targetCount: 5,
      ),
    ],
  ),
  // Week 3
  Challenge(
    id: 'challenge-w3',
    title: '숲속 친구들',
    description: '숲에서 다양한 동물 친구들을 만나보세요!',
    weekNumber: 2,
    rewardPoints: 50,
    rewardPetExp: 30,
    tasks: [
      ChallengeTask(
        id: 'w3-t1',
        type: ChallengeTaskType.discoverCategory,
        title: '포유류 1종 발견하기',
        description: '숲속 포유류 친구를 찾아보세요',
        emoji: '🦊',
        targetCount: 1,
        targetCategory: 'mammal',
      ),
      ChallengeTask(
        id: 'w3-t2',
        type: ChallengeTaskType.discoverCategory,
        title: '조류 1종 발견하기',
        description: '새 친구를 관찰해보세요',
        emoji: '🐦',
        targetCount: 1,
        targetCategory: 'bird',
      ),
      ChallengeTask(
        id: 'w3-t3',
        type: ChallengeTaskType.writeDiary,
        title: '관찰 일기 2편 작성',
        description: '동물 관찰 일기를 써보세요',
        emoji: '📝',
        targetCount: 2,
      ),
      ChallengeTask(
        id: 'w3-t4',
        type: ChallengeTaskType.petCare,
        title: '펫 돌봄 3회',
        description: '나의 펫과 함께 놀아주세요',
        emoji: '🐾',
        targetCount: 3,
      ),
    ],
  ),
  // Week 4
  Challenge(
    id: 'challenge-w4',
    title: '자연 마스터',
    description: '자연의 모든 것을 탐험해보세요!',
    weekNumber: 3,
    rewardPoints: 50,
    rewardPetExp: 30,
    tasks: [
      ChallengeTask(
        id: 'w4-t1',
        type: ChallengeTaskType.discoverSpecies,
        title: '아무 종 3종 발견하기',
        description: '어떤 종이든 3종을 도감에 등록해보세요',
        emoji: '🔍',
        targetCount: 3,
      ),
      ChallengeTask(
        id: 'w4-t2',
        type: ChallengeTaskType.quizCorrect,
        title: '퀴즈 5문제 맞히기',
        description: '자연 마스터의 실력을 보여주세요',
        emoji: '🧠',
        targetCount: 5,
      ),
      ChallengeTask(
        id: 'w4-t3',
        type: ChallengeTaskType.writeDiary,
        title: '관찰 일기 2편 작성',
        description: '자연 관찰 일기를 써보세요',
        emoji: '📝',
        targetCount: 2,
      ),
      ChallengeTask(
        id: 'w4-t4',
        type: ChallengeTaskType.petCare,
        title: '펫 돌봄 2회',
        description: '나의 펫을 돌봐주세요',
        emoji: '🐾',
        targetCount: 2,
      ),
    ],
  ),
];

/// 현재 주에 해당하는 챌린지를 반환 (4주 순환)
Challenge getCurrentChallenge() {
  final now = DateTime.now();
  // 연중 몇 번째 주인지 계산
  final firstDayOfYear = DateTime(now.year, 1, 1);
  final dayOfYear = now.difference(firstDayOfYear).inDays;
  final weekNumber = (dayOfYear / 7).floor();
  final challengeIndex = weekNumber % _challenges.length;
  return _challenges[challengeIndex];
}

/// 특정 인덱스의 챌린지를 반환
Challenge getChallengeByIndex(int index) {
  return _challenges[index % _challenges.length];
}
