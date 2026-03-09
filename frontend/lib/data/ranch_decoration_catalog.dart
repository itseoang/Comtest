import '../models/ranch_decoration.dart';

// ---------------------------------------------------------------------------
// Decoration catalog – 장식물 13 + 시설물 6 + 테마 7
// ---------------------------------------------------------------------------

const List<DecorationItemDef> kDecorationCatalog = [
  // ── 장식물 ──────────────────────────────────────────
  DecorationItemDef(
    id: 'deco_pine',
    name: '소나무',
    emoji: '🌲',
    category: DecorationCategory.decoration,
    price: 0,
    description: '사계절 푸른 소나무',
  ),
  DecorationItemDef(
    id: 'deco_oak',
    name: '참나무',
    emoji: '🌳',
    category: DecorationCategory.decoration,
    price: 0,
    description: '튼튼한 참나무',
  ),
  DecorationItemDef(
    id: 'deco_sunflower',
    name: '해바라기',
    emoji: '🌻',
    category: DecorationCategory.decoration,
    price: 0,
    description: '햇살을 따라 고개를 돌리는 꽃',
  ),
  DecorationItemDef(
    id: 'deco_rock',
    name: '돌',
    emoji: '🪨',
    category: DecorationCategory.decoration,
    price: 0,
    description: '자연 그대로의 돌',
  ),
  DecorationItemDef(
    id: 'deco_palm',
    name: '야자수',
    emoji: '🌴',
    category: DecorationCategory.decoration,
    price: 30,
    description: '열대 느낌의 야자수',
  ),
  DecorationItemDef(
    id: 'deco_cherry',
    name: '벚꽃',
    emoji: '🌸',
    category: DecorationCategory.decoration,
    price: 20,
    description: '봄바람에 흩날리는 벚꽃',
  ),
  DecorationItemDef(
    id: 'deco_rose',
    name: '장미',
    emoji: '🌹',
    category: DecorationCategory.decoration,
    price: 25,
    description: '향기로운 붉은 장미',
  ),
  DecorationItemDef(
    id: 'deco_tulip',
    name: '튤립',
    emoji: '🌷',
    category: DecorationCategory.decoration,
    price: 20,
    description: '다채로운 색의 튤립',
  ),
  DecorationItemDef(
    id: 'deco_fence',
    name: '울타리',
    emoji: '🏗️',
    category: DecorationCategory.decoration,
    price: 15,
    description: '목장을 감싸는 나무 울타리',
  ),
  DecorationItemDef(
    id: 'deco_mushroom',
    name: '버섯',
    emoji: '🍄',
    category: DecorationCategory.decoration,
    price: 15,
    description: '귀여운 빨간 버섯',
  ),
  DecorationItemDef(
    id: 'deco_cactus',
    name: '선인장',
    emoji: '🌵',
    category: DecorationCategory.decoration,
    price: 25,
    description: '물 없이도 잘 자라는 선인장',
  ),
  DecorationItemDef(
    id: 'deco_xmas_tree',
    name: '크리스마스트리',
    emoji: '🎄',
    category: DecorationCategory.decoration,
    price: 50,
    requiredPetLevel: 8,
    description: '반짝이는 크리스마스트리',
  ),
  DecorationItemDef(
    id: 'deco_bamboo',
    name: '대나무',
    emoji: '🎋',
    category: DecorationCategory.decoration,
    price: 40,
    requiredPetLevel: 5,
    description: '바람에 흔들리는 대나무',
  ),

  // ── 시설물 ──────────────────────────────────────────
  DecorationItemDef(
    id: 'fac_house',
    name: '집',
    emoji: '🏡',
    category: DecorationCategory.facility,
    price: 100,
    gridWidth: 2,
    gridHeight: 2,
    description: '아늑한 목장의 집',
  ),
  DecorationItemDef(
    id: 'fac_bridge',
    name: '다리',
    emoji: '🌉',
    category: DecorationCategory.facility,
    price: 80,
    gridWidth: 2,
    gridHeight: 1,
    description: '연못을 건너는 작은 다리',
  ),
  DecorationItemDef(
    id: 'fac_bench',
    name: '벤치',
    emoji: '🪑',
    category: DecorationCategory.facility,
    price: 40,
    description: '쉬어가는 나무 벤치',
  ),
  DecorationItemDef(
    id: 'fac_lamp',
    name: '가로등',
    emoji: '🏮',
    category: DecorationCategory.facility,
    price: 50,
    description: '따뜻한 빛의 가로등',
  ),
  DecorationItemDef(
    id: 'fac_tent',
    name: '텐트',
    emoji: '⛺',
    category: DecorationCategory.facility,
    price: 120,
    requiredPetLevel: 3,
    gridWidth: 2,
    gridHeight: 2,
    description: '야외 캠핑 텐트',
  ),
  DecorationItemDef(
    id: 'fac_fountain',
    name: '분수',
    emoji: '⛲',
    category: DecorationCategory.facility,
    price: 200,
    requiredCollections: 10,
    gridWidth: 2,
    gridHeight: 2,
    description: '물줄기가 솟아오르는 분수',
  ),

  // ── 테마 ──────────────────────────────────────────
  DecorationItemDef(
    id: 'theme_spring',
    name: '봄 테마',
    emoji: '🌸',
    category: DecorationCategory.theme,
    price: 0,
    description: '벚꽃이 흩날리는 봄 풍경',
  ),
  DecorationItemDef(
    id: 'theme_summer',
    name: '여름 테마',
    emoji: '☀️',
    category: DecorationCategory.theme,
    price: 0,
    description: '푸른 초원의 여름 풍경 (기본)',
  ),
  DecorationItemDef(
    id: 'theme_fall',
    name: '가을 테마',
    emoji: '🍂',
    category: DecorationCategory.theme,
    price: 50,
    description: '단풍이 물드는 가을 풍경',
  ),
  DecorationItemDef(
    id: 'theme_winter',
    name: '겨울 테마',
    emoji: '❄️',
    category: DecorationCategory.theme,
    price: 80,
    description: '눈 내리는 겨울 풍경',
  ),
  DecorationItemDef(
    id: 'theme_forest',
    name: '숲 테마',
    emoji: '🌲',
    category: DecorationCategory.theme,
    price: 100,
    requiredPetLevel: 5,
    description: '울창한 숲속 풍경',
  ),
  DecorationItemDef(
    id: 'theme_desert',
    name: '사막 테마',
    emoji: '🏜️',
    category: DecorationCategory.theme,
    price: 120,
    requiredCollections: 8,
    description: '신비로운 사막 풍경',
  ),
  DecorationItemDef(
    id: 'theme_ocean',
    name: '바다 테마',
    emoji: '🌊',
    category: DecorationCategory.theme,
    price: 150,
    requiredPetLevel: 10,
    description: '시원한 바다 풍경',
  ),
];

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

DecorationItemDef? findDecorationById(String id) {
  try {
    return kDecorationCatalog.firstWhere((d) => d.id == id);
  } catch (_) {
    return null;
  }
}

List<DecorationItemDef> getDecorationsByCategory(DecorationCategory category) {
  return kDecorationCatalog.where((d) => d.category == category).toList();
}

List<DecorationItemDef> getThemeCatalog() {
  return getDecorationsByCategory(DecorationCategory.theme);
}
