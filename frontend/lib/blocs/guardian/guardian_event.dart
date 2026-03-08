part of 'guardian_bloc.dart';

abstract class GuardianEvent extends Equatable {
  const GuardianEvent();

  @override
  List<Object?> get props => [];
}

/// 어린이 모드: 초대 코드 생성
class GenerateInviteCode extends GuardianEvent {
  const GenerateInviteCode({
    required this.childId,
    required this.childName,
  });

  final String childId;
  final String childName;

  @override
  List<Object?> get props => [childId, childName];
}

/// 보호자 모드: QR 스캔으로 등록
class ScanGuardianQr extends GuardianEvent {
  const ScanGuardianQr({required this.qrData});

  final String qrData;

  @override
  List<Object?> get props => [qrData];
}

/// 보호자 모드: 코드로 직접 등록
class RegisterAsGuardian extends GuardianEvent {
  const RegisterAsGuardian({required this.inviteCode});

  final String inviteCode;

  @override
  List<Object?> get props => [inviteCode];
}

/// 보호자 연결 해제
class RemoveGuardian extends GuardianEvent {
  const RemoveGuardian();
}

/// 보호자 연결 상태 확인
class CheckGuardianStatus extends GuardianEvent {
  const CheckGuardianStatus();
}
