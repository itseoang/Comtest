import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/friend/friend_bloc.dart';
import '../../models/friend.dart';
import 'friend_collection_screen.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FriendBloc()..add(const LoadFriends()),
      child: const _FriendsView(),
    );
  }
}

class _FriendsView extends StatefulWidget {
  const _FriendsView();

  @override
  State<_FriendsView> createState() => _FriendsViewState();
}

class _FriendsViewState extends State<_FriendsView> {
  void _showAddFriendDialog(BuildContext context) {
    final codeController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.person_add, color: Color(0xFF2E7D32)),
            SizedBox(width: 8),
            Text('친구 추가'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '친구의 코드를 입력해주세요',
              style: TextStyle(fontSize: 14, color: Color(0xFF8D6E63)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: codeController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: '예: TREE99',
                prefixIcon: const Icon(Icons.tag),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: const Color(0xFFF5F5F0),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              final code = codeController.text.trim();
              if (code.isEmpty) return;
              Navigator.of(dialogContext).pop();
              context.read<FriendBloc>().add(AddFriend(friendCode: code));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 친구'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            onPressed: () => _showAddFriendDialog(context),
          ),
        ],
      ),
      body: BlocConsumer<FriendBloc, FriendState>(
        listener: (context, state) {
          if (state is FriendAddSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("'${state.addedName}'님과 친구가 되었습니다!"),
                backgroundColor: const Color(0xFF2E7D32),
              ),
            );
          } else if (state is FriendAddError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red[700],
              ),
            );
          }
        },
        builder: (context, state) {
          List<Friend> friends = [];
          if (state is FriendLoaded) friends = state.friends;
          if (state is FriendAddSuccess) friends = state.friends;
          if (state is FriendAddError) friends = state.friends;

          if (friends.isEmpty && state is! FriendInitial) {
            return _buildEmptyState(context);
          }
          if (friends.isNotEmpty) {
            return _buildFriendList(context, friends);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildFriendList(BuildContext context, List<Friend> friends) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: friends.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildFriendCard(context, friends[index]),
    );
  }

  Widget _buildFriendCard(BuildContext context, Friend friend) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => FriendCollectionScreen(friend: friend),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 아바타
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                child: Text(
                  friend.nickname.isNotEmpty ? friend.nickname[0] : '?',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend.nickname,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.collections_bookmark_outlined, size: 14, color: Color(0xFF8D6E63)),
                        const SizedBox(width: 4),
                        Text(
                          '도감 ${friend.collectionCount}종',
                          style: const TextStyle(fontSize: 13, color: Color(0xFF8D6E63)),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.pets, size: 14, color: Color(0xFF8D6E63)),
                        const SizedBox(width: 4),
                        Text(
                          friend.petName,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF8D6E63)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 화살표
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('도감 보기', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2E7D32))),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_right, size: 16, color: Color(0xFF2E7D32)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 64, color: Color(0xFFBCAAA4)),
            const SizedBox(height: 16),
            const Text(
              '친구 코드를 공유해서\n친구를 추가해보세요!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Color(0xFF8D6E63), height: 1.5),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddFriendDialog(context),
              icon: const Icon(Icons.person_add),
              label: const Text('친구 추가하기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
