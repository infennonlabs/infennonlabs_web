import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../brand_theme.dart';

/// Outlines [child] with a short pulse while [active], so a click on a ticker entry shows
/// where it landed. Calls [onDone] when the pulse ends.
class PulseHighlight extends StatefulWidget {
  const PulseHighlight({
    super.key,
    required this.active,
    required this.radius,
    required this.child,
    this.onDone,
  });

  final bool active;
  final double radius;
  final Widget child;
  final VoidCallback? onDone;

  @override
  State<PulseHighlight> createState() => _PulseHighlightState();
}

class _PulseHighlightState extends State<PulseHighlight>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void didUpdateWidget(PulseHighlight oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _controller.forward(from: 0).whenComplete(() {
        if (mounted) widget.onDone?.call();
      });
    }
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
      child: widget.child,
      builder: (BuildContext context, Widget? child) {
        if (!widget.active || !_controller.isAnimating) return child!;
        final t = _controller.value;
        final strength = (1 - t) * (0.55 + 0.45 * math.cos(t * math.pi * 6));
        return DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            border: Border.all(
              color: BrandTheme.ocean.withValues(alpha: strength.clamp(0, 1)),
              width: 3,
            ),
          ),
          child: child,
        );
      },
    );
  }
}
