import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  const Profile({
    required this.id,
    required this.email,
    required this.nickname,
    required this.friendCode,
    required this.petType,
    required this.petName,
    required this.petLevel,
    required this.petExp,
    this.isGuardian = false,
    this.guardianName,
    this.gradeLevel = 2,
    this.ecoPoints = 0,
    this.activePetId,
    this.statusMessage,
    this.avatarFrameIndex = 0,
    this.profileBgColorIndex = 0,
    this.titleBadge,
  });

  final String id;
  final String email;
  final String nickname;
  final String friendCode;
  final String petType;
  final String petName;
  final int petLevel;
  final int petExp;
  final bool isGuardian;
  final String? guardianName;
  /// 0=유아(만4세) ~ 6=초등6학년
  final int gradeLevel;
  /// 에코포인트 (퀴즈·발견 등으로 누적)
  final int ecoPoints;
  final String? activePetId;
  /// 한줄 소개
  final String? statusMessage;
  /// 아바타 프레임 인덱스 (0=기본, 1~6=커스텀)
  final int avatarFrameIndex;
  /// 프로필 배경색 인덱스 (0=기본, 1~8=커스텀)
  final int profileBgColorIndex;
  /// 칭호 배지 (null=없음)
  final String? titleBadge;

  Profile copyWith({
    String? id,
    String? email,
    String? nickname,
    String? friendCode,
    String? petType,
    String? petName,
    int? petLevel,
    int? petExp,
    bool? isGuardian,
    String? guardianName,
    int? gradeLevel,
    int? ecoPoints,
    String? activePetId,
    String? statusMessage,
    int? avatarFrameIndex,
    int? profileBgColorIndex,
    String? titleBadge,
  }) {
    return Profile(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      friendCode: friendCode ?? this.friendCode,
      petType: petType ?? this.petType,
      petName: petName ?? this.petName,
      petLevel: petLevel ?? this.petLevel,
      petExp: petExp ?? this.petExp,
      isGuardian: isGuardian ?? this.isGuardian,
      guardianName: guardianName ?? this.guardianName,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      ecoPoints: ecoPoints ?? this.ecoPoints,
      activePetId: activePetId ?? this.activePetId,
      statusMessage: statusMessage ?? this.statusMessage,
      avatarFrameIndex: avatarFrameIndex ?? this.avatarFrameIndex,
      profileBgColorIndex: profileBgColorIndex ?? this.profileBgColorIndex,
      titleBadge: titleBadge ?? this.titleBadge,
    );
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      email: json['email'] as String,
      nickname: json['nickname'] as String,
      friendCode: json['friend_code'] as String,
      petType: json['pet_type'] as String,
      petName: json['pet_name'] as String,
      petLevel: json['pet_level'] as int,
      petExp: json['pet_exp'] as int,
      isGuardian: json['is_guardian'] as bool? ?? false,
      guardianName: json['guardian_name'] as String?,
      gradeLevel: json['grade_level'] as int? ?? 2,
      ecoPoints: json['eco_points'] as int? ?? 0,
      activePetId: json['active_pet_id'] as String?,
      statusMessage: json['status_message'] as String?,
      avatarFrameIndex: json['avatar_frame_index'] as int? ?? 0,
      profileBgColorIndex: json['profile_bg_color_index'] as int? ?? 0,
      titleBadge: json['title_badge'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nickname': nickname,
      'friend_code': friendCode,
      'pet_type': petType,
      'pet_name': petName,
      'pet_level': petLevel,
      'pet_exp': petExp,
      'is_guardian': isGuardian,
      'guardian_name': guardianName,
      'grade_level': gradeLevel,
      'eco_points': ecoPoints,
      'active_pet_id': activePetId,
      'status_message': statusMessage,
      'avatar_frame_index': avatarFrameIndex,
      'profile_bg_color_index': profileBgColorIndex,
      'title_badge': titleBadge,
    };
  }

  @override
  List<Object?> get props => [
        id,
        email,
        nickname,
        friendCode,
        petType,
        petName,
        petLevel,
        petExp,
        isGuardian,
        guardianName,
        gradeLevel,
        ecoPoints,
        activePetId,
        statusMessage,
        avatarFrameIndex,
        profileBgColorIndex,
        titleBadge,
      ];
}
