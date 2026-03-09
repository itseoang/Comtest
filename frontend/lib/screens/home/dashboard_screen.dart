import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/challenge/challenge_bloc.dart';
import '../../blocs/collection/collection_bloc.dart';
import '../../blocs/pet/pet_bloc.dart';
import '../../blocs/quiz/quiz_bloc.dart';
import '../../widgets/pet/pet_dashboard_card.dart';
import '../../widgets/pet/pet_select_sheet.dart';

// ─────────────────────────────────────────
// Mock Data Models
// ─────────────────────────────────────────

class _PopularItem {
  const _PopularItem({
    required this.name,
    required this.category,
    required this.location,
    required this.likes,
    required this.icon,
    required this.color,
    required this.author,
    required this.emoji,
    required this.bgColors,
  });

  final String name;
  final String category;
  final String location;
  final int likes;
  final IconData icon;
  final Color color;
  final String author;
  final String emoji;
  final List<Color> bgColors;
}

class _CommunityPost {
  const _CommunityPost({
    required this.avatarLabel,
    required this.nickname,
    required this.timeAgo,
    required this.content,
    required this.likes,
    required this.comments,
  });

  final String avatarLabel;
  final String nickname;
  final String timeAgo;
  final String content;
  final int likes;
  final int comments;
}

const _kPopularItems = [
  _PopularItem(
    name: '벚꽃',
    category: '식물',
    location: '여의도공원',
    likes: 128,
    icon: Icons.local_florist,
    color: Color(0xFFE91E63),
    author: '하늘이맘',
    emoji: '🌸',
    bgColors: [Color(0xFFFCE4EC), Color(0xFFF8BBD0)],
  ),
  _PopularItem(
    name: '직박구리',
    category: '조류',
    location: '북한산',
    likes: 95,
    icon: Icons.flutter_dash,
    color: Color(0xFF2196F3),
    author: '새탐험가',
    emoji: '🐦',
    bgColors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
  ),
  _PopularItem(
    name: '호랑나비',
    category: '곤충',
    location: '서울숲',
    likes: 87,
    icon: Icons.emoji_nature,
    color: Color(0xFFFF9800),
    author: '나비소녀',
    emoji: '🦋',
    bgColors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
  ),
  _PopularItem(
    name: '고라니',
    category: '포유류',
    location: '양재천',
    likes: 76,
    icon: Icons.pets,
    color: Color(0xFF795548),
    author: '숲속친구',
    emoji: '🦌',
    bgColors: [Color(0xFFEFEBE9), Color(0xFFD7CCC8)],
  ),
  _PopularItem(
    name: '개구리',
    category: '양서류',
    location: '청계천',
    likes: 64,
    icon: Icons.cruelty_free,
    color: Color(0xFF4CAF50),
    author: '연못지기',
    emoji: '🐸',
    bgColors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
  ),
];

const _kCommunityPosts = [
  _CommunityPost(
    avatarLabel: '민',
    nickname: '민수네자연교실',
    timeAgo: '2시간 전',
    content: '오늘 한강공원에서 청둥오리 가족을 발견했어요! 아기 오리가 줄지어 따라가는 모습이 너무 귀여웠어요 🦆',
    likes: 24,
    comments: 8,
  ),
  _CommunityPost(
    avatarLabel: '서',
    nickname: '서연이의도감',
    timeAgo: '5시간 전',
    content: '우리 동네 텃밭에서 무당벌레를 찾았어요. 점이 7개인 칠성무당벌레였어요!',
    likes: 18,
    comments: 5,
  ),
  _CommunityPost(
    avatarLabel: '지',
    nickname: '지호탐험대',
    timeAgo: '어제',
    content: '청계산에서 도롱뇽 알을 발견! 투명한 젤리 같은 알 속에 작은 생명이 보여요 🥚',
    likes: 42,
    comments: 12,
  ),
];

