class SpeciesInfo {
  const SpeciesInfo({
    required this.name,
    required this.scientificName,
    required this.classification,
    required this.habitat,
    required this.size,
    required this.features,
    required this.funFact,
    required this.conservationStatus,
  });

  final String name;
  final String scientificName;
  final String classification;
  final String habitat;
  final String size;
  final List<String> features;
  final String funFact;
  final String conservationStatus;
}

class SpeciesEncyclopedia {
  static const Map<String, SpeciesInfo> data = {
    '진달래': SpeciesInfo(
      name: '진달래',
      scientificName: 'Rhododendron mucronulatum',
      classification: '식물계 > 피자식물문 > 쌍떡잎식물강 > 진달래목 > 진달래과',
      habitat: '한국, 중국, 일본의 산지. 해발 100~2,000m의 양지바른 산기슭과 능선',
      size: '높이 2~3m의 낙엽 관목',
      features: [
        '잎보다 꽃이 먼저 피는 선화후엽(先花後葉) 식물',
        '꽃잎은 분홍색~연보라색, 깔때기 모양으로 5갈래',
        '꽃은 식용 가능하며 화전, 진달래 화채에 사용',
        '철쭉과 비슷하지만 철쭉은 독성이 있어 구별 필요',
      ],
      funFact: '진달래꽃은 먹을 수 있지만, 비슷하게 생긴 철쭉꽃은 독이 있어요! 진달래는 꽃이 먼저 피고 잎이 나중에 나오고, 철쭉은 꽃과 잎이 같이 나와요.',
      conservationStatus: '관심 대상 (LC) - 개체수 안정',
    ),
    '청딱따구리': SpeciesInfo(
      name: '청딱따구리',
      scientificName: 'Picus canus',
      classification: '동물계 > 척삭동물문 > 조강 > 딱따구리목 > 딱따구리과',
      habitat: '한국, 유럽~동아시아 온대 산림. 활엽수림과 혼합림',
      size: '몸길이 약 25~28cm, 날개 길이 14~15cm',
      features: [
        '머리꼭대기가 회색이고 수컷만 이마에 빨간 반점',
        '등은 올리브 녹색, 배는 연한 회색',
        '혀가 매우 길어 나무 속 곤충을 꺼내 먹음',
        '나무를 두드리는 소리로 영역을 표시 (드러밍)',
      ],
      funFact: '딱따구리는 1초에 20번이나 나무를 쪼을 수 있어요! 뇌를 보호하는 특수한 두개골 구조가 있어서 충격을 흡수해요. 혀 길이가 머리 둘레만큼 길답니다!',
      conservationStatus: '관심 대상 (LC) - 개체수 감소 추세',
    ),
    '무당벌레': SpeciesInfo(
      name: '무당벌레',
      scientificName: 'Harmonia axyridis',
      classification: '동물계 > 절지동물문 > 곤충강 > 딱정벌레목 > 무당벌레과',
      habitat: '한국, 동아시아 원산. 농경지, 정원, 산림 등 다양한 환경',
      size: '몸길이 5.5~8.5mm',
      features: [
        '등딱지 색과 무늬가 매우 다양 (200가지 이상의 변이)',
        '진딧물을 하루 최대 100마리까지 잡아먹는 익충',
        '위험을 느끼면 다리 관절에서 노란 체액(리필린) 분비',
        '겨울에 집단으로 모여 월동하는 습성',
      ],
      funFact: '무당벌레 한 마리가 평생 5,000마리 이상의 진딧물을 먹어요! 그래서 농부들에게 정말 고마운 곤충이에요. 점무늬 개수는 종류마다 다르고 나이와는 관계없어요.',
      conservationStatus: '관심 대상 (LC) - 전 세계 분포, 개체수 풍부',
    ),
    '다람쥐': SpeciesInfo(
      name: '다람쥐',
      scientificName: 'Tamias sibiricus',
      classification: '동물계 > 척삭동물문 > 포유강 > 쥐목 > 다람쥐과',
      habitat: '한국, 시베리아~동아시아의 침엽수림 및 혼합림',
      size: '몸길이 12~17cm, 꼬리 8~11cm, 몸무게 50~150g',
      features: [
        '등에 5개의 검은 줄무늬와 4개의 밝은 줄무늬',
        '볼주머니에 먹이를 저장하여 운반 (양쪽 볼에 도토리 4~5개)',
        '겨울잠(동면)을 자며, 가을에 먹이를 땅속에 저장',
        '나무 타기에 뛰어나고 초속 4.5m의 속도로 이동',
      ],
      funFact: '다람쥐는 가을에 도토리를 수백 개 땅에 묻어두는데, 묻은 곳을 까먹어서 그 도토리가 싹이 터서 나무가 돼요! 그래서 다람쥐를 "숲의 정원사"라고 불러요.',
      conservationStatus: '관심 대상 (LC) - 개체수 안정',
    ),
    '도롱뇽': SpeciesInfo(
      name: '도롱뇽',
      scientificName: 'Hynobius leechii',
      classification: '동물계 > 척삭동물문 > 양서강 > 도롱뇽목 > 도롱뇽과',
      habitat: '한국 고유종에 가까운 분포. 계곡, 습지, 산림 내 수원지 근처',
      size: '몸길이 8~14cm (꼬리 포함)',
      features: [
        '피부가 촉촉하고 점액으로 덮여 있어 피부 호흡 가능',
        '알을 바나나 모양의 젤리 주머니에 낳음 (한 쌍씩)',
        '유생(올챙이) 시기에 아가미로 호흡하다가 성체가 되면 폐 호흡',
        '야행성이며 곤충, 지렁이, 작은 무척추동물을 먹음',
      ],
      funFact: '도롱뇽은 잘린 꼬리나 다리가 다시 자라나는 재생 능력이 있어요! 과학자들이 이 능력을 연구해서 사람의 상처 치료에 활용하려고 해요.',
      conservationStatus: '관심 대상 (LC) - 서식지 파괴로 일부 지역 감소',
    ),
    '은행나무': SpeciesInfo(
      name: '은행나무',
      scientificName: 'Ginkgo biloba',
      classification: '식물계 > 은행식물문 > 은행강 > 은행목 > 은행과',
      habitat: '중국 원산, 전 세계 온대 지역에서 가로수로 식재',
      size: '높이 최대 40m, 수령 1,000년 이상 가능',
      features: [
        '약 2억 7천만 년 전부터 존재한 "살아있는 화석"',
        '부채 모양의 독특한 잎, 가을에 노란색으로 단풍',
        '암나무와 수나무가 따로 있는 자웅이주 식물',
        '열매(은행)는 식용이지만 과육에는 독성분(빌로볼) 포함',
      ],
      funFact: '은행나무는 공룡시대부터 살아남은 나무예요! 2억 7천만 년 동안 거의 모습이 변하지 않았어요. 히로시마 원폭에서도 살아남은 은행나무가 있을 정도로 생명력이 강해요.',
      conservationStatus: '위기 (EN) - 야생 개체군 극소수, 대부분 인공 식재',
    ),
  };

  static SpeciesInfo? getInfo(String speciesName) => data[speciesName];
}
