part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// 앱 시작 시 인증 상태 확인
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// 이메일/비밀번호 로그인
class LoginRequested extends AuthEvent {
  const LoginRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

/// 로그아웃
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// devMode 전용 테스트 로그인 (Supabase/API 호출 없음)
class DevLogin extends AuthEvent {
  const DevLogin();
}

/// devMode 전용 보호자 모드 로그인 (isGuardian: true)
class DevGuardianLogin extends AuthEvent {
  const DevGuardianLogin();
}

/// 에코포인트 추가
class AddEcoPoints extends AuthEvent {
  const AddEcoPoints({required this.points, required this.source});

  final int points;
  final String source;

  @override
  List<Object?> get props => [points, source];
}

/// 에코포인트 사용 (기프티콘 교환)
class SpendEcoPoints extends AuthEvent {
  const SpendEcoPoints({required this.points});

  final int points;

  @override
  List<Object?> get props => [points];
}

/// 보호자 학년 설정
class UpdateGradeLevel extends AuthEvent {
  const UpdateGradeLevel({required this.gradeLevel});

  final int gradeLevel;

  @override
  List<Object?> get props => [gradeLevel];
}

/// 닉네임 변경
class UpdateNickname extends AuthEvent {
  const UpdateNickname({required this.nickname});
  final String nickname;
  @override
  List<Object?> get props => [nickname];
}

/// 프로필 꾸미기 (아바타 프레임, 배경색, 한줄소개, 칭호)
class UpdateProfileCustomization extends AuthEvent {
  const UpdateProfileCustomization({
    this.statusMessage,
    this.avatarFrameIndex,
    this.profileBgColorIndex,
    this.titleBadge,
  });
  final String? statusMessage;
  final int? avatarFrameIndex;
  final int? profileBgColorIndex;
  final String? titleBadge;
  @override
  List<Object?> get props => [statusMessage, avatarFrameIndex, profileBgColorIndex, titleBadge];
}