// ─────────────────────────────────────────
// Main Screen
// ─────────────────────────────────────────

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAF5),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          '자연도감',
          style: TextStyle(
            color: Color(0xFF2E7D32),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF3E2723),
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.search,
              color: Color(0xFF3E2723),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GreetingBanner(),
              const SizedBox(height: 16),
              const PetDashboardCard(),
              const SizedBox(height: 20),
              _QuickMenuRow(),
              const SizedBox(height: 20),
              const _ChallengeBanner(),
              const SizedBox(height: 20),
              _SectionHeader(title: '인기 관찰', onMore: () {}),
              const SizedBox(height: 12),
              const _PopularDiscoveriesRow(),
              const SizedBox(height: 20),
              _SectionHeader(title: '커뮤니티 소식', onMore: () {}),
              const SizedBox(height: 12),
              const _CommunityFeed(),
              const SizedBox(height: 20),
              const _NatureTipCard(),
              const SizedBox(height: 20),
              const _EcoPointBanner(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Section Header
// ─────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onMore});

  final String title;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF3E2723),
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onMore,
          child: const Text(
            '더보기',
            style: TextStyle(
              color: Color(0xFF2E7D32),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// 1. Greeting Banner (compact)
// ─────────────────────────────────────────

class _GreetingBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final nickname = state is Authenticated ? state.profile.nickname : '탐험가';
        final now = DateTime.now();
        final dateStr = '${now.year}년 ${now.month}월 ${now.day}일';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '안녕, $nickname!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.forest,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────
// 2. Quick Menu Row (horizontal scroll)
// ─────────────────────────────────────────

class _QuickMenuRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      _QuickMenuItem(
        icon: Icons.collections_bookmark,
        label: '내 도감',
        color: const Color(0xFF4CAF50),
        onTap: () => context.push('/home/collection'),
      ),
      _QuickMenuItem(
        icon: Icons.camera_alt,
        label: '종 식별',
        color: const Color(0xFF2196F3),
        onTap: () => context.go('/identify'),
      ),
      _QuickMenuItem(
        icon: Icons.auto_stories,
        label: '관찰 일기',
        color: const Color(0xFFFF9800),
        onTap: () => context.go('/diary'),
      ),
      _QuickMenuItem(
        icon: Icons.people,
        label: '친구',
        color: const Color(0xFF9C27B0),
        onTap: () => context.go('/friends'),
      ),
      _QuickMenuItem(
        icon: Icons.pets,
        label: '내 펫',
        color: const Color(0xFF795548),
        onTap: () {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: context.read<CollectionBloc>()),
                BlocProvider.value(value: context.read<PetBloc>()),
              ],
              child: const PetSelectSheet(),
            ),
          );
        },
      ),
      _QuickMenuItem(
        icon: Icons.person,
        label: '프로필',
        color: const Color(0xFF607D8B),
        onTap: () => context.go('/profile'),
      ),
    ];

    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) => _QuickMenuChip(item: items[index]),
      ),
    );
  }
}

class _QuickMenuItem {
  const _QuickMenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
}

class _QuickMenuChip extends StatelessWidget {
  const _QuickMenuChip({required this.item});

