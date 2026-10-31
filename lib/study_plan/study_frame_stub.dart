import 'package:flutter/material.dart';

/// Stand-in for the embedded game when not running on the web (tests, native
/// builds). Tapping it counts as activity, and the corner button plays the
/// part of the game's own Back to Home.
class StudyFrame extends StatelessWidget {
  const StudyFrame({
    super.key,
    required this.url,
    required this.onActivity,
    required this.onExit,
  });

  final Uri url;
  final VoidCallback onActivity;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: GestureDetector(
            key: const ValueKey<String>('study-frame'),
            behavior: HitTestBehavior.opaque,
            onTap: onActivity,
            child: Container(
              color: Colors.white,
              alignment: Alignment.center,
              child: Text('Game: $url'),
            ),
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          child: TextButton(
            key: const ValueKey<String>('study-frame-exit'),
            onPressed: onExit,
            child: const Text('Back to Home'),
          ),
        ),
      ],
    );
  }
}
