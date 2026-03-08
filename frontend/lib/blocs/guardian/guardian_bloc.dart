import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'guardian_event.dart';
part 'guardian_state.dart';

class GuardianBloc extends Bloc<GuardianEvent, GuardianState> {
  GuardianBloc() : super(const GuardianInitial()) {
    on<GenerateInviteCode>(_onGenerateInviteCode);
    on<ScanGuardianQr>(_onScanGuardianQr);
    on<RegisterAsGuardian>(_onRegisterAsGuardian);
    on<RemoveGuardian>(_onRemoveGuardian);
    on<CheckGuardianStatus>(_onCheckGuardianStatus);
  }

  /// 8자리 대문자+숫자 코드 생성
  static String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        8,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  Future<void> _onGenerateInviteCode(
    GenerateInviteCode event,
    Emitter<GuardianState> emit,
  ) async {
    emit(const GuardianLoading());
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final code = _generateCode();
    final expiresAt = DateTime.now().add(const Duration(minutes: 10));
    final qrData =
        'nature-guardian://invite?code=$code&child_id=${event.childId}&child_name=${Uri.encodeComponent(event.childName)}';

    emit(InviteCodeGenerated(
      inviteCode: code,
      qrData: qrData,
      expiresAt: expiresAt,
    ));
  }

  Future<void> _onScanGuardianQr(
    ScanGuardianQr event,
    Emitter<GuardianState> emit,
  ) async {
    emit(const GuardianLoading());
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // QR 데이터 파싱
    final uri = Uri.tryParse(event.qrData);
    if (uri == null || uri.scheme != 'nature-guardian' || uri.host != 'invite') {
      emit(const GuardianError(message: '유효하지 않은 QR 코드입니다'));
      return;
    }

    final code = uri.queryParameters['code'];
    final childId = uri.queryParameters['child_id'];
    final childName = uri.queryParameters['child_name'];

    if (code == null || childId == null || childName == null) {
      emit(const GuardianError(message: 'QR 코드 정보가 부족합니다'));
      return;
    }

    // mock: 무조건 성공
    emit(GuardianRegistered(
      childId: childId,
      childName: Uri.decodeComponent(childName),
      guardianName: '보호자',
    ));
  }

  Future<void> _onRegisterAsGuardian(
    RegisterAsGuardian event,
    Emitter<GuardianState> emit,
  ) async {
    emit(const GuardianLoading());
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // mock: 8자리 코드면 성공 처리
    final code = event.inviteCode.toUpperCase().trim();
    if (code.length != 8) {
      emit(const GuardianError(message: '초대 코드는 8자리입니다'));
      return;
    }

    // mock 어린이 정보 반환
    emit(const GuardianRegistered(
      childId: 'dev-test-user-001',
      childName: '테스트탐험가',
      guardianName: '보호자',
    ));
  }

  Future<void> _onRemoveGuardian(
    RemoveGuardian event,
    Emitter<GuardianState> emit,
  ) async {
    emit(const GuardianLoading());
    await Future<void>.delayed(const Duration(milliseconds: 300));
    emit(const GuardianInitial());
  }

  Future<void> _onCheckGuardianStatus(
    CheckGuardianStatus event,
    Emitter<GuardianState> emit,
  ) async {
    // mock: 초기 상태에서는 연결된 보호자 없음
    // 향후 서버에서 상태 조회
    emit(const GuardianInitial());
  }
}
