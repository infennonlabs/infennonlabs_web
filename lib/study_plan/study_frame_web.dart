import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';
import 'package:study_plan_bridge_shared/study_plan_bridge_shared.dart';
import 'package:web/web.dart' as web;

int _nextViewId = 0;

/// The game, running in a frame on the page. It reports taps and its Back to
/// Home button through the Study Plan bridge. Create it with a key that
/// changes with [url], so a new game gets a new frame.
class StudyFrame extends StatefulWidget {
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
  State<StudyFrame> createState() => _StudyFrameState();
}

class _StudyFrameState extends State<StudyFrame> {
  late final String _viewType = 'study-frame-${_nextViewId++}';
  late final StudyPlanFrameListener _listener = StudyPlanFrameListener(
    onActivity: () => widget.onActivity(),
    onExit: () => widget.onExit(),
  );

  @override
  void initState() {
    super.initState();
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int _) {
      final web.HTMLIFrameElement frame = web.HTMLIFrameElement()
        ..src = widget.url.toString()
        ..allow = 'fullscreen; autoplay';
      frame.style
        ..setProperty('border', 'none')
        ..setProperty('width', '100%')
        ..setProperty('height', '100%');
      _listener.attach(frame);
      return frame;
    });
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => HtmlElementView(viewType: _viewType);
}
