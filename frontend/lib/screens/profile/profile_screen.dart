import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../config/constants.dart';
import '../../models/profile.dart';
import '../../widgets/pet/pet_avatar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('나'),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return _ProfileContent(profile: state.profile);
          }
          return const Center(child: Text('로그인이 필요합니다'));
        },
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final Profile profile;
  const _ProfileContent({required this.profile});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile header card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                    child: Text(
                      profile.nickname.isNotEmpty
                          ? profile.nickname[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Nickname
                  Text(
                    profile.nickname,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                    ),
                  ),

                  // Friend code badge
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: profile.friendCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('친구 코드가 복사되었습니다!')),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F0),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFD7CCC8)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.tag, size: 16, color: Color(0xFF8D6E63)),
                          const SizedBox(width: 4),
                          Text(
                            profile.friendCode,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3E2723),
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.copy, size: 14, color: Color(0xFF8D6E63)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const _StatCounter(count: 0, label: '컬렉션'),
                      Container(height: 30, width: 1, color: const Color(0xFFEEE8E0)),
                      const _StatCounter(count: 0, label: '에코포인트'),
                      Container(height: 30, width: 1, color: const Color(0xFFEEE8E0)),
                      const _StatCounter(count: 0, label: '친구'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Quick actions
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit_outlined, color: Color(0xFF2E7D32)),
                  title: const Text('프로필 수정'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.palette_outlined, color: Color(0xFF2E7D32)),
                  title: const Text('프로필 꾸미기'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.pets_outlined, color: Color(0xFF2E7D32)),
                  title: const Text('내 펫'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Pet mini preview
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  PetAvatar(
                    petType: profile.petType,
                    petColor: AppConstants.petTypes[profile.petType]?['color'] ?? '#4CAF50',
                    level: profile.petLevel,
                    size: 52,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.petName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3E2723),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${AppConstants.petTypes[profile.petType]?['name'] ?? ''} Lv.${profile.petLevel}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF8D6E63),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('보기'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Logout button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('로그아웃'),
                    content: const Text('정말 로그아웃하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          context.read<AuthBloc>().add(const LogoutRequested());
                          context.go('/login');
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFE53935),
                        ),
                        child: const Text('로그아웃'),
                      ),
                    ],
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE53935),
              ),
              child: const Text('로그아웃'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _StatCounter extends StatelessWidget {
  final int count;
  final String label;

  const _StatCounter({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3E2723),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF8D6E63),
          ),
        ),
      ],
    );
  }
}
