enum GifticonCategory { all, cafe, convenience, icecream }

class Gifticon {
  const Gifticon({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    required this.requiredPoints,
    required this.description,
  });

  final String id;
  final String name;
  final String emoji;
  final GifticonCategory category;
  final int requiredPoints;
  final String description;
}

const List<Gifticon> kGifticons = [
  // 카페
  Gifticon(
    id: 'cafe_001',
    name: '초코라떼',
    emoji: '☕',
    category: GifticonCategory.cafe,
    requiredPoints: 500,
    description: '진한 초콜릿과 부드러운 우유가 어우러진 달콤한 라떼',
  ),
  Gifticon(
    id: 'cafe_002',
    name: '딸기스무디',
    emoji: '🍓',
    category: GifticonCategory.cafe,
    requiredPoints: 600,
    description: '신선한 딸기로 만든 새콤달콤한 스무디',
  ),
  Gifticon(
    id: 'cafe_003',
    name: '바닐라쉐이크',
    emoji: '🥤',
    category: GifticonCategory.cafe,
    requiredPoints: 800,
    description: '부드럽고 진한 바닐라 아이스크림 쉐이크',
  ),
  Gifticon(
    id: 'cafe_004',
    name: '아이스티',
    emoji: '🧊',
    category: GifticonCategory.cafe,
    requiredPoints: 300,
    description: '시원하고 향긋한 과일 아이스티',
  ),

  // 편의점
  Gifticon(
    id: 'conv_001',
    name: '삼각김밥',
    emoji: '🍙',
    category: GifticonCategory.convenience,
    requiredPoints: 100,
    description: '편의점 인기 간식, 참치마요 삼각김밥',
  ),
  Gifticon(
    id: 'conv_002',
    name: '초코파이',
    emoji: '🍫',
    category: GifticonCategory.convenience,
    requiredPoints: 200,
    description: '촉촉한 케이크에 달콤한 초콜릿이 가득',
  ),
  Gifticon(
    id: 'conv_003',
    name: '젤리세트',
    emoji: '🍬',
    category: GifticonCategory.convenience,
    requiredPoints: 300,
    description: '다양한 맛의 알록달록 젤리 모음',
  ),
  Gifticon(
    id: 'conv_004',
    name: '음료수',
    emoji: '🥤',
    category: GifticonCategory.convenience,
    requiredPoints: 150,
    description: '편의점에서 골라 마시는 시원한 음료수',
  ),

  // 아이스크림
  Gifticon(
    id: 'ice_001',
    name: '메로나',
    emoji: '🍈',
    category: GifticonCategory.icecream,
    requiredPoints: 200,
    description: '달콤한 멜론 맛 국민 아이스크림',
  ),
  Gifticon(
    id: 'ice_002',
    name: '월드콘',
    emoji: '🍦',
    category: GifticonCategory.icecream,
    requiredPoints: 400,
    description: '콘 아이스크림의 클래식, 바삭한 콘과 풍부한 크림',
  ),
  Gifticon(
    id: 'ice_003',
    name: '빠삐코',
    emoji: '🧊',
    category: GifticonCategory.icecream,
    requiredPoints: 250,
    description: '짜먹는 슬러시 아이스크림, 여름 필수템',
  ),
  Gifticon(
    id: 'ice_004',
    name: '탱크보이',
    emoji: '🍧',
    category: GifticonCategory.icecream,
    requiredPoints: 600,
    description: '크고 시원한 빙수 아이스크림, 탱크처럼 든든한 크기',
  ),
];
