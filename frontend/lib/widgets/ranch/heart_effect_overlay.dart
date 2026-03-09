import 'package:flutter/material.dart';

class HeartEffectOverlay extends StatefulWidget {
  const HeartEffectOverlay({
    super.key,
    required this.creaturePositions,
    required this.onComplete,
  });

  final List<Offset> creaturePositions;
  final VoidCallback onComplete;

  @override
  State<HeartEffectOverlay> createState() => _HeartEffectOverlayState();
}

class _HeartEffectOverlayState extends State<HeartEffectOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _floatAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _floatAnimation = Tween<double>(begin: 0, end: 40).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0)),
    );

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: widget.creaturePositions.map((pos) {
            return Positioned(
              left: pos.dx,
              top: pos.dy - _floatAnimation.value,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: const Text('❤️', style: TextStyle(fontSize: 20)),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
