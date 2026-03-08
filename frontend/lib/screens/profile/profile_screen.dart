import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/guardian/guardian_bloc.dart';
import '../../blocs/quiz/quiz_bloc.dart';
import '../../config/constants.dart';
import '../../models/profile.dart';
import '../../widgets/pet/pet_avatar.dart';
import '../guardian/guardian_invite_screen.dart';
import '../guardian/guardian_scan_screen.dart';

// ---------------------------------------------------------------------------
// 헬퍼: 아바타 프레임 색상
// ---------------------------------------------------------------------------
List<Color> _getFrameColors(int index) {
  const options = <List<Color>>[
    [Color(0xFF2E7D32)],
    [Color(0xFF42A5F5), Color(0xFF1565C0)],
    [Color(0xFFFF7043), Color(0xFFE91E63)],
    [Color(0xFF7E57C2), Color(0xFF4527A0)],
    [Color(0xFFFFD54F), Color(0xFFFF8F00)],
    [Color(0xFF66BB6A), Color(0xFF2E7D32)],
    [Color(0xFFE91E63), Color(0xFFFF9800), Color(0xFF4CAF50), Color(0xFF2196F3)],
  ];
  if (index < 0 || index >= options.length) return [options[0][0], options[0][0]];
  final colors = options[index];
  return colors.length == 1 ? [colors[0], colors[0]] : colors;
}

// 헬퍼: 프로필 배경색
Color _getBgColor(int index) {
  const options = <Color>[
    Color(0xFFFAFAF5),
    Color(0xFFE0F2F1),
    Color(0xFFEDE7F6),
    Color(0xFFFCE4EC),
    Color(0xFFFFFDE7),
    Color(0xFFE3F2FD),
    Color(0xFFE8F5E9),
    Color(0xFFFFF3E0),
    Color(0xFFF3E5F5),
  ];
  if (index < 0 || index >= options.length) return options[0];
  return options[index];
}

// ---------------------------------------------------------------------------
// ProfileScreen
// ---------------------------------------------------------------------------
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

// ---------------------------------------------------------------------------
// _ProfileContent
// ---------------------------------------------------------------------------
class _ProfileContent extends StatefulWidget {
  final Profile profile;
  const _ProfileContent({required this.profile});

