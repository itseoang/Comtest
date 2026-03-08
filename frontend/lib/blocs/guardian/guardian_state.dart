part of 'guardian_bloc.dart';

abstract class GuardianState extends Equatable {
  const GuardianState();

  @override
  List<Object?> get props => [];
}

/// 초기 상태 (보호자 미연결)
class GuardianInitial extends GuardianState {
  const GuardianInitial();
}

/// 로딩 중
class GuardianLoading extends GuardianState {
  const GuardianLoading();
}

/// 초대 코드가 생성됨 (어린이 모드에서 사용)
class InviteCodeGenerated extends GuardianState {
  const InviteCodeGenerated({
    required this.inviteCode,
    required this.qrData,
    required this.expiresAt,
  });

  final String inviteCode;
  final String qrData;
  final DateTime expiresAt;

  @override
  List<Object?> get props => [inviteCode, qrData, expiresAt];
}

/// 보호자 등록 완료
class GuardianRegistered extends GuardianState {
  const GuardianRegistered({
    required this.childId,
    required this.childName,
    required this.guardianName,
  });

  final String childId;
  final String childName;
  final String guardianName;

  @override
  List<Object?> get props => [childId, childName, guardianName];
}

/// 이미 보호자가 연결된 상태
class GuardianConnected extends GuardianState {
  const GuardianConnected({
    required this.guardianName,
    this.connectedChildren = const [],
  });

  final String guardianName;
  final List<String> connectedChildren;

  @override
  List<Object?> get props => [guardianName, connectedChildren];
}

/// 에러 상태
class GuardianError extends GuardianState {
  const GuardianError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
