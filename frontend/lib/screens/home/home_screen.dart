import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/collection/collection_bloc.dart';
import '../../models/collection.dart';
import '../../services/map_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = '전체';
  bool _showAll = false;
  String? _expandedItemId;

  // 사용자 현재 위치 (mock: 서울 중심부)
  static const double _userLat = 37.5665;
  static const double _userLng = 126.9780;

  static const _categories = ['전체', '식물', '조류', '곤충', '포유류', '양서류'];

  static const _categoryMap = {
    '식물': 'plant',
    '조류': 'bird',
    '곤충': 'insect',
    '포유류': 'mammal',
    '양서류': 'amphibian',
  };

  static final _friendItems = [
    CollectionItem(
      id: 'friend-001',
      cardNumber: '#F01',
      speciesName: '벚꽃',
      speciesCategory: 'plant',
      stats: const CardStats(
        hp: 55,
        attack: 15,
        defense: 50,
        speed: 20,
        charm: 85,
        rarityScore: 60,
      ),
      locationName: '여의도공원',
      discoveredAt: DateTime(2026, 3, 2, 11, 0),
      weather: '☀️ 맑음',
      latitude: 37.5264,
      longitude: 126.9246,
    ),
    CollectionItem(
      id: 'friend-002',
      cardNumber: '#F02',
      speciesName: '청둥오리',
      speciesCategory: 'bird',
      stats: const CardStats(
        hp: 60,
        attack: 45,
        defense: 55,
        speed: 50,
        charm: 70,
        rarityScore: 55,
      ),
      locationName: '한강공원',
      discoveredAt: DateTime(2026, 3, 1, 9, 30),
      weather: '⛅ 구름 조금',
      latitude: 37.5283,
      longitude: 126.9340,
    ),
    CollectionItem(
      id: 'friend-003',
      cardNumber: '#F03',
      speciesName: '호랑나비',
      speciesCategory: 'insect',
      stats: const CardStats(
        hp: 25,
        attack: 30,
        defense: 20,
        speed: 80,
        charm: 90,
        rarityScore: 70,
      ),
      locationName: '서울숲',
      discoveredAt: DateTime(2026, 2, 28, 14, 0),
      weather: '☀️ 맑음',
      latitude: 37.5445,
      longitude: 127.0374,
    ),
    CollectionItem(
      id: 'friend-004',
      cardNumber: '#F04',
      speciesName: '너구리',
      speciesCategory: 'mammal',
      stats: const CardStats(
        hp: 65,
        attack: 50,
        defense: 60,
        speed: 40,
        charm: 55,
        rarityScore: 52,
      ),
      locationName: '관악산',
      discoveredAt: DateTime(2026, 3, 3, 7, 0),
      weather: '🌫️ 안개',
      latitude: 37.4436,
      longitude: 126.9640,
    ),
  ];

  // 주변 추천 장소 mock 데이터
  static final _nearbySpots = {
    '여의도공원': {
      'tourism': ['여의도 한강공원', '63빌딩 전망대', 'IFC몰'],
      'food': ['여의도 맛집거리', '마포 양꼬치'],
      'experience': ['한강 자전거 대여', '여의도 피크닉'],
    },
    '한강공원': {
      'tourism': ['반포대교 달빛무지개분수', '세빛섬'],
      'food': ['반포 카페거리', '이촌 맛집'],
      'experience': ['한강 카약', '편의점 피크닉'],
    },
    '서울숲': {
      'tourism': ['서울숲 갤러리', '뚝섬유원지'],
      'food': ['성수동 카페거리', '서울숲 브런치'],
      'experience': ['사슴 먹이주기', '숲속 산책로'],
    },
    '관악산': {
      'tourism': ['관악산 전망대', '서울대 캠퍼스'],
      'food': ['신림동 순대타운', '낙성대 맛집'],
      'experience': ['관악산 등산', '계곡 물놀이'],
    },
  };

  // Haversine 공식으로 두 좌표 간 거리 계산 (km)
  double _haversineDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const r = 6371.0; // 지구 반지름 (km)
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  double _toRad(double deg) => deg * pi / 180;

  String _formatDistance(double km) {
    if (km < 1.0) {
      return '${(km * 1000).round()}m';
    }
    return '${km.toStringAsFixed(1)}km';
  }

  @override
  void initState() {
    super.initState();
    context.read<CollectionBloc>().add(const LoadCollections());
  }

  ({IconData icon, Color color}) _categoryStyle(String category) {
    switch (category) {
      case 'plant':
        return (icon: Icons.eco, color: const Color(0xFF2E7D32));
      case 'bird':
        return (icon: Icons.flutter_dash, color: const Color(0xFF1565C0));
      case 'insect':
        return (icon: Icons.bug_report, color: const Color(0xFFE65100));
      case 'mammal':
        return (icon: Icons.pets, color: const Color(0xFF4E342E));
      case 'amphibian':
        return (icon: Icons.water, color: const Color(0xFF00695C));
      default:
        return (icon: Icons.nature, color: const Color(0xFF757575));
    }
  }

  List<CollectionItem> _filteredItems(List<CollectionItem> myItems) {
    // 미보유 아이템을 거리 기준 정렬
    final sortedFriendItems = [..._friendItems];
    sortedFriendItems.sort((a, b) {
      final distA = (a.latitude != null && a.longitude != null)
          ? _haversineDistance(_userLat, _userLng, a.latitude!, a.longitude!)
          : double.infinity;
      final distB = (b.latitude != null && b.longitude != null)
          ? _haversineDistance(_userLat, _userLng, b.latitude!, b.longitude!)
          : double.infinity;
      return distA.compareTo(distB);
    });

    // 전체 도감: 내 것 먼저 → 미보유(거리순) 뒤에 표시
    final allItems = _showAll ? [...myItems, ...sortedFriendItems] : myItems;
    if (_selectedCategory == '전체') return allItems;
    final categoryKey = _categoryMap[_selectedCategory];
    return allItems
        .where((item) => item.speciesCategory == categoryKey)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAF5),
        elevation: 0,
        title: const Text(
          '도감',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3E2723),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF3E2723)),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<CollectionBloc, CollectionState>(
        builder: (context, state) {
          if (state is CollectionLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CollectionError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (state is CollectionLoaded) {
            return _buildBody(context, state.items);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<CollectionItem> myItems) {
    final filtered = _filteredItems(myItems);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildToggle(myItems),
        _buildCategoryChips(),
        Expanded(
          child: filtered.isEmpty
              ? _buildEmptyState()
              : _buildList(filtered, myItems),
        ),
      ],
    );
  }

  Widget _buildToggle(List<CollectionItem> myItems) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFEFEBE9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  _toggleButton(
                    label: '내 도감',
                    count: myItems.length,
                    selected: !_showAll,
                    onTap: () => setState(() => _showAll = false),
                  ),
                  _toggleButton(
                    label: '전체 도감',
                    count: myItems.length + _friendItems.length,
                    selected: _showAll,
                    onTap: () => setState(() => _showAll = true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleButton({
    required String label,
    required int count,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF2E7D32) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? Colors.white
                      : const Color(0xFF8D6E63),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.25)
                      : const Color(0xFFD7CCC8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : const Color(0xFF8D6E63),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final selected = _selectedCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFEFEBE9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFD7CCC8),
                  width: 1,
                ),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : const Color(0xFF5D4037),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            _selectedCategory == '전체'
                ? '아직 발견한 생물이 없어요'
                : '이 카테고리에 발견한 생물이 없어요',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3E2723),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '직접 탐험하고 발견해보세요!',
            style: TextStyle(
              fontSize: 13,
              color: const Color(0xFF3E2723).withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
    List<CollectionItem> items,
    List<CollectionItem> myItems,
  ) {
    final myIds = myItems.map((e) => e.id).toSet();
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = items[index];
        final isFriend = !myIds.contains(item.id);
        return _buildListItem(context, item, isFriend: isFriend);
      },
    );
  }

  Widget _buildListItem(
    BuildContext context,
    CollectionItem item, {
    required bool isFriend,
  }) {
    final style = _categoryStyle(item.speciesCategory);
    final isExpanded = _expandedItemId == item.id;

    // 내 것 = 컬러, 미보유(친구) = 그레이
    final iconColor = isFriend ? const Color(0xFFBDBDBD) : style.color;
    final iconBgColor = isFriend
        ? const Color(0xFFEEEEEE)
        : style.color.withValues(alpha: 0.15);
    final nameColor = isFriend
        ? const Color(0xFF9E9E9E)
        : const Color(0xFF3E2723);
    final subColor = isFriend
        ? const Color(0xFFBDBDBD)
        : const Color(0xFF8D6E63);

    // 거리 계산 (미보유 아이템만)
    double? distanceKm;
    if (isFriend && item.latitude != null && item.longitude != null) {
      distanceKm = _haversineDistance(
        _userLat,
        _userLng,
        item.latitude!,
        item.longitude!,
      );
    }

    return GestureDetector(
      onTap: isFriend
          ? () {
              setState(() {
                _expandedItemId = isExpanded ? null : item.id;
              });
            }
          : () => context.push('/home/collection/${item.id}'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isFriend ? const Color(0xFFF5F5F5) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isFriend
                ? (isExpanded
                    ? const Color(0xFF66BB6A)
                    : const Color(0xFFE0E0E0))
                : const Color(0xFFEFEBE9),
            width: isExpanded ? 1.5 : 1,
          ),
          boxShadow: isFriend
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 메인 아이템 행
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // 카테고리 아이콘 원형
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(style.icon, size: 24, color: iconColor),
                      ),
                      if (isFriend)
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Color(0xFFBDBDBD),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lock,
                              size: 11,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  // 텍스트 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                item.speciesName,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: nameColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isFriend) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0E0E0),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  '미발견',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF9E9E9E),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            if (item.locationName != null) ...[
                              Icon(
                                Icons.location_on_outlined,
                                size: 12,
                                color: isFriend
                                    ? const Color(0xFF66BB6A)
                                    : subColor,
                              ),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  item.locationName!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: subColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // 거리 표시 (미보유 아이템만)
                              if (isFriend && distanceKm != null) ...[
                                Text(
                                  ' · ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: subColor,
                                  ),
                                ),
                                Text(
                                  _formatDistance(distanceKm),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF66BB6A),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                              if (!isFriend && item.discoveredAt != null)
                                Text(
                                  ' · ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: subColor,
                                  ),
                                ),
                            ],
                            if (!isFriend && item.discoveredAt != null)
                              Text(
                                '${item.discoveredAt!.month}/${item.discoveredAt!.day}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: subColor,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.cardNumber,
                          style: TextStyle(
                            fontSize: 11,
                            color: isFriend
                                ? const Color(0xFFBDBDBD)
                                : const Color(0xFF3E2723).withValues(alpha: 0.35),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 오른쪽 영역: 미보유는 촬영장소 버튼, 보유는 희귀도 뱃지
                  if (isFriend)
                    _buildLocationButton(item)
                  else
                    _buildRarityBadge(item.stats.rarityScore),
                ],
              ),
            ),
            // 확장 영역 (미보유 아이템이 탭될 때)
            if (isFriend)
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: isExpanded
                    ? _buildNearbySection(item)
                    : const SizedBox.shrink(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationButton(CollectionItem item) {
    return GestureDetector(
      onTap: () {
        MapLauncher.openNaverMap(
          placeName: item.locationName ?? item.speciesName,
          latitude: item.latitude,
          longitude: item.longitude,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF66BB6A),
            width: 1,
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.map_outlined,
              size: 14,
              color: Color(0xFF2E7D32),
            ),
            SizedBox(width: 4),
            Text(
              '촬영장소',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbySection(CollectionItem item) {
    final locationKey = item.locationName;
    final spots = locationKey != null ? _nearbySpots[locationKey] : null;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(13),
          bottomRight: Radius.circular(13),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.place_outlined,
                      size: 14,
                      color: Color(0xFF66BB6A),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${locationKey ?? '이 장소'} 주변 추천',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (spots != null) ...[
                  _buildSpotCategory(
                    emoji: '🏛',
                    label: '관광',
                    spots: spots['tourism'] ?? [],
                    baseLocation: locationKey,
                  ),
                  const SizedBox(height: 8),
                  _buildSpotCategory(
                    emoji: '🍽',
                    label: '맛집',
                    spots: spots['food'] ?? [],
                    baseLocation: locationKey,
                  ),
                  const SizedBox(height: 8),
                  _buildSpotCategory(
                    emoji: '🎯',
                    label: '체험',
                    spots: spots['experience'] ?? [],
                    baseLocation: locationKey,
                  ),
                ] else
                  const Text(
                    '주변 정보를 불러올 수 없어요',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFBDBDBD),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpotCategory({
    required String emoji,
    required String label,
    required List<dynamic> spots,
    required String? baseLocation,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 40,
          child: Text(
            '$emoji $label',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5D4037),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 28,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: spots.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final spotName = spots[index] as String;
                return GestureDetector(
                  onTap: () {
                    MapLauncher.openNaverMap(placeName: spotName);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFD7CCC8),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      spotName,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF5D4037),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRarityBadge(int score) {
    final Color badgeColor;
    final String label;
    if (score >= 80) {
      badgeColor = const Color(0xFFFF8F00);
      label = '희귀';
    } else if (score >= 60) {
      badgeColor = const Color(0xFF1565C0);
      label = '특이';
    } else {
      badgeColor = const Color(0xFF2E7D32);
      label = '일반';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: badgeColor.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: badgeColor,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$score pt',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: badgeColor.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
