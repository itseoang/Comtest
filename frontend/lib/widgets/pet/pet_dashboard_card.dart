import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/challenge/challenge_bloc.dart';
import '../../blocs/collection/collection_bloc.dart';
import '../../blocs/pet/pet_bloc.dart';
import '../../models/challenge.dart';
import '../../models/pet.dart';
import 'pet_avatar.dart';
import 'pet_select_sheet.dart';

class PetDashboardCard extends StatelessWidget {
  const PetDashboardCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PetBloc, PetState>(
      builder: (context, state) {
        if (state is PetNone || state is PetInitial) {
          return _buildEmptyCard(context);
        }
        if (state is PetLoaded) {
          return _buildPetCard(context, state);
        }
        if (state is PetLevelUp) {
          return _buildPetCard(
            context,
            PetLoaded(pet: state.pet),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF795548).withValues(alpha: 0.2),
          style: BorderStyle.solid,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '🐾',
            style: TextStyle(fontSize: 40),
          ),
          const SizedBox(height: 8),
          const Text(
            '펫을 선택해보세요!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2723),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '도감에 등록한 생물 중 하나를 골라\n가상으로 키울 수 있어요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF8D6E63),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
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
              icon: const Icon(Icons.pets, size: 18),
              label: const Text('펫 선택하기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF795548),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetCard(BuildContext context, PetLoaded state) {
    final pet = state.pet;

    return GestureDetector(
      onTap: () => context.push('/home/pet'),
      child: Container(
        padding: const EdgeInsets.all(16),
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
        children: [
          // 상단: 아바타 + 정보
          Row(
            children: [
              PetAvatar.fromPet(pet: pet, size: 64),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            pet.nickname,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3E2723),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F8E9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            pet.stageName,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF558B2F),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pet.speciesName} · Lv.${pet.level}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8D6E63),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // 경험치 바
                    _ExpBar(exp: pet.exp, maxExp: pet.maxExp),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // 3 게이지
          Row(
            children: [
              Expanded(child: _GaugeBar(label: '배고픔', value: pet.hunger, icon: Icons.restaurant, color: const Color(0xFFFF9800))),
              const SizedBox(width: 8),
              Expanded(child: _GaugeBar(label: '갈증', value: pet.thirst, icon: Icons.water_drop, color: const Color(0xFF2196F3))),
              const SizedBox(width: 8),
              Expanded(child: _GaugeBar(label: '행복', value: pet.happiness, icon: Icons.favorite, color: const Color(0xFFE91E63))),
            ],
          ),
          const SizedBox(height: 14),
          // 돌봄 버튼 3개
          Row(
            children: [
              Expanded(
                child: _CareButton(
                  label: '먹이주기',
                  icon: Icons.restaurant,
                  enabled: state.canFeed,
                  onPressed: () {
                    context.read<PetBloc>().add(const PerformCareAction(action: CareAction.feed));
                    context.read<ChallengeBloc>().add(const UpdateTaskProgress(type: ChallengeTaskType.petCare));
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CareButton(
                  label: '물주기',
                  icon: Icons.water_drop,
                  enabled: state.canWater,
                  onPressed: () {
                    context.read<PetBloc>().add(const PerformCareAction(action: CareAction.water));
                    context.read<ChallengeBloc>().add(const UpdateTaskProgress(type: ChallengeTaskType.petCare));
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CareButton(
                  label: '놀아주기',
                  icon: Icons.sports_esports,
                  enabled: state.canPlay,
                  onPressed: () {
                    context.read<PetBloc>().add(const PerformCareAction(action: CareAction.play));
                    context.read<ChallengeBloc>().add(const UpdateTaskProgress(type: ChallengeTaskType.petCare));
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}

class _ExpBar extends StatelessWidget {
  const _ExpBar({required this.exp, required this.maxExp});
  final int exp;
  final int maxExp;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: maxExp > 0 ? (exp / maxExp).clamp(0.0, 1.0) : 0,
                  backgroundColor: const Color(0xFFE0E0E0),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$exp/$maxExp',
              style: const TextStyle(fontSize: 10, color: Color(0xFF8D6E63)),
            ),
          ],
        ),
      ],
    );
  }
}

class _GaugeBar extends StatelessWidget {
  const _GaugeBar({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: (value / 100).clamp(0.0, 1.0),
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$value%',
          style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _CareButton extends StatelessWidget {
  const _CareButton({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });
  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled ? const Color(0xFF795548) : const Color(0xFFBDBDBD),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        elevation: enabled ? 2 : 0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}