  final _QuickMenuItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              color: item.color,
              size: 26,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.label,
            style: const TextStyle(
              color: Color(0xFF3E2723),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// 3. Weekly Challenge Banner
// ─────────────────────────────────────────

class _ChallengeBanner extends StatelessWidget {
  const _ChallengeBanner();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChallengeBloc, ChallengeState>(
      builder: (context, state) {
        String title = '이번 주 챌린지';
        int completed = 0;
        int total = 1;
        double ratio = 0;

        if (state is ChallengeLoaded) {
          title = state.challenge.title;
          completed = state.challenge.completedCount;
          total = state.challenge.totalCount;
          ratio = state.challenge.progress;
        } else if (state is ChallengeRewardClaimed) {
          title = state.challenge.title;
          completed = state.challenge.completedCount;
          total = state.challenge.totalCount;
          ratio = state.challenge.progress;
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '🌿 이번 주 챌린지',
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.push('/home/challenge'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '참여하기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF3E2723),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: ratio,
                        backgroundColor: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                        minHeight: 7,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$completed / $total 완료',
                    style: const TextStyle(
                      color: Color(0xFF2E7D32),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────
// 4. Popular Discoveries (horizontal scroll)
// ─────────────────────────────────────────

class _PopularDiscoveriesRow extends StatelessWidget {
  const _PopularDiscoveriesRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _kPopularItems.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) =>
            _PopularCard(item: _kPopularItems[index]),
      ),
    );
  }
}

class _PopularCard extends StatelessWidget {
  const _PopularCard({required this.item});

  final _PopularItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo-style area with emoji
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: item.bgColors,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Stack(
              children: [
                // Large emoji as mock photo
                Center(
                  child: Text(
                    item.emoji,
                    style: const TextStyle(fontSize: 52),
                  ),
                ),
                // Category badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      item.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // Like badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.favorite, color: Colors.white, size: 11),
                        const SizedBox(width: 3),
                        Text(
                          '${item.likes}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Info area
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color: Color(0xFF3E2723),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 12, color: Color(0xFF8D6E63)),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        item.location,
                        style: const TextStyle(
                          color: Color(0xFF8D6E63),
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Author row
                Row(
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: item.color.withValues(alpha: 0.15),
                      child: Text(
                        item.author[0],
                        style: TextStyle(
                          color: item.color,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        item.author,
                        style: const TextStyle(
                          color: Color(0xFF795548),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// 5. Community Feed
// ─────────────────────────────────────────

class _CommunityFeed extends StatelessWidget {
  const _CommunityFeed();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < _kCommunityPosts.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _CommunityPostCard(post: _kCommunityPosts[i]),
        ],
      ],
    );
  }
}

class _CommunityPostCard extends StatelessWidget {
  const _CommunityPostCard({required this.post});

  final _CommunityPost post;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info row
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                child: Text(
                  post.avatarLabel,
                  style: const TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.nickname,
                      style: const TextStyle(
                        color: Color(0xFF3E2723),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      post.timeAgo,
                      style: const TextStyle(
                        color: Color(0xFF8D6E63),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Content
          Text(
            post.content,
            style: const TextStyle(
              color: Color(0xFF3E2723),
              fontSize: 13.5,
              height: 1.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          // Action row
          Row(
            children: [
              _ActionChip(
                icon: Icons.favorite_border,
                count: post.likes,
                onTap: () {},
              ),
              const SizedBox(width: 16),
              _ActionChip(
                icon: Icons.chat_bubble_outline,
                count: post.comments,
                onTap: () {},
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {},
                child: const Icon(
                  Icons.share_outlined,
                  color: Color(0xFF8D6E63),
                  size: 17,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.count,
    required this.onTap,
  });

  final IconData icon;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF8D6E63), size: 17),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: const TextStyle(
              color: Color(0xFF8D6E63),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// 6. Nature Tip Card
// ─────────────────────────────────────────

class _NatureTipCard extends StatelessWidget {
  const _NatureTipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFCA28).withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFCA28).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '💡 오늘의 자연 팁',
                  style: TextStyle(
                    color: Color(0xFF795548),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '봄철 야생화 관찰 시 꽃잎의 수를 세어보세요. 꽃잎 수로 식물 과(科)를 추정할 수 있어요!',
            style: TextStyle(
              color: Color(0xFF3E2723),
              fontSize: 13.5,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// 7. Eco Point Banner (existing, preserved)
// ─────────────────────────────────────────

class _EcoPointBanner extends StatelessWidget {
  const _EcoPointBanner();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final ecoPoints = state is Authenticated ? state.profile.ecoPoints : 0;
        final quizCount = context.read<QuizBloc>().history.results.length;

        return GestureDetector(
          onTap: () => context.push('/profile/gifticon-exchange'),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.eco,
                    color: Color(0xFF2E7D32),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            '에코 포인트',
                            style: TextStyle(
                              color: Color(0xFF3E2723),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${ecoPoints}pt',
                              style: const TextStyle(
                                color: Color(0xFF2E7D32),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        quizCount > 0
                            ? '퀴즈 ${quizCount}문제 풀었어요!'
                            : '퀴즈를 풀면 포인트를 획득해요!',
                        style: const TextStyle(
                          color: Color(0xFF795548),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF9E9E9E),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
