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
    on<DevGuardianLogin>(_onDevGuardianLogin);
    on<AddEcoPoints>(_onAddEcoPoints);
    on<SpendEcoPoints>(_onSpendEcoPoints);
    on<UpdateGradeLevel>(_onUpdateGradeLevel);
    on<UpdateNickname>(_onUpdateNickname);
    on<UpdateProfileCustomization>(_onUpdateProfileCustomization);
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
    isGuardian: false,
    gradeLevel: 2,
    ecoPoints: 500,
  );

  /// devMode 전용 보호자 mock 프로필
  static const Profile _devGuardianProfile = Profile(
    id: 'dev-guardian-user-001',
    email: 'guardian@nature.app',
    nickname: '보호자',
    friendCode: 'GUARD1',
    petType: 'plant',
    petName: '나무',
    petLevel: 3,
    petExp: 50,
    isGuardian: true,
    gradeLevel: 2,
    ecoPoints: 0,
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

  /// devMode 전용: 보호자 mock 프로필로 즉시 로그인
  Future<void> _onDevGuardianLogin(
    DevGuardianLogin event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await Future<void>.delayed(const Duration(milliseconds: 300));
    emit(const Authenticated(profile: _devGuardianProfile));
  }

  Future<void> _onAddEcoPoints(
    AddEcoPoints event,
    Emitter<AuthState> emit,
  ) async {
    if (state is Authenticated) {
      final current = (state as Authenticated).profile;
      emit(Authenticated(
        profile: current.copyWith(
          ecoPoints: current.ecoPoints + event.points,
        ),
      ));
    }
  }

  Future<void> _onSpendEcoPoints(
    SpendEcoPoints event,
    Emitter<AuthState> emit,
  ) async {
    if (state is Authenticated) {
      final current = (state as Authenticated).profile;
      if (current.ecoPoints >= event.points) {
        emit(Authenticated(
          profile: current.copyWith(
            ecoPoints: current.ecoPoints - event.points,
          ),
        ));
      }
    }
  }

  Future<void> _onUpdateGradeLevel(
    UpdateGradeLevel event,
    Emitter<AuthState> emit,
  ) async {
    if (state is Authenticated) {
      final current = (state as Authenticated).profile;
      emit(Authenticated(
        profile: current.copyWith(
          gradeLevel: event.gradeLevel,
        ),
      ));
    }
  }

  Future<void> _onUpdateNickname(
    UpdateNickname event,
    Emitter<AuthState> emit,
  ) async {
    if (state is Authenticated) {
      final current = (state as Authenticated).profile;
      emit(Authenticated(
        profile: current.copyWith(nickname: event.nickname),
      ));
    }
  }

  Future<void> _onUpdateProfileCustomization(
    UpdateProfileCustomization event,
    Emitter<AuthState> emit,
  ) async {
    if (state is Authenticated) {
      final current = (state as Authenticated).profile;
      emit(Authenticated(
        profile: current.copyWith(
          statusMessage: event.statusMessage ?? current.statusMessage,
          avatarFrameIndex: event.avatarFrameIndex ?? current.avatarFrameIndex,
          profileBgColorIndex: event.profileBgColorIndex ?? current.profileBgColorIndex,
          titleBadge: event.titleBadge ?? current.titleBadge,
        ),
      ));
    }
  }
}
