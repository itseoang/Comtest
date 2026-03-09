import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/challenge/challenge_bloc.dart';
import '../../blocs/pet/pet_bloc.dart';
import '../../config/constants.dart';
import '../../models/challenge.dart';
import '../../models/pet.dart';
import '../../services/ad_service.dart';
import '../../widgets/pet/pet_avatar.dart';

// ---------------------------------------------------------------------------
// 하트 파티클 데이터 클래스
// ---------------------------------------------------------------------------
class _HeartParticle {
  _HeartParticle({
    required this.key,
    required this.top,
    required this.left,
  });

  final Key key;
  double top;
  double left;
  double opacity = 1.0;
}

// ---------------------------------------------------------------------------
// PetDetailScreen
// ---------------------------------------------------------------------------
class PetDetailScreen extends StatefulWidget {
  const PetDetailScreen({super.key});

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  final List<_HeartParticle> _particles = [];
  final Random _random = Random();

  // -------------------------------------------------------------------------
  // 헬퍼: 카테고리 색상
  // -------------------------------------------------------------------------
  Color _categoryColor(String category) {
    switch (category) {
      case 'plant':
        return const Color(0xFF4CAF50);
      case 'bird':
        return const Color(0xFF2196F3);
      case 'insect':
        return const Color(0xFFFF9800);
      case 'mammal':
        return const Color(0xFF795548);
      case 'amphibian':
        return const Color(0xFF009688);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  // -------------------------------------------------------------------------
  // 헬퍼: 성장 단계 레이블
  // -------------------------------------------------------------------------
  String _stageLabel(PetGrowthStage stage) {
    switch (stage) {
      case PetGrowthStage.egg:
        return '알/씨앗';
      case PetGrowthStage.baby:
        return '아기';
      case PetGrowthStage.juvenile:
        return '청소년';
      case PetGrowthStage.adult:
        return '성체';
    }
  }

  // -------------------------------------------------------------------------
  // 헬퍼: 카테고리 + 성장단계별 이모지
  // -------------------------------------------------------------------------
  String _stageEmojiForCategory(String category, PetGrowthStage stage) {
    switch (category) {
      case 'plant':
        switch (stage) {
          case PetGrowthStage.egg:
            return '🌰';
          case PetGrowthStage.baby:
            return '🌱';
          case PetGrowthStage.juvenile:
            return '🌿';
          case PetGrowthStage.adult:
            return '🌸';
        }
      case 'bird':
        switch (stage) {
          case PetGrowthStage.egg:
            return '🥚';
          case PetGrowthStage.baby:
            return '🐣';
          case PetGrowthStage.juvenile:
            return '🐦';
          case PetGrowthStage.adult:
            return '🦅';
        }
      case 'insect':
        switch (stage) {
          case PetGrowthStage.egg:
            return '🟡';
          case PetGrowthStage.baby:
            return '🐛';
          case PetGrowthStage.juvenile:
            return '🫎';
          case PetGrowthStage.adult:
            return '🐞';
        }
      case 'mammal':
        switch (stage) {
          case PetGrowthStage.egg:
            return '🍼';
          case PetGrowthStage.baby:
            return '🐿️';
          case PetGrowthStage.juvenile:
            return '🐾';
          case PetGrowthStage.adult:
            return '🏔️';
        }
      case 'amphibian':
        switch (stage) {
          case PetGrowthStage.egg:
            return '🫧';
          case PetGrowthStage.baby:
            return '🦎';
          case PetGrowthStage.juvenile:
            return '🔄';
          case PetGrowthStage.adult:
            return '🦗';
        }
      default:
        return '🐾';
    }
  }

  // -------------------------------------------------------------------------
  // 헬퍼: 경과 시간 텍스트
  // -------------------------------------------------------------------------
  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }

  // -------------------------------------------------------------------------
  // 미니게임: 하트 파티클 생성
  // -------------------------------------------------------------------------
  void _spawnHeart() {
    final particle = _HeartParticle(
      key: ValueKey(DateTime.now().microsecondsSinceEpoch),
      top: 60.0 + _random.nextDouble() * 40.0,
      left: 80.0 + _random.nextDouble() * 140.0,
    );

    setState(() {
      _particles.add(particle);
    });

    // 애니메이션 시작: 위로 올라가며 투명해짐
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        setState(() {
          particle.top -= 70;
          particle.opacity = 0.0;
        });
      }
    });

    // 파티클 제거
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() {
          _particles.remove(particle);
        });
      }
    });
  }

  // -------------------------------------------------------------------------
  // 미니게임: 광고 보고 터치 충전
  // -------------------------------------------------------------------------
  Future<void> _showRewardedAd(BuildContext context) async {
    final adService = AdService.instance;

    if (!adService.isAdReady) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('광고를 준비 중이에요. 잠시 후 다시 시도해주세요!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      adService.loadRewardedAd();
      return;
    }

    await adService.showRewardedAd(
      onRewarded: () {
        if (context.mounted) {
          context.read<PetBloc>().add(const ResetMiniGameSession());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('터치가 충전되었어요! 더 놀아주세요!'),
              backgroundColor: Color(0xFF4CAF50),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }

  // -------------------------------------------------------------------------
  // 빌드: EXP 바
  // -------------------------------------------------------------------------
  Widget _buildExpBar(Pet pet, Color categoryColor) {
    final progress = pet.maxExp > 0 ? pet.exp / pet.maxExp : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'EXP',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: categoryColor,
              ),
            ),
            Text(
              '${pet.exp} / ${pet.maxExp}',
              style: const TextStyle(fontSize: 11, color: Color(0xFF8D6E63)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: const Color(0xFFE8E0DB),
            valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // 빌드: 게이지 바 (배고픔, 갈증, 행복)
  // -------------------------------------------------------------------------
  Widget _buildGauge(
    String label,
    int value,
    IconData icon,
    Color color,
  ) {
    final progress = value / 100.0;
    Color barColor;
    if (value >= 60) {
      barColor = color;
    } else if (value >= 30) {
      barColor = Colors.orange;
    } else {
      barColor = Colors.red.shade400;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: barColor),
            const SizedBox(width: 3),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF8D6E63),
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 11,
                color: barColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: const Color(0xFFE8E0DB),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // 빌드: 성장 타임라인
  // -------------------------------------------------------------------------
  Widget _buildGrowthTimeline(Pet pet, Color categoryColor) {
    final stages = [
      (PetGrowthStage.egg, 'Lv.1'),
      (PetGrowthStage.baby, 'Lv.3'),
      (PetGrowthStage.juvenile, 'Lv.8'),
      (PetGrowthStage.adult, 'Lv.15'),
    ];
    final currentIndex =
        stages.indexWhere((s) => s.$1 == pet.growthStage);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(stages.length * 2 - 1, (i) {
        if (i.isOdd) {
          // 연결선
          final lineIndex = i ~/ 2;
          final completed = lineIndex < currentIndex;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 22),
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color:
                      completed ? categoryColor : const Color(0xFFE0D5CF),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          );
        }

        final stageIndex = i ~/ 2;
        final stage = stages[stageIndex];
        final isCurrent = stageIndex == currentIndex;
        final isCompleted = stageIndex < currentIndex;
        final isFuture = stageIndex > currentIndex;

        final emoji =
            _stageEmojiForCategory(pet.speciesCategory, stage.$1);
        final stageLabel = _stageLabel(stage.$1);
        final circleSize = isCurrent ? 52.0 : 44.0;

        Color circleColor;
        Color borderColor;
        double borderWidth;
        Color textColor;

        if (isCurrent) {
          circleColor = categoryColor.withValues(alpha: 0.18);
          borderColor = categoryColor;
          borderWidth = 2.5;
          textColor = categoryColor;
        } else if (isCompleted) {
          circleColor = categoryColor.withValues(alpha: 0.10);
          borderColor = categoryColor.withValues(alpha: 0.5);
          borderWidth = 1.5;
          textColor = categoryColor.withValues(alpha: 0.7);
        } else {
          circleColor = const Color(0xFFF0ECE8);
          borderColor = const Color(0xFFDED5CF);
          borderWidth = 1.5;
          textColor = const Color(0xFFBDB5B0);
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: circleColor,
                    border: Border.all(
                      color: borderColor,
                      width: borderWidth,
                    ),
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: categoryColor.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: TextStyle(
                        fontSize: isCurrent ? 22 : 18,
                      ),
                    ),
                  ),
                ),
                if (isCompleted)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: categoryColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white, width: 1.5),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check,
                          size: 9,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              stageLabel,
              style: TextStyle(
                fontSize: 11,
                color: textColor,
                fontWeight:
                    isCurrent ? FontWeight.w700 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              stage.$2,
              style: TextStyle(
                fontSize: 10,
                color: isFuture
                    ? const Color(0xFFCDC5C0)
                    : const Color(0xFF8D6E63),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      }),
    );
  }

  // -------------------------------------------------------------------------
  // 빌드: 돌봄 그리드 아이템
  // -------------------------------------------------------------------------
  Widget _buildCareItem({
    required String label,
    required String emoji,
    required CareAction action,
    required bool enabled,
    required Color categoryColor,
    DateTime? lastActionAt,
  }) {
    return InkWell(
      onTap: enabled
          ? () {
              context
                  .read<PetBloc>()
                  .add(PerformCareAction(action: action));
              context.read<ChallengeBloc>().add(
                    const UpdateTaskProgress(
                        type: ChallengeTaskType.petCare),
                  );
            }
          : null,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: enabled ? Colors.white : const Color(0xFFF7F4F1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: enabled
                ? categoryColor.withValues(alpha: 0.3)
                : const Color(0xFFE0D5CF),
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: enabled
                    ? const Color(0xFF3E2723)
                    : const Color(0xFFBDB5B0),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (!enabled && lastActionAt != null)
              Builder(builder: (_) {
                final remaining = PetConstants.careCooldownMinutes -
                    DateTime.now().difference(lastActionAt).inMinutes;
                return Text(
                  remaining > 0 ? '남은 ${remaining}분' : '곧 가능',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFFBDB5B0),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // 빌드: 활동 로그 아이템
  // -------------------------------------------------------------------------
  Widget _buildActivityItem(PetActivity activity) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F2EE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                activity.icon ?? '📝',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF3E2723),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  _timeAgo(activity.timestamp),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFB0A098),
                  ),
                ),
              ],
            ),
          ),
          if (activity.expAmount != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '+${activity.expAmount} EXP',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // 빌드: 섹션 제목
  // -------------------------------------------------------------------------
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF3E2723),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // 빌드: 레벨업 배너 (PetLevelUp 상태 시)
  // -------------------------------------------------------------------------
  Widget _buildLevelUpBanner(PetLevelUp state) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF9C4), Color(0xFFFFF3E0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFCC02).withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFCC02).withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('⬆️', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lv.${state.previousLevel} → Lv.${state.pet.level}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D4037),
                ),
              ),
              if (state.newStage != null)
                Text(
                  '${_stageLabel(state.newStage!)} 단계로 진화!',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8D6E63),
                  ),
                )
              else
                const Text(
                  '레벨 업!',
                  style: TextStyle(fontSize: 13, color: Color(0xFF8D6E63)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // 메인 body 빌드 (PetLoaded 기준)
  // -------------------------------------------------------------------------
  Widget _buildBody(PetLoaded state) {
    final pet = state.pet;
    final categoryColor = _categoryColor(pet.speciesCategory);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------------------------------------------------------
          // Section 1: 대형 아바타 + 상태
          // ---------------------------------------------------------------
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  categoryColor.withValues(alpha: 0.15),
                  const Color(0xFFFAFAF5),
                ],
              ),
            ),
            padding:
                const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              children: [
                // 아바타 + 기분 이모지 오버레이
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    PetAvatar.fromPet(pet: pet, size: 140),
                    Positioned(
                      right: -8,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.10),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          pet.moodEmoji,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // 닉네임
                Text(
                  pet.nickname,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
                const SizedBox(height: 4),

                // 종명 · 레벨
                Text(
                  '${pet.speciesName} · Lv.${pet.level}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8D6E63),
                  ),
                ),
                const SizedBox(height: 8),

                // 성장 단계 배지
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${pet.stageEmoji} ${pet.stageName}',
                    style: TextStyle(
                      fontSize: 13,
                      color: categoryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // 기분 텍스트
                Text(
                  '기분: ${pet.moodLabel}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8D6E63),
                  ),
                ),
                const SizedBox(height: 18),

                // EXP 바
                _buildExpBar(pet, categoryColor),
                const SizedBox(height: 14),

                // 3개 게이지 바
                Row(
                  children: [
                    Expanded(
                      child: _buildGauge(
                        '배고픔',
                        pet.hunger,
                        Icons.restaurant,
                        const Color(0xFFFF9800),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGauge(
                        '갈증',
                        pet.thirst,
                        Icons.water_drop,
                        const Color(0xFF2196F3),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGauge(
                        '행복',
                        pet.happiness,
                        Icons.favorite,
                        const Color(0xFFE91E63),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ---------------------------------------------------------------
          // Section 2: 성장 타임라인
          // ---------------------------------------------------------------
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('🌱 성장 타임라인'),
                _buildGrowthTimeline(pet, categoryColor),
              ],
            ),
          ),

          // 구분선
          const Divider(
            height: 1,
            thickness: 1,
            indent: 24,
            endIndent: 24,
            color: Color(0xFFF0EAE5),
          ),

          // ---------------------------------------------------------------
          // Section 3: 돌봄 그리드
          // ---------------------------------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('🤲 돌봄'),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.1,
                  children: [
                    _buildCareItem(
                      label: '먹이주기',
                      emoji: '🍽️',
                      action: CareAction.feed,
                      enabled: state.canFeed,
                      lastActionAt: pet.lastFedAt,
                      categoryColor: categoryColor,
                    ),
                    _buildCareItem(
                      label: '물주기',
                      emoji: '💧',
                      action: CareAction.water,
                      enabled: state.canWater,
                      lastActionAt: pet.lastWateredAt,
                      categoryColor: categoryColor,
                    ),
                    _buildCareItem(
                      label: '놀아주기',
                      emoji: '🎮',
                      action: CareAction.play,
                      enabled: state.canPlay,
                      lastActionAt: pet.lastPlayedAt,
                      categoryColor: categoryColor,
                    ),
                    _buildCareItem(
                      label: '산책',
                      emoji: '🚶',
                      action: CareAction.walk,
                      enabled: state.canWalk,
                      lastActionAt: pet.lastWalkedAt,
                      categoryColor: categoryColor,
                    ),
                    _buildCareItem(
                      label: '목욕',
                      emoji: '🛁',
                      action: CareAction.bath,
                      enabled: state.canBath,
                      lastActionAt: pet.lastBathedAt,
                      categoryColor: categoryColor,
                    ),
                    _buildCareItem(
                      label: '자장가',
                      emoji: '🎵',
                      action: CareAction.lullaby,
                      enabled: state.canLullaby,
                      lastActionAt: pet.lastLullabyAt,
                      categoryColor: categoryColor,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ---------------------------------------------------------------
          // Section 4: 미니게임 (쓰다듬기)
          // ---------------------------------------------------------------
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('💕 쓰다듬기'),
                Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: categoryColor.withValues(alpha: 0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 하트 파티클
                      ..._particles.map((p) => AnimatedPositioned(
                            key: p.key,
                            duration:
                                const Duration(milliseconds: 800),
                            curve: Curves.easeOut,
                            top: p.top,
                            left: p.left,
                            child: AnimatedOpacity(
                              duration:
                                  const Duration(milliseconds: 800),
                              opacity: p.opacity,
                              child: const Text(
                                '💕',
                                style: TextStyle(fontSize: 22),
                              ),
                            ),
                          )),

                      // 펫 이모지 터치 영역
                      GestureDetector(
                        onTap: state.miniGameTapsRemaining > 0
                            ? () {
                                context
                                    .read<PetBloc>()
                                    .add(const PerformMiniGameTap());
                                _spawnHeart();
                              }
                            : null,
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Text(
                              pet.stageEmoji,
                              style:
                                  const TextStyle(fontSize: 80),
                            ),
                          ],
                        ),
                      ),

                      // 하단 안내 텍스트 + 광고 버튼
                      Positioned(
                        bottom: 10,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              state.miniGameTapsRemaining > 0
                                  ? '남은 터치: ${state.miniGameTapsRemaining}/${PetConstants.miniGameMaxTapsPerSession}'
                                  : '터치를 다 사용했어요!',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF8D6E63),
                              ),
                            ),
                            if (state.miniGameTapsRemaining <= 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: GestureDetector(
                                  onTap: () => _showRewardedAd(context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFF9800).withValues(alpha: 0.3),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.play_circle_fill, color: Colors.white, size: 16),
                                        SizedBox(width: 4),
                                        Text(
                                          '광고 보고 더 놀기',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 구분선
          const Divider(
            height: 1,
            thickness: 1,
            indent: 24,
            endIndent: 24,
            color: Color(0xFFF0EAE5),
          ),

          // ---------------------------------------------------------------
          // Section 5: 활동 로그
          // ---------------------------------------------------------------
          Padding(
            padding:
                const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('📋 활동 기록'),
                if (state.activities.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 24),
                      child: Column(
                        children: [
                          Text(
                            '📭',
                            style: TextStyle(fontSize: 36),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '아직 활동 기록이 없어요',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFFB0A098),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...state.activities
                      .take(20)
                      .map(_buildActivityItem),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // build
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF3E2723),
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: Color(0xFF8D6E63),
              size: 22,
            ),
            tooltip: '미니게임 초기화',
            onPressed: () {
              context
                  .read<PetBloc>()
                  .add(const ResetMiniGameSession());
            },
          ),
        ],
      ),
      body: BlocBuilder<PetBloc, PetState>(
        builder: (context, state) {
          // PetLevelUp: 배너 + PetLoaded 콘텐츠 동시 표시
          if (state is PetLevelUp) {
            final loadedState = PetLoaded(
              pet: state.pet,
              activities: const [],
            );
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildLevelUpBanner(state),
                  _buildBody(loadedState),
                ],
              ),
            );
          }

          if (state is PetLoaded) {
            return _buildBody(state);
          }

          if (state is PetNone) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '🌿',
                    style: TextStyle(fontSize: 56),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '아직 펫이 없어요',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '도감에서 발견한 생물을\n나의 펫으로 키워보세요!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8D6E63),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => context.pop(),
                    child: const Text('도감으로 돌아가기'),
                  ),
                ],
              ),
            );
          }

          if (state is PetError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '⚠️',
                    style: TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8D6E63),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // PetInitial / 기타 로딩
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF2E7D32),
            ),
          );
        },
      ),
    );
  }
}
