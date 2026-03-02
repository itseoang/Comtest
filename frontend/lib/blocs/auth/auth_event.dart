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
