import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../models/profile.dart';
import '../../services/api/dio_client.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient(),
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<DevLogin>(_onDevLogin);
  }

  final DioClient _dioClient;

  /// devMode 전용 mock 프로필
  static const Profile _devProfile = Profile(
    id: 'dev-test-user-001',
    email: 'test@nature.app',
    nickname: '테스트탐험가',
    friendCode: 'TEST01',
    petType: 'plant',
    petName: '새싹이',
    petLevel: 5,
    petExp: 120,
  );

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    // 저장된 토큰 확인 로직은 추후 구현
    emit(const Unauthenticated());
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final response = await _dioClient.dio.post(
        '/auth/login',
        data: {'email': event.email, 'password': event.password},
      );
      final profile = Profile.fromJson(
        response.data['profile'] as Map<String, dynamic>,
      );
      emit(Authenticated(profile: profile));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    // 로그아웃 처리 (토큰 삭제 등)
    emit(const Unauthenticated());
  }

  /// devMode 전용: API 없이 mock 프로필로 즉시 로그인
  Future<void> _onDevLogin(
    DevLogin event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    // 짧은 지연으로 로딩 UI 확인 가능
    await Future<void>.delayed(const Duration(milliseconds: 300));
    emit(const Authenticated(profile: _devProfile));
  }
}
