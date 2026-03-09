import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Theme color palette
// ---------------------------------------------------------------------------

class _ThemeColors {
  const _ThemeColors({
    required this.grassTop,
    required this.grassBottom,
    required this.path,
    required this.pond,
    required this.pondDeep,
    required this.grassPatch,
  });

  final Color grassTop;
  final Color grassBottom;
  final Color path;
  final Color pond;
  final Color pondDeep;
  final Color grassPatch;
}

const Map<String, _ThemeColors> _themeColorMap = {
  'theme_spring': _ThemeColors(
    grassTop: Color(0xFFA5D6A7),
    grassBottom: Color(0xFF66BB6A),
    path: Color(0xFFE8D5B7),
    pond: Color(0xFF80DEEA),
    pondDeep: Color(0xFF26C6DA),
    grassPatch: Color(0xFF43A047),
  ),
  'theme_summer': _ThemeColors(
    grassTop: Color(0xFF8BC34A),
    grassBottom: Color(0xFF689F38),
    path: Color(0xFFD7CCC8),
    pond: Color(0xFF4FC3F7),
    pondDeep: Color(0xFF0288D1),
    grassPatch: Color(0xFF558B2F),
  ),
  'theme_fall': _ThemeColors(
    grassTop: Color(0xFFE6B980),
    grassBottom: Color(0xFFC49A52),
    path: Color(0xFFD7B899),
    pond: Color(0xFF90A4AE),
    pondDeep: Color(0xFF546E7A),
    grassPatch: Color(0xFFBF8C3E),
  ),
  'theme_winter': _ThemeColors(
    grassTop: Color(0xFFE0E0E0),
    grassBottom: Color(0xFFBDBDBD),
    path: Color(0xFFF5F5F5),
    pond: Color(0xFFB3E5FC),
    pondDeep: Color(0xFF81D4FA),
    grassPatch: Color(0xFFCFD8DC),
  ),
  'theme_forest': _ThemeColors(
    grassTop: Color(0xFF2E7D32),
    grassBottom: Color(0xFF1B5E20),
    path: Color(0xFF8D6E63),
    pond: Color(0xFF4DB6AC),
    pondDeep: Color(0xFF00897B),
    grassPatch: Color(0xFF1B5E20),
  ),
  'theme_desert': _ThemeColors(
    grassTop: Color(0xFFE8C170),
    grassBottom: Color(0xFFD4A843),
    path: Color(0xFFF5E0B0),
    pond: Color(0xFF4FC3F7),
    pondDeep: Color(0xFF0288D1),
    grassPatch: Color(0xFFCC9933),
  ),
  'theme_ocean': _ThemeColors(
    grassTop: Color(0xFF80CBC4),
    grassBottom: Color(0xFF4DB6AC),
    path: Color(0xFFFFE0B2),
    pond: Color(0xFF29B6F6),
    pondDeep: Color(0xFF0277BD),
    grassPatch: Color(0xFF00897B),
  ),
};

// ---------------------------------------------------------------------------
// Painter
// ---------------------------------------------------------------------------

class RanchBackgroundPainter extends CustomPainter {
  final Size worldSize;
  final String themeId;

  RanchBackgroundPainter({required this.worldSize, this.themeId = 'theme_summer'});

  @override
  void paint(Canvas canvas, Size size) {
    final colors = _themeColorMap[themeId] ?? _themeColorMap['theme_summer']!;

    // 1. Grass gradient background
    final grassRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final grassPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [colors.grassTop, colors.grassBottom],
      ).createShader(grassRect);
    canvas.drawRect(grassRect, grassPaint);

    // 2. Dirt path
    final pathPaint = Paint()
      ..color = colors.path
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final dirtPath = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(
        size.width * 0.25, size.height * 0.55,
        size.width * 0.5, size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.75, size.height * 0.45,
        size.width, size.height * 0.4,
      );
    canvas.drawPath(dirtPath, pathPaint);

    // 3a. Pond (bottom-right oval)
    final pondCenter = Offset(size.width * 0.78, size.height * 0.75);
    final pondRect =
        Rect.fromCenter(center: pondCenter, width: 100, height: 65);
    final pondPaint = Paint()
      ..shader = RadialGradient(
        colors: [colors.pond, colors.pondDeep],
      ).createShader(pondRect);
    canvas.drawOval(pondRect, pondPaint);

    // Pond highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(pondCenter.dx - 15, pondCenter.dy - 10),
        width: 35,
        height: 18,
      ),
      highlightPaint,
    );

    // 3b. Second pond (upper-left area)
    final pond2Center = Offset(size.width * 0.25, size.height * 0.3);
    final pond2Rect =
        Rect.fromCenter(center: pond2Center, width: 85, height: 55);
    final pond2Paint = Paint()
      ..shader = RadialGradient(
        colors: [colors.pond, colors.pondDeep],
      ).createShader(pond2Rect);
    canvas.drawOval(pond2Rect, pond2Paint);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(pond2Center.dx - 12, pond2Center.dy - 8),
        width: 28,
        height: 14,
      ),
      highlightPaint,
    );

    // 4. Grass patches (12 total)
    final grassPatchPaint = Paint()
      ..color = colors.grassPatch.withValues(alpha: 0.3);
    for (final p in [
      Offset(size.width * 0.05, size.height * 0.1),
      Offset(size.width * 0.15, size.height * 0.2),
      Offset(size.width * 0.28, size.height * 0.65),
      Offset(size.width * 0.35, size.height * 0.8),
      Offset(size.width * 0.42, size.height * 0.15),
      Offset(size.width * 0.50, size.height * 0.7),
      Offset(size.width * 0.58, size.height * 0.35),
      Offset(size.width * 0.65, size.height * 0.3),
      Offset(size.width * 0.72, size.height * 0.55),
      Offset(size.width * 0.80, size.height * 0.88),
      Offset(size.width * 0.85, size.height * 0.15),
      Offset(size.width * 0.93, size.height * 0.5),
    ]) {
      canvas.drawCircle(p, 15, grassPatchPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is RanchBackgroundPainter) {
      return oldDelegate.worldSize != worldSize ||
          oldDelegate.themeId != themeId;
    }
    return true;
  }
}

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class RanchBackground extends StatelessWidget {
  final Size worldSize;
  final String themeId;

  const RanchBackground({
    super.key,
    required this.worldSize,
    this.themeId = 'theme_summer',
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RanchBackgroundPainter(
        worldSize: worldSize,
        themeId: themeId,
      ),
      child: SizedBox(width: worldSize.width, height: worldSize.height),
    );
  }
}
