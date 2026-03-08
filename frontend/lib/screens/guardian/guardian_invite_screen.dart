import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../blocs/guardian/guardian_bloc.dart';

class GuardianInviteScreen extends StatefulWidget {
  const GuardianInviteScreen({
    super.key,
    required this.childId,
    required this.childName,
  });

  final String childId;
  final String childName;

  @override
  State<GuardianInviteScreen> createState() => _GuardianInviteScreenState();
}

class _GuardianInviteScreenState extends State<GuardianInviteScreen> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    // 초대 코드 생성
    context.read<GuardianBloc>().add(GenerateInviteCode(
      childId: widget.childId,
      childName: widget.childName,
    ));
  }

  void _startTimer(DateTime expiresAt) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final diff = expiresAt.difference(now);
      if (diff.isNegative) {
        _timer?.cancel();
        setState(() => _remaining = Duration.zero);
      } else {
        setState(() => _remaining = diff);
      }
    });
    // 초기 값 설정
    final diff = expiresAt.difference(DateTime.now());
    _remaining = diff.isNegative ? Duration.zero : diff;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _regenerateCode() {
    context.read<GuardianBloc>().add(GenerateInviteCode(
      childId: widget.childId,
      childName: widget.childName,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '보호자 초대',
          style: TextStyle(
            color: Color(0xFF3E2723),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF3E2723)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<GuardianBloc, GuardianState>(
        listener: (context, state) {
          if (state is InviteCodeGenerated) {
            _startTimer(state.expiresAt);
          }
        },
        builder: (context, state) {
          if (state is GuardianLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2E7D32),
              ),
            );
          }

          if (state is InviteCodeGenerated) {
            return _buildQrContent(state);
          }

          if (state is GuardianError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Color(0xFFE53935)),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(fontSize: 16, color: Color(0xFF3E2723)),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _regenerateCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildQrContent(InviteCodeGenerated state) {
    final isExpired = _remaining == Duration.zero;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        children: [
          // 설명 텍스트
          const Icon(
            Icons.family_restroom,
            size: 48,
            color: Color(0xFF2E7D32),
          ),
          const SizedBox(height: 16),
          const Text(
            '보호자의 휴대폰으로\n아래 QR 코드를 스캔해주세요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              color: Color(0xFF3E2723),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),

          // QR 코드 프레임
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF2E7D32),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                // 장식 라벨
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.qr_code_2, size: 18, color: Color(0xFF2E7D32)),
                      SizedBox(width: 6),
                      Text(
                        '보호자 초대 QR',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // QR 코드
                if (!isExpired)
                  QrImageView(
                    data: state.qrData,
                    version: QrVersions.auto,
                    size: 240,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Color(0xFF2E7D32),
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.circle,
                      color: Color(0xFF3E2723),
                    ),
                  )
                else
                  Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.timer_off, size: 48, color: Color(0xFF8D6E63)),
                        SizedBox(height: 12),
                        Text(
                          '코드가 만료되었습니다',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF8D6E63),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 초대 코드 텍스트
          Text(
            state.inviteCode,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2723),
              letterSpacing: 6,
            ),
          ),
          const SizedBox(height: 8),

          // 코드 복사 버튼
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: state.inviteCode));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('초대 코드가 복사되었습니다'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('코드 복사'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 24),

          // 만료 타이머 / 재생성 버튼
          if (!isExpired)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: _remaining.inMinutes < 2
                    ? const Color(0xFFE53935).withValues(alpha: 0.1)
                    : const Color(0xFFF5F5F0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 20,
                    color: _remaining.inMinutes < 2
                        ? const Color(0xFFE53935)
                        : const Color(0xFF8D6E63),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '남은 시간 ${_formatDuration(_remaining)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _remaining.inMinutes < 2
                          ? const Color(0xFFE53935)
                          : const Color(0xFF8D6E63),
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _regenerateCode,
                icon: const Icon(Icons.refresh),
                label: const Text(
                  '코드 재생성',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 32),

          // 안내 텍스트
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: Color(0xFF8D6E63)),
                    SizedBox(width: 8),
                    Text(
                      '안내',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '1. 보호자의 휴대폰에서 자연도감 앱을 열어주세요\n'
                  '2. 보호자 모드로 로그인 후 QR 스캔을 눌러주세요\n'
                  '3. 이 화면의 QR 코드를 스캔하면 연결됩니다',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8D6E63),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