  @override
  State<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<_ProfileContent> {
  String? _profileImagePath;

  // -------------------------------------------------------------------------
  // 이미지 피커
  // -------------------------------------------------------------------------
  void _showImagePicker() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: Color(0xFF2E7D32)),
                title: const Text('카메라로 촬영'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: Color(0xFF2E7D32)),
                title: const Text('갤러리에서 선택'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_profileImagePath != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Color(0xFFE53935)),
                  title: const Text('사진 삭제', style: TextStyle(color: Color(0xFFE53935))),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _profileImagePath = null);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _profileImagePath = picked.path);
    }
  }

  // -------------------------------------------------------------------------
  // 프로필 수정 Bottom Sheet
  // -------------------------------------------------------------------------
  void _showEditProfileSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<AuthBloc>(),
        child: _EditProfileSheet(
          currentNickname: widget.profile.nickname,
          currentImagePath: _profileImagePath,
          onImageTap: _showImagePicker,
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // 프로필 꾸미기 Bottom Sheet
  // -------------------------------------------------------------------------
  void _showCustomizeSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<AuthBloc>(),
        child: _CustomizeProfileSheet(
          currentStatusMessage: widget.profile.statusMessage,
          currentFrameIndex: widget.profile.avatarFrameIndex,
          currentBgColorIndex: widget.profile.profileBgColorIndex,
          currentTitleBadge: widget.profile.titleBadge,
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final bgColor = _getBgColor(widget.profile.profileBgColorIndex);
    final frameColors = _getFrameColors(widget.profile.avatarFrameIndex);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ----------------------------------------------------------------
          // 프로필 헤더 카드
          // ----------------------------------------------------------------
          Card(
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // 아바타 (프레임 포함)
                  GestureDetector(
                    onTap: _showImagePicker,
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: frameColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 41,
                            backgroundColor: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                            backgroundImage: _profileImagePath != null
                                ? FileImage(File(_profileImagePath!))
                                : null,
                            child: _profileImagePath == null
                                ? Text(
                                    widget.profile.nickname.isNotEmpty
                                        ? widget.profile.nickname[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 칭호 배지
                  if (widget.profile.titleBadge != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        widget.profile.titleBadge!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],

                  // 닉네임
                  Text(
                    widget.profile.nickname,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                    ),
                  ),

                  // 한줄 소개
                  if (widget.profile.statusMessage != null &&
                      widget.profile.statusMessage!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      widget.profile.statusMessage!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8D6E63),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],

                  // 친구 코드 배지
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: widget.profile.friendCode));
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
                            widget.profile.friendCode,
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

                  // 통계 행
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const _StatCounter(count: 0, label: '컬렉션'),
                      Container(height: 30, width: 1, color: const Color(0xFFEEE8E0)),
                      GestureDetector(
                        onTap: () => context.push('/profile/gifticon-exchange'),
                        child: _StatCounter(count: widget.profile.ecoPoints, label: '에코포인트'),
                      ),
                      Container(height: 30, width: 1, color: const Color(0xFFEEE8E0)),
                      _StatCounter(
                        count: context.read<QuizBloc>().history.results.length,
                        label: '퀴즈',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ----------------------------------------------------------------
          // 빠른 메뉴
          // ----------------------------------------------------------------
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit_outlined, color: Color(0xFF2E7D32)),
                  title: const Text('프로필 수정'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showEditProfileSheet,
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.palette_outlined, color: Color(0xFF2E7D32)),
                  title: const Text('프로필 꾸미기'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showCustomizeSheet,
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.pets_outlined, color: Color(0xFF2E7D32)),
                  title: const Text('내 펫'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/home/pet'),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.card_giftcard_outlined, color: Color(0xFF2E7D32)),
                  title: const Text('기프티콘 교환'),
                  subtitle: Text(
                    '보유 ${widget.profile.ecoPoints}P',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF8D6E63)),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/profile/gifticon-exchange'),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.family_restroom_outlined, color: Color(0xFF2E7D32)),
                  title: const Text('보호자'),
                  subtitle: const Text(
                    '보호자 연결 및 관리',
                    style: TextStyle(fontSize: 12, color: Color(0xFF8D6E63)),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (_) => BlocProvider(
                        create: (_) => GuardianBloc(),
                        child: _GuardianSheet(profile: widget.profile),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ----------------------------------------------------------------
          // 펫 미리보기 카드
          // ----------------------------------------------------------------
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  PetAvatar(
                    petType: widget.profile.petType,
                    petColor: AppConstants.petTypes[widget.profile.petType]?['color'] ?? '#4CAF50',
                    level: widget.profile.petLevel,
                    size: 52,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.profile.petName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3E2723),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${AppConstants.petTypes[widget.profile.petType]?['name'] ?? ''} Lv.${widget.profile.petLevel}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF8D6E63),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (_) => _PetDetailSheet(profile: widget.profile),
                      );
                    },
                    child: const Text('보기'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ----------------------------------------------------------------
          // 로그아웃 버튼
          // ----------------------------------------------------------------
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                showDialog<void>(
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

// ===========================================================================
// _EditProfileSheet — 프로필 수정 Bottom Sheet
// ===========================================================================
class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({
    required this.currentNickname,
    required this.currentImagePath,
    required this.onImageTap,
  });

  final String currentNickname;
  final String? currentImagePath;
  final VoidCallback onImageTap;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nicknameController;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.currentNickname);
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 핸들바
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 제목
          const Center(
            child: Text(
              '프로필 수정',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2723),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 프로필 사진
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                widget.onImageTap();
              },
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                    backgroundImage: widget.currentImagePath != null
                        ? FileImage(File(widget.currentImagePath!))
                        : null,
                    child: widget.currentImagePath == null
                        ? Text(
                            widget.currentNickname.isNotEmpty
                                ? widget.currentNickname[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 닉네임 입력
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _nicknameController,
            builder: (context, value, _) {
              return TextField(
                controller: _nicknameController,
                maxLength: 10,
                decoration: InputDecoration(
                  labelText: '닉네임',
                  hintText: '닉네임을 입력해주세요',
                  labelStyle: const TextStyle(color: Color(0xFF8D6E63)),
                  counterText: '${value.text.length}/10',
                  counterStyle: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8D6E63),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD7CCC8)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // 저장 버튼
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                final nickname = _nicknameController.text.trim();
                if (nickname.isNotEmpty) {
                  context.read<AuthBloc>().add(UpdateNickname(nickname: nickname));
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('프로필이 수정되었습니다')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '저장',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// _CustomizeProfileSheet — 프로필 꾸미기 Bottom Sheet
// ===========================================================================

// 프레임 옵션 데이터
const _kFrameOptions = <(String, List<Color>)>[
  ('기본', [Color(0xFF2E7D32)]),
  ('하늘', [Color(0xFF42A5F5), Color(0xFF1565C0)]),
  ('노을', [Color(0xFFFF7043), Color(0xFFE91E63)]),
  ('보라', [Color(0xFF7E57C2), Color(0xFF4527A0)]),
  ('금빛', [Color(0xFFFFD54F), Color(0xFFFF8F00)]),
  ('숲', [Color(0xFF66BB6A), Color(0xFF2E7D32)]),
  ('무지개', [Color(0xFFE91E63), Color(0xFFFF9800), Color(0xFF4CAF50), Color(0xFF2196F3)]),
];

// 배경색 옵션 데이터
const _kBgColorOptions = <(String, Color)>[
  ('기본', Color(0xFFFAFAF5)),
  ('민트', Color(0xFFE0F2F1)),
  ('라벤더', Color(0xFFEDE7F6)),
  ('피치', Color(0xFFFCE4EC)),
  ('레몬', Color(0xFFFFFDE7)),
  ('스카이', Color(0xFFE3F2FD)),
  ('세이지', Color(0xFFE8F5E9)),
  ('코랄', Color(0xFFFFF3E0)),
  ('로즈', Color(0xFFF3E5F5)),
];

// 칭호 옵션 데이터 (null = 없음)
const _kTitleOptions = <String?>[
  null,
  '🌱 새싹 탐험가',
  '🔍 호기심 천국',
  '📸 자연 포토그래퍼',
  '📝 일기 마스터',
  '🏆 도감 챔피언',
  '🌿 자연의 친구',
  '🦋 생태 관찰자',
];

class _CustomizeProfileSheet extends StatefulWidget {
  const _CustomizeProfileSheet({
    required this.currentStatusMessage,
    required this.currentFrameIndex,
    required this.currentBgColorIndex,
    required this.currentTitleBadge,
  });

  final String? currentStatusMessage;
  final int currentFrameIndex;
  final int currentBgColorIndex;
  final String? currentTitleBadge;

  @override
  State<_CustomizeProfileSheet> createState() => _CustomizeProfileSheetState();
}

class _CustomizeProfileSheetState extends State<_CustomizeProfileSheet> {
  late final TextEditingController _statusController;
  late int _selectedFrameIndex;
  late int _selectedBgColorIndex;
  late String? _selectedTitle;

  @override
  void initState() {
    super.initState();
    _statusController = TextEditingController(text: widget.currentStatusMessage ?? '');
    _selectedFrameIndex = widget.currentFrameIndex;
    _selectedBgColorIndex = widget.currentBgColorIndex;
    _selectedTitle = widget.currentTitleBadge;
  }

  @override
  void dispose() {
    _statusController.dispose();
    super.dispose();
  }

  List<Color> _frameGradient(int index) {
    final colors = _kFrameOptions[index].$2;
    return colors.length == 1 ? [colors[0], colors[0]] : colors;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Column(
          children: [
            // ----------------------------------------------------------------
            // 고정 헤더 (핸들바 + 제목)
            // ----------------------------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Column(
                children: [
                  // 핸들바
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '프로필 꾸미기',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // ----------------------------------------------------------------
            // 스크롤 영역
            // ----------------------------------------------------------------
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --------------------------------------------------------
                    // 섹션 1: 한줄 소개
                    // --------------------------------------------------------
                    const Text(
                      '한줄 소개',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _statusController,
                      builder: (context, value, _) {
                        return TextField(
                          controller: _statusController,
                          maxLength: 30,
                          decoration: InputDecoration(
                            hintText: '나를 소개해보세요!',
                            hintStyle: const TextStyle(color: Color(0xFFBCAAA4)),
                            counterText: '${value.text.length}/30',
                            counterStyle: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8D6E63),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFD7CCC8)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Color(0xFF2E7D32), width: 2),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // --------------------------------------------------------
                    // 섹션 2: 아바타 프레임
                    // --------------------------------------------------------
                    const Text(
                      '아바타 프레임',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(_kFrameOptions.length, (index) {
                          final option = _kFrameOptions[index];
                          final isSelected = _selectedFrameIndex == index;
                          final gradColors = _frameGradient(index);

                          return GestureDetector(
                            onTap: () => setState(() => _selectedFrameIndex = index),
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              child: Column(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: gradColors,
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      border: isSelected
                                          ? Border.all(
                                              color: const Color(0xFF2E7D32),
                                              width: 3,
                                            )
                                          : null,
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFF2E7D32)
                                                    .withValues(alpha: 0.4),
                                                blurRadius: 8,
                                                spreadRadius: 1,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 26,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black26,
                                                blurRadius: 4,
                                              ),
                                            ],
                                          )
                                        : Center(
                                            child: Container(
                                              width: 48,
                                              height: 48,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFFAFAF5),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.person,
                                                color: Color(0xFF8D6E63),
                                                size: 24,
                                              ),
                                            ),
                                          ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    option.$1,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isSelected
                                          ? const Color(0xFF2E7D32)
                                          : const Color(0xFF8D6E63),
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --------------------------------------------------------
                    // 섹션 3: 배경 색상
                    // --------------------------------------------------------
                    const Text(
                      '배경 색상',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.1,
                      children: List.generate(_kBgColorOptions.length, (index) {
                        final option = _kBgColorOptions[index];
                        final isSelected = _selectedBgColorIndex == index;

                        return GestureDetector(
                          onTap: () => setState(() => _selectedBgColorIndex = index),
                          child: Column(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: option.$2,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF2E7D32)
                                        : const Color(0xFFD7CCC8),
                                    width: isSelected ? 3 : 1.5,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF2E7D32)
                                                .withValues(alpha: 0.3),
                                            blurRadius: 6,
                                            spreadRadius: 1,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        color: Color(0xFF2E7D32),
                                        size: 22,
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                option.$1,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isSelected
                                      ? const Color(0xFF2E7D32)
                                      : const Color(0xFF8D6E63),
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),

                    // --------------------------------------------------------
                    // 섹션 4: 칭호
                    // --------------------------------------------------------
                    const Text(
                      '칭호',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _kTitleOptions.map((title) {
                        final isSelected = _selectedTitle == title;
                        final label = title ?? '없음';

                        return GestureDetector(
                          onTap: () => setState(() => _selectedTitle = title),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFF5F5F0),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF2E7D32)
                                    : const Color(0xFFD7CCC8),
                              ),
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 13,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF3E2723),
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),

                    // --------------------------------------------------------
                    // 저장 버튼
                    // --------------------------------------------------------
                    SafeArea(
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            final statusText = _statusController.text.trim();
                            context.read<AuthBloc>().add(
                                  UpdateProfileCustomization(
                                    statusMessage:
                                        statusText.isNotEmpty ? statusText : null,
                                    avatarFrameIndex: _selectedFrameIndex,
                                    profileBgColorIndex: _selectedBgColorIndex,
                                    titleBadge: _selectedTitle,
                                  ),
                                );
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('프로필 꾸미기가 저장되었습니다'),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            '저장',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ===========================================================================
// _GuardianSheet
// ===========================================================================
class _GuardianSheet extends StatelessWidget {
  const _GuardianSheet({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final isGuardian = profile.isGuardian;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 32 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들바
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Icon(Icons.family_restroom, size: 48, color: Color(0xFF2E7D32)),
          const SizedBox(height: 12),
          Text(
            isGuardian ? '어린이 관리' : '보호자 연결',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3E2723)),
          ),
          const SizedBox(height: 8),
          Text(
            isGuardian
                ? '어린이의 QR 코드를 스캔하거나\n초대 코드를 입력해 연결하세요'
                : '보호자를 연결하면 활동 내역을 공유하고\n안전하게 앱을 사용할 수 있어요',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xFF8D6E63), height: 1.5),
          ),
          const SizedBox(height: 24),

          // BLoC 상태에 따른 연결된 정보 표시
          BlocBuilder<GuardianBloc, GuardianState>(
            builder: (context, state) {
              if (state is GuardianConnected) {
                return _buildConnectedInfo(context, state, isGuardian);
              }
              return const SizedBox.shrink();
            },
          ),

          if (isGuardian) ...[
            // 보호자 모드 — QR 코드 스캔 버튼
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _openScanScreen(context);
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('QR 코드 스캔', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // 초대 코드 입력 버튼
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showCodeInputDialog(context);
                },
                icon: const Icon(Icons.keyboard),
                label: const Text('초대 코드 입력', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2E7D32),
                  side: const BorderSide(color: Color(0xFF2E7D32)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ] else ...[
            // 어린이 모드 — 보호자 초대하기 버튼 (QR 생성)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _openInviteScreen(context, profile);
                },
                icon: const Icon(Icons.qr_code),
                label: const Text('보호자 초대하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConnectedInfo(BuildContext context, GuardianConnected state, bool isGuardian) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, size: 20, color: Color(0xFF4CAF50)),
              const SizedBox(width: 8),
              Text(
                isGuardian ? '연결된 어린이' : '연결된 보호자',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isGuardian && state.connectedChildren.isNotEmpty)
            ...state.connectedChildren.map(
              (child) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.child_care, size: 18, color: Color(0xFF8D6E63)),
                    const SizedBox(width: 8),
                    Text(child, style: const TextStyle(fontSize: 15, color: Color(0xFF3E2723))),
                  ],
                ),
              ),
            )
          else if (!isGuardian)
            Row(
              children: [
                const Icon(Icons.person, size: 18, color: Color(0xFF8D6E63)),
                const SizedBox(width: 8),
                Text(
                  state.guardianName,
                  style: const TextStyle(fontSize: 15, color: Color(0xFF3E2723)),
                ),
              ],
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                context.read<GuardianBloc>().add(const RemoveGuardian());
              },
              style: TextButton.styleFrom(foregroundColor: const Color(0xFFE53935)),
              child: const Text('연결 해제'),
            ),
          ),
        ],
      ),
    );
  }

  void _openInviteScreen(BuildContext context, Profile profile) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => BlocProvider(
          create: (_) => GuardianBloc(),
          child: GuardianInviteScreen(
            childId: profile.id,
            childName: profile.nickname,
          ),
        ),
      ),
    );
  }

  void _openScanScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => BlocProvider(
          create: (_) => GuardianBloc(),
          child: const GuardianScanScreen(),
        ),
      ),
    );
  }

  void _showCodeInputDialog(BuildContext context) {
    final codeController = TextEditingController();
    final guardianBloc = GuardianBloc();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: guardianBloc,
        child: BlocListener<GuardianBloc, GuardianState>(
          listener: (ctx, state) {
            if (state is GuardianRegistered) {
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("'${state.childName}' 어린이와 연결되었습니다!"),
                  backgroundColor: const Color(0xFF4CAF50),
                ),
              );
              guardianBloc.close();
            } else if (state is GuardianError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: const Color(0xFFE53935),
                ),
              );
            }
          },
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text(
              '초대 코드 입력',
              style: TextStyle(color: Color(0xFF3E2723)),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '어린이의 초대 코드 8자리를 입력해주세요',
                  style: TextStyle(fontSize: 14, color: Color(0xFF8D6E63)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: codeController,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 8,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    color: Color(0xFF3E2723),
                  ),
                  decoration: InputDecoration(
                    hintText: 'ABCD1234',
                    hintStyle: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      color: const Color(0xFF8D6E63).withValues(alpha: 0.3),
                    ),
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFD7CCC8)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  guardianBloc.close();
                },
                child: const Text('취소', style: TextStyle(color: Color(0xFF8D6E63))),
              ),
              ElevatedButton(
                onPressed: () {
                  final code = codeController.text.toUpperCase().trim();
                  if (code.length == 8) {
                    guardianBloc.add(RegisterAsGuardian(inviteCode: code));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('확인'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// _PetDetailSheet
// ===========================================================================
class _PetDetailSheet extends StatelessWidget {
  const _PetDetailSheet({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final petInfo = AppConstants.petTypes[profile.petType];
    final petName = petInfo?['name'] ?? '새싹이';
    final petColor = petInfo?['color'] ?? '#4CAF50';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            PetAvatar(
              petType: profile.petType,
              petColor: petColor,
              level: profile.petLevel,
              size: 100,
            ),
            const SizedBox(height: 16),
            Text(
              profile.petName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2723),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$petName Lv.${profile.petLevel}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8D6E63),
              ),
            ),
            const SizedBox(height: 20),
            // 경험치 바
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5E8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '경험치',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3E2723),
                        ),
                      ),
                      Text(
                        '${profile.petExp} / ${profile.petLevel * 100}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8D6E63),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (profile.petExp / (profile.petLevel * 100)).clamp(0.0, 1.0),
                      backgroundColor: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // 펫 상태 정보
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5E8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _PetStatItem(icon: Icons.favorite, label: '건강', value: '좋음', color: Color(0xFFE91E63)),
                  _PetStatItem(icon: Icons.emoji_emotions, label: '기분', value: '행복', color: Color(0xFFFF9800)),
                  _PetStatItem(icon: Icons.restaurant, label: '배고픔', value: '보통', color: Color(0xFF4CAF50)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '자연을 더 많이 관찰하면 ${profile.petName}이(가) 성장해요!',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF8D6E63),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// _PetStatItem
// ===========================================================================
class _PetStatItem extends StatelessWidget {
  const _PetStatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3E2723),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF8D6E63)),
        ),
      ],
    );
  }
}

// ===========================================================================
// _StatCounter
// ===========================================================================
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
