import 'package:flutter/material.dart';

import 'brand_theme.dart';

/// The soft gradient and glow bubbles behind the home page and its screens.
class HomeBackdrop extends StatelessWidget {
  const HomeBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFFE9F8FF),
            Color(0xFFFFF6E2),
            Color(0xFFEAFDE9),
          ],
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -80,
            left: -60,
            child: _GlowBubble(color: BrandTheme.sky, size: 260),
          ),
          Positioned(
            top: 120,
            right: -50,
            child: _GlowBubble(color: BrandTheme.peach, size: 220),
          ),
          Positioned(
            bottom: -60,
            left: 80,
            child: _GlowBubble(color: BrandTheme.lime, size: 210),
          ),
        ],
      ),
    );
  }
}

class _GlowBubble extends StatelessWidget {
  const _GlowBubble({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: <Color>[
            color.withValues(alpha: 0.75),
            color.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}
