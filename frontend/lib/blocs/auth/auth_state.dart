part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// 초기 상태 (확인 전)
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// 인증 상태 확인 중
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// 로그인 완료
class Authenticated extends AuthState {
  const Authenticated({required this.profile});

  final Profile profile;

  @override
  List<Object?> get props => [profile];
}

/// 미로그인
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// 오류
class AuthError extends AuthState {
  const AuthError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
