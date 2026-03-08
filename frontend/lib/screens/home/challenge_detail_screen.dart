import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/challenge/challenge_bloc.dart';
import '../../blocs/pet/pet_bloc.dart';
import '../../models/challenge.dart';

class ChallengeDetailScreen extends StatelessWidget {
  const ChallengeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChallengeBloc, ChallengeState>(
      listener: (context, state) {
        if (state is ChallengeRewardClaimed) {
          context.read<AuthBloc>().add(
                AddEcoPoints(points: state.points, source: 'challenge'),
              );
          context.read<PetBloc>().add(
                AddPetExp(exp: state.petExp, source: 'challenge'),
              );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '🎉 보상 획득! +${state.points} 에코포인트, +${state.petExp} 펫 경험치',
              ),
              backgroundColor: const Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAF5),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFAFAF5),
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Text(
            '이번 주 챌린지',
            style: TextStyle(
              color: Color(0xFF3E2723),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          iconTheme: const IconThemeData(color: Color(0xFF3E2723)),
        ),
        body: BlocBuilder<ChallengeBloc, ChallengeState>(
          builder: (context, state) {
            if (state is ChallengeLoaded || state is ChallengeRewardClaimed) {
              final challenge = state is ChallengeLoaded
                  ? state.challenge
                  : (state as ChallengeRewardClaimed).challenge;
              return _buildContent(context, challenge);
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Challenge challenge) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          _buildHeaderCard(challenge),
          const SizedBox(height: 20),
          // Section title
          const Text(
            '미션 목록',
            style: TextStyle(
              color: Color(0xFF3E2723),
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          // Mission cards
          ...challenge.tasks.map((task) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildTaskCard(task),
              )),
          const SizedBox(height: 16),
          // Reward banner
          _buildRewardBanner(context, challenge),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(Challenge challenge) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            challenge.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            challenge.description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: challenge.progress,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${challenge.completedCount} / ${challenge.totalCount} 완료',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(ChallengeTask task) {
    final isCompleted = task.isCompleted;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFFE8F5E9) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFF2E7D32).withValues(alpha: 0.3)
              : const Color(0xFFE0E0E0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Emoji
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFF2E7D32).withValues(alpha: 0.12)
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 24)
                  : Text(task.emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    color: const Color(0xFF3E2723),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  task.description,
                  style: const TextStyle(
                    color: Color(0xFF8D6E63),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                // Progress bar
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: task.targetCount > 0
                              ? (task.currentCount / task.targetCount).clamp(0.0, 1.0)
                              : 0,
                          backgroundColor: const Color(0xFFE0E0E0),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isCompleted ? const Color(0xFF2E7D32) : const Color(0xFF66BB6A),
                          ),
                          minHeight: 5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${task.currentCount}/${task.targetCount}',
                      style: TextStyle(
                        color: isCompleted ? const Color(0xFF2E7D32) : const Color(0xFF8D6E63),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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

  Widget _buildRewardBanner(BuildContext context, Challenge challenge) {
    final canClaim = challenge.isAllCompleted && !challenge.isClaimed;
    final isClaimed = challenge.isClaimed;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isClaimed
            ? const Color(0xFFE8F5E9)
            : canClaim
                ? const Color(0xFFFFF8E1)
                : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isClaimed
              ? const Color(0xFF2E7D32).withValues(alpha: 0.3)
              : canClaim
                  ? const Color(0xFFFFCA28).withValues(alpha: 0.5)
                  : const Color(0xFFE0E0E0),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                isClaimed ? '🎉' : '🎁',
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isClaimed ? '보상을 받았어요!' : '챌린지 완료 보상',
                      style: const TextStyle(
                        color: Color(0xFF3E2723),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+${challenge.rewardPoints} 에코포인트  ·  +${challenge.rewardPetExp} 펫 경험치',
                      style: const TextStyle(
                        color: Color(0xFF8D6E63),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (canClaim) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<ChallengeBloc>().add(const ClaimReward());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  '보상 받기',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
