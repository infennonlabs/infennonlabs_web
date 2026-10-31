import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:study_plan_shared/study_plan_shared.dart';

import '../brand_theme.dart';
import 'study_catalog.dart';
import 'study_frame.dart';

/// Plays a Study Plan: the games run in a frame while one shared clock counts
/// down, only while the child is playing. Nothing is saved.
class StudyRunnerPage extends StatefulWidget {
  const StudyRunnerPage({
    super.key,
    required this.items,
    required this.totalMinutes,
    required this.games,
    required this.onFinished,
    this.idleAfterSeconds = 20,
  });

  final List<StudyPlanItem> items;
  final int totalMinutes;
  final List<StudyGameInfo> games;

  /// Called when the plan is over (time up or ended) and the child goes home.
  final VoidCallback onFinished;

  final int idleAfterSeconds;

  @override
  State<StudyRunnerPage> createState() => _StudyRunnerPageState();
}

class _StudyRunnerPageState extends State<StudyRunnerPage>
    with WidgetsBindingObserver {
  late final StudySession _session = StudySession(
    totalMinutes: widget.totalMinutes,
    itemCount: widget.items.length,
    idleAfterSeconds: widget.idleAfterSeconds,
  );
  Timer? _timer;

  /// True after the game's own Back to Home: the child picks what is next.
  bool _menu = false;

  /// Changes to start a fresh frame for the same item.
  int _frameGeneration = 0;

  /// Plan items the child has marked done.
  final Set<int> _done = <int>{};

  bool get _allDone => _done.length == widget.items.length;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _session.tick());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _session.setHidden(
      state == AppLifecycleState.paused || state == AppLifecycleState.hidden,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _session.dispose();
    super.dispose();
  }

  StudyGameInfo _game(StudyPlanItem item) =>
      widget.games.firstWhere((StudyGameInfo g) => g.id == item.gameId);

  String _label(StudyPlanItem item) {
    final StudyGameInfo game = _game(item);
    final StudyModeInfo? mode = item.modeId == null
        ? null
        : game.modeById(item.modeId!);
    return mode == null ? game.title : '${game.title}: ${mode.title}';
  }

  void _select(int index) {
    // A tap on the menu or tabs keeps the child from looking idle, but only
    // the game itself starts the clock.
    _session.onActivity(startsClock: false);
    setState(() {
      if (index != _session.activeItem || _menu) _frameGeneration++;
      _menu = false;
    });
    _session.selectItem(index);
  }

  /// The child says they are finished with the current item: tick it off and
  /// move to the next one that is not done. When every item is done the plan
  /// ends early.
  void _markDone() {
    _session.onActivity(startsClock: false);
    final int current = _session.activeItem;
    setState(() => _done.add(current));
    if (_allDone) {
      _session.end();
      return;
    }
    for (var step = 1; step < widget.items.length; step++) {
      final int next = (current + step) % widget.items.length;
      if (!_done.contains(next)) {
        _select(next);
        return;
      }
    }
  }

  void _goHome() {
    widget.onFinished();
    Navigator.of(context).popUntil((Route<dynamic> r) => r.isFirst);
  }

  static String _clock(int seconds) =>
      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F8FF),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _session,
          builder: (BuildContext context, Widget? _) {
            final StudyPhase phase = _session.phase;
            return Column(
              children: <Widget>[
                _TopBar(
                  clock: _clock(_session.remainingSeconds),
                  fraction: _session.remainingSeconds / _session.totalSeconds,
                  phase: phase,
                  onEnd: _session.end,
                ),
                _Tabs(
                  labels: <String>[
                    for (final StudyPlanItem item in widget.items) _label(item),
                  ],
                  selected: _menu ? -1 : _session.activeItem,
                  done: _done,
                  onSelect: _select,
                  onDone: phase == StudyPhase.finished || _menu
                      ? null
                      : (_done.contains(_session.activeItem)
                            ? null
                            : _markDone),
                  activeIsDone: _done.contains(_session.activeItem),
                ),
                if (phase == StudyPhase.ready && !_menu) const _ReadyHint(),
                Expanded(
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(child: _body()),
                      if (phase == StudyPhase.idle)
                        Positioned.fill(
                          child: _Scrim(
                            child: _Card(
                              emoji: '👋',
                              title: 'Still playing?',
                              message:
                                  'The timer is paused. Tap to keep going.',
                              button: "I'm here!",
                              buttonKey: 'study-resume',
                              onPressed: _session.resume,
                            ),
                          ),
                        ),
                      if (phase == StudyPhase.finished)
                        Positioned.fill(
                          child: _Scrim(
                            child: _Card(
                              emoji: '🎉',
                              title: _session.usedAllTime || _allDone
                                  ? 'Great work!'
                                  : 'Study Plan ended',
                              message: _summary(),
                              button: 'Back to home',
                              buttonKey: 'study-done',
                              onPressed: _goHome,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _summary() {
    final int counted = <int>[
      for (var i = 0; i < widget.items.length; i++) _session.secondsOn(i),
    ].fold(0, (int a, int b) => a + b);
    final StringBuffer text = StringBuffer();
    if (_allDone) {
      text.write('You finished everything in your plan.');
    } else if (_session.usedAllTime) {
      text.write('You used all ${widget.totalMinutes} minutes of practice.');
    } else if (counted == 0) {
      text.write('The timer never started, so no practice time was counted.');
    } else {
      text.write('Here is what your child practiced.');
    }
    for (var i = 0; i < widget.items.length; i++) {
      final int seconds = _session.secondsOn(i);
      if (seconds == 0 && !_done.contains(i)) continue;
      text.write(
        '\n${_done.contains(i) ? '✓ ' : ''}${_label(widget.items[i])}: ${_clock(seconds)}',
      );
    }
    return text.toString();
  }

  Widget _body() {
    // Once the plan is over there is no game left to play, so the summary sits
    // on a plain background rather than over a running game.
    if (_session.phase == StudyPhase.finished) return const SizedBox.shrink();
    if (_menu) {
      return _Menu(
        labels: <String>[
          for (final StudyPlanItem item in widget.items) _label(item),
        ],
        seconds: <int>[
          for (var i = 0; i < widget.items.length; i++) _session.secondsOn(i),
        ],
        done: _done,
        clock: _clock,
        onSelect: _select,
      );
    }
    final StudyPlanItem item = widget.items[_session.activeItem];
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: ColoredBox(
          color: Colors.white,
          child: StudyFrame(
            key: ValueKey<String>(
              'frame-${_session.activeItem}-$_frameGeneration',
            ),
            url: _game(item).urlFor(item.modeId),
            onActivity: _session.onActivity,
            onExit: () => setState(() => _menu = true),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.clock,
    required this.fraction,
    required this.phase,
    required this.onEnd,
  });

  final String clock;
  final double fraction;
  final StudyPhase phase;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    final bool counting = phase == StudyPhase.running;
    final String state = switch (phase) {
      StudyPhase.ready => 'starts on first tap',
      StudyPhase.running => 'counting',
      StudyPhase.idle || StudyPhase.hidden => 'paused',
      StudyPhase.finished => 'done',
    };
    return Container(
      width: double.infinity,
      color: BrandTheme.ink,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Wrap(
        spacing: 14,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: counting
                      ? const Color(0xFF8FD060)
                      : const Color(0xFFFFB36A),
                ),
              ),
              const SizedBox(width: 8),
              Semantics(
                label: 'Time left $clock, $state',
                excludeSemantics: true,
                child: Text(
                  clock,
                  key: const ValueKey<String>('study-clock'),
                  style: GoogleFonts.fredoka(color: Colors.white, fontSize: 26),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                state,
                key: const ValueKey<String>('study-state'),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          SizedBox(
            width: 160,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: fraction.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: Colors.white24,
                color: const Color(0xFF4CB4E7),
              ),
            ),
          ),
          OutlinedButton(
            key: const ValueKey<String>('study-end'),
            onPressed: phase == StudyPhase.finished ? null : onEnd,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white54),
            ),
            child: const Text('End Study Plan'),
          ),
        ],
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({
    required this.labels,
    required this.selected,
    required this.done,
    required this.onSelect,
    required this.onDone,
    required this.activeIsDone,
  });

  final List<String> labels;
  final int selected;
  final Set<int> done;
  final ValueChanged<int> onSelect;

  /// Null when marking done is not possible right now.
  final VoidCallback? onDone;
  final bool activeIsDone;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: Row(
        children: <Widget>[
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
              itemCount: labels.length,
              separatorBuilder: (BuildContext _, int _) =>
                  const SizedBox(width: 8),
              itemBuilder: (BuildContext context, int i) => ChoiceChip(
                key: ValueKey<String>('study-tab-$i'),
                avatar: done.contains(i)
                    ? Icon(
                        Icons.check_circle,
                        size: 18,
                        color: selected == i
                            ? Colors.white
                            : const Color(0xFF2E9656),
                      )
                    : null,
                label: Text(labels[i]),
                selected: selected == i,
                showCheckmark: false,
                selectedColor: BrandTheme.ocean,
                labelStyle: TextStyle(
                  color: selected == i ? Colors.white : BrandTheme.ink,
                  fontWeight: FontWeight.w800,
                ),
                onSelected: (_) => onSelect(i),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              key: const ValueKey<String>('study-item-done'),
              onPressed: onDone,
              icon: Icon(
                activeIsDone ? Icons.check_circle : Icons.check_circle_outline,
                size: 20,
              ),
              label: Text(activeIsDone ? 'Done' : 'Done with this one'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2E9656),
                visualDensity: VisualDensity.compact,
                textStyle: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Menu extends StatelessWidget {
  const _Menu({
    required this.labels,
    required this.seconds,
    required this.done,
    required this.clock,
    required this.onSelect,
  });

  final List<String> labels;
  final List<int> seconds;
  final Set<int> done;
  final String Function(int seconds) clock;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            Text(
              'What next?',
              textAlign: TextAlign.center,
              style: GoogleFonts.fredoka(color: BrandTheme.ink, fontSize: 30),
            ),
            const SizedBox(height: 14),
            for (var i = 0; i < labels.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: FilledButton(
                  key: ValueKey<String>('study-menu-$i'),
                  onPressed: () => onSelect(i),
                  style: FilledButton.styleFrom(
                    backgroundColor: BrandTheme.ocean,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    textStyle: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  child: Text(
                    '${done.contains(i) ? '✓ ' : ''}${seconds[i] == 0 ? labels[i] : '${labels[i]}  ·  ${clock(seconds[i])}'}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ReadyHint extends StatelessWidget {
  const _ReadyHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('study-ready-hint'),
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0D9A0)),
      ),
      child: const Text(
        "The timer hasn't started. It begins with your child's first tap in the game.",
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFF4A3B10), fontSize: 13.5),
      ),
    );
  }
}

class _Scrim extends StatelessWidget {
  const _Scrim({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // A game in a web frame takes every click for itself, even under a Flutter
    // dialog, unless the dialog sits on a pointer interceptor.
    return PointerInterceptor(
      child: ColoredBox(
        color: const Color(0xB80F2231),
        child: Center(child: SingleChildScrollView(child: child)),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.emoji,
    required this.title,
    required this.message,
    required this.button,
    required this.buttonKey,
    required this.onPressed,
  });

  final String emoji;
  final String title;
  final String message;
  final String button;
  final String buttonKey;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      constraints: const BoxConstraints(maxWidth: 380),
      padding: const EdgeInsets.fromLTRB(26, 24, 26, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.fredoka(color: BrandTheme.ink, fontSize: 30),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF445062),
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            key: ValueKey<String>(buttonKey),
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: BrandTheme.ocean,
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            child: Text(button),
          ),
        ],
      ),
    );
  }
}
