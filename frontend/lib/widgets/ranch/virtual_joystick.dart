import 'package:flutter/material.dart';

class VirtualJoystick extends StatefulWidget {
  final void Function(Offset direction) onDirectionChanged;

  const VirtualJoystick({super.key, required this.onDirectionChanged});

  @override
  State<VirtualJoystick> createState() => _VirtualJoystickState();
}

class _VirtualJoystickState extends State<VirtualJoystick> {
  static const double _outerRadius = 60.0;
  static const double _innerRadius = 20.0;
  static const double _widgetSize = 140.0;

  Offset _knobPosition = Offset.zero;

  Offset _clampToOuter(Offset delta) {
    final distance = delta.distance;
    if (distance <= _outerRadius) return delta;
    return delta / distance * _outerRadius;
  }

  void _onPanStart(DragStartDetails details) {
    const center = Offset(_widgetSize / 2, _widgetSize / 2);
    final delta = details.localPosition - center;
    final clamped = _clampToOuter(delta);
    setState(() => _knobPosition = clamped);
    widget.onDirectionChanged(Offset(
      clamped.dx / _outerRadius,
      clamped.dy / _outerRadius,
    ));
  }

  void _onPanUpdate(DragUpdateDetails details) {
    const center = Offset(_widgetSize / 2, _widgetSize / 2);
    final delta = details.localPosition - center;
    final clamped = _clampToOuter(delta);
    setState(() => _knobPosition = clamped);
    widget.onDirectionChanged(Offset(
      clamped.dx / _outerRadius,
      clamped.dy / _outerRadius,
    ));
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() => _knobPosition = Offset.zero);
    widget.onDirectionChanged(Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: SizedBox(
        width: _widgetSize,
        height: _widgetSize,
        child: CustomPaint(
          painter: _JoystickPainter(
            knobOffset: _knobPosition,
            outerRadius: _outerRadius,
            innerRadius: _innerRadius,
          ),
        ),
      ),
    );
  }
}

class _JoystickPainter extends CustomPainter {
  final Offset knobOffset;
  final double outerRadius;
  final double innerRadius;

  const _JoystickPainter({
    required this.knobOffset,
    required this.outerRadius,
    required this.innerRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Outer circle fill
    final outerFillPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    // Outer circle border
    final outerBorderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, outerRadius, outerFillPaint);
    canvas.drawCircle(center, outerRadius, outerBorderPaint);

    // Inner knob
    final knobCenter = center + knobOffset;
    final knobPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(knobCenter, innerRadius, knobPaint);
  }

  @override
  bool shouldRepaint(_JoystickPainter oldDelegate) {
    return oldDelegate.knobOffset != knobOffset;
  }
}
