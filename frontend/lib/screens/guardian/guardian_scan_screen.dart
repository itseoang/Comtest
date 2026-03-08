import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../blocs/guardian/guardian_bloc.dart';

class GuardianScanScreen extends StatefulWidget {
  const GuardianScanScreen({super.key});

  @override
  State<GuardianScanScreen> createState() => _GuardianScanScreenState();
}

class _GuardianScanScreenState extends State<GuardianScanScreen> {
  MobileScannerController? _scannerController;
  bool _isProcessing = false;
  bool _showSuccess = false;
  String? _registeredChildName;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (_isProcessing) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    final qrData = barcode.rawValue!;
    if (!qrData.startsWith('nature-guardian://invite')) return;

    setState(() => _isProcessing = true);
    _scannerController?.stop();

    // QR 데이터에서 어린이 이름 추출하여 확인 다이얼로그 표시
    final uri = Uri.tryParse(qrData);
    final childName = uri?.queryParameters['child_name'] != null
        ? Uri.decodeComponent(uri!.queryParameters['child_name']!)
        : '알 수 없는 어린이';

    _showConfirmDialog(qrData, childName);
  }

  void _showConfirmDialog(String qrData, String childName) {
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.child_care, color: Color(0xFF2E7D32)),
            SizedBox(width: 8),
            Text('보호자 등록'),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 16, color: Color(0xFF3E2723)),
            children: [
              const TextSpan(text: "'"),
              TextSpan(
                text: childName,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
              ),
              const TextSpan(text: "' 어린이의 보호자로 등록하시겠습니까?"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
              setState(() => _isProcessing = false);
              _scannerController?.start();
            },
            child: const Text('취소', style: TextStyle(color: Color(0xFF8D6E63))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
              context.read<GuardianBloc>().add(ScanGuardianQr(qrData: qrData));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('등록하기'),
          ),
        ],
      ),
    );
  }

  void _showCodeInputDialog() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '초대 코드 입력',
          style: TextStyle(color: Color(0xFF3E2723)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '어린이의 초대 코드 8자리를 입력해주세요',
              style: TextStyle(fontSize: 14, color: Color(0xFF8D6E63)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              textCapitalization: TextCapitalization.characters,
              maxLength: 8,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
                color: Color(0xFF3E2723),
              ),
              decoration: InputDecoration(
                hintText: 'ABCD1234',
                hintStyle: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: const Color(0xFF8D6E63).withValues(alpha: 0.3),
                ),
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD7CCC8)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('취소', style: TextStyle(color: Color(0xFF8D6E63))),
          ),
          ElevatedButton(
            onPressed: () {
              final code = controller.text.toUpperCase().trim();
              if (code.length == 8) {
                Navigator.of(dialogContext).pop();
                context.read<GuardianBloc>().add(RegisterAsGuardian(inviteCode: code));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _onRegistrationSuccess(String childName) {
    setState(() {
      _showSuccess = true;
      _registeredChildName = childName;
    });

    // 3초 후 자동 복귀
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          '어린이 등록',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocListener<GuardianBloc, GuardianState>(
        listener: (context, state) {
          if (state is GuardianRegistered) {
            _onRegistrationSuccess(state.childName);
          } else if (state is GuardianError) {
            setState(() => _isProcessing = false);
            _scannerController?.start();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFFE53935),
              ),
            );
          }
        },
        child: _showSuccess ? _buildSuccessView() : _buildScannerView(),
      ),
    );
  }

  Widget _buildScannerView() {
    return Stack(
      children: [
        // 카메라 뷰
        if (_scannerController != null)
          MobileScanner(
            controller: _scannerController!,
            onDetect: _onBarcodeDetected,
          ),

        // 오버레이
        _ScanOverlay(isProcessing: _isProcessing),

        // 하단 버튼
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // 안내 텍스트
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Text(
                      '어린이 휴대폰의 QR 코드를 스캔해주세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 직접 코드 입력 버튼
                  TextButton.icon(
                    onPressed: _showCodeInputDialog,
                    icon: const Icon(Icons.keyboard, size: 20),
                    label: const Text(
                      '직접 코드 입력',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 로딩 인디케이터
        if (_isProcessing)
          const Center(
            child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
          ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 체크마크 애니메이션
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 56,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              '보호자 등록이 완료되었습니다!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2723),
              ),
            ),
            const SizedBox(height: 12),
            if (_registeredChildName != null)
              Text(
                "'$_registeredChildName' 어린이와 연결되었습니다",
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF8D6E63),
                ),
              ),
            const SizedBox(height: 32),
            const Text(
              '잠시 후 이전 화면으로 돌아갑니다...',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF8D6E63),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 스캔 영역 가이드 오버레이
class _ScanOverlay extends StatelessWidget {
  const _ScanOverlay({required this.isProcessing});

  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scanSize = constraints.maxWidth * 0.7;
        final left = (constraints.maxWidth - scanSize) / 2;
        final top = (constraints.maxHeight - scanSize) / 2 - 40;

        return Stack(
          children: [
            // 반투명 배경
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: 0.5),
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.red, // 임의 색상, srcOut으로 잘림
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Positioned(
                    left: left,
                    top: top,
                    child: Container(
                      width: scanSize,
                      height: scanSize,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 스캔 프레임 테두리
            Positioned(
              left: left,
              top: top,
              child: Container(
                width: scanSize,
                height: scanSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isProcessing
                        ? const Color(0xFF4CAF50)
                        : Colors.white.withValues(alpha: 0.8),
                    width: 3,
                  ),
                ),
              ),
            ),

            // 모서리 장식
            ..._buildCorners(left, top, scanSize),
          ],
        );
      },
    );
  }

  List<Widget> _buildCorners(double left, double top, double size) {
    const cornerLength = 30.0;
    const cornerWidth = 4.0;
    const color = Color(0xFF4CAF50);

    return [
      // 왼쪽 상단
      Positioned(
        left: left - 1,
        top: top - 1,
        child: SizedBox(
          width: cornerLength,
          height: cornerLength,
          child: CustomPaint(painter: const _CornerPainter(corner: _Corner.topLeft, color: color, strokeWidth: cornerWidth)),
        ),
      ),
      // 오른쪽 상단
      Positioned(
        left: left + size - cornerLength + 1,
        top: top - 1,
        child: SizedBox(
          width: cornerLength,
          height: cornerLength,
          child: CustomPaint(painter: const _CornerPainter(corner: _Corner.topRight, color: color, strokeWidth: cornerWidth)),
        ),
      ),
      // 왼쪽 하단
      Positioned(
        left: left - 1,
        top: top + size - cornerLength + 1,
        child: SizedBox(
          width: cornerLength,
          height: cornerLength,
          child: CustomPaint(painter: const _CornerPainter(corner: _Corner.bottomLeft, color: color, strokeWidth: cornerWidth)),
        ),
      ),
      // 오른쪽 하단
      Positioned(
        left: left + size - cornerLength + 1,
        top: top + size - cornerLength + 1,
        child: SizedBox(
          width: cornerLength,
          height: cornerLength,
          child: CustomPaint(painter: const _CornerPainter(corner: _Corner.bottomRight, color: color, strokeWidth: cornerWidth)),
        ),
      ),
    ];
  }
}

enum _Corner { topLeft, topRight, bottomLeft, bottomRight }

class _CornerPainter extends CustomPainter {
  const _CornerPainter({
    required this.corner,
    required this.color,
    required this.strokeWidth,
  });

  final _Corner corner;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    switch (corner) {
      case _Corner.topLeft:
        path.moveTo(0, size.height);
        path.lineTo(0, 0);
        path.lineTo(size.width, 0);
      case _Corner.topRight:
        path.moveTo(0, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height);
      case _Corner.bottomLeft:
        path.moveTo(0, 0);
        path.lineTo(0, size.height);
        path.lineTo(size.width, size.height);
      case _Corner.bottomRight:
        path.moveTo(0, size.height);
        path.lineTo(size.width, size.height);
        path.lineTo(size.width, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
