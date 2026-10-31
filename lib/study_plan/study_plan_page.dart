import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grade_filter_shared/grade_filter_shared.dart';
import 'package:mode_selection_shared/mode_selection_shared.dart';
import 'package:study_plan_shared/study_plan_shared.dart';

import '../brand_theme.dart';
import '../home_backdrop.dart';
import 'study_catalog.dart';
import 'study_runner_page.dart';

/// Which "i" note is showing: All Modes of a game, or one of its modes.
typedef _Info = ({String gameId, String? modeId});

/// Where a parent builds a Study Plan: pick All Modes or single modes from
/// the games, then choose the total time. Nothing is saved.
class StudyPlanPage extends StatefulWidget {
  const StudyPlanPage({
    super.key,
    required this.draft,
    this.initialGrade,
    this.games,
  });

  final StudyPlanDraft draft;

  /// The grade chosen on the home page, carried over as a starting point.
  final GradeFilter? initialGrade;

  /// The games on offer; the catalog's games by default.
  final List<StudyGameInfo>? games;

  @override
  State<StudyPlanPage> createState() => _StudyPlanPageState();
}

class _StudyPlanPageState extends State<StudyPlanPage> {
  late final List<StudyGameInfo> _games = widget.games ?? studyGames();
  late GradeFilter? _grade = widget.initialGrade;
  _Info? _info;

  StudyGameInfo _gameById(String id) =>
      _games.firstWhere((StudyGameInfo g) => g.id == id);

  /// Grade buttons only matter once a game with a grade range is on offer.
  bool get _hasGradedGames => _games.any(
    (StudyGameInfo g) =>
        GradeSpan.parse(g.entry.gradeRangeLabel ?? 'All') != null,
  );

  void _pickAllModes(String gameId) {
    setState(() => _info = (gameId: gameId, modeId: null));
    widget.draft.toggleAllModes(gameId);
  }

  void _pickMode(String gameId, String modeId) {
    setState(() => _info = (gameId: gameId, modeId: modeId));
    widget.draft.toggleMode(gameId, modeId);
  }

  void _start() {
    final List<StudyPlanItem> items = widget.draft.items;
    if (items.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StudyRunnerPage(
          items: items,
          totalMinutes: widget.draft.totalMinutes,
          games: _games,
          onFinished: widget.draft.clear,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<StudyGameInfo> shown = _games
        .where(
          (StudyGameInfo g) =>
              gradeRangeMatches(g.entry.gradeRangeLabel ?? 'All', _grade),
        )
        .toList();
    return Scaffold(
      body: Stack(
        children: <Widget>[
          const HomeBackdrop(),
          SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1180),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _header(context),
                            if (_hasGradedGames) ...<Widget>[
                              const SizedBox(height: 14),
                              _gradeChips(),
                            ],
                            const SizedBox(height: 18),
                            _cards(shown),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                ListenableBuilder(
                  listenable: widget.draft,
                  builder: (BuildContext context, Widget? _) => _Tray(
                    draft: widget.draft,
                    gameById: _gameById,
                    onStart: _start,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  'Study Plan',
                  style: GoogleFonts.fredoka(
                    color: BrandTheme.ink,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            OutlinedButton(
              key: const ValueKey<String>('study-cancel'),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          kStudyPlanSubtitle,
          style: TextStyle(
            color: Color(0xFF445062),
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _gradeChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        const Text(
          'Grade',
          style: TextStyle(
            color: BrandTheme.ink,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        for (final GradeFilter grade in GradeFilter.values)
          ChoiceChip(
            key: ValueKey<String>('study-grade-${grade.label}'),
            label: Text(grade.label),
            selected: _grade == grade,
            showCheckmark: false,
            selectedColor: BrandTheme.ocean,
            labelStyle: TextStyle(
              color: _grade == grade ? Colors.white : BrandTheme.ink,
              fontWeight: FontWeight.w700,
            ),
            onSelected: (_) =>
                setState(() => _grade = _grade == grade ? null : grade),
          ),
      ],
    );
  }

  Widget _cards(List<StudyGameInfo> shown) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int columns = constraints.maxWidth >= 800 ? 2 : 1;
        const double gap = 14;
        final double width =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        return ListenableBuilder(
          listenable: widget.draft,
          builder: (BuildContext context, Widget? _) => Wrap(
            spacing: gap,
            runSpacing: gap,
            children: <Widget>[
              for (var i = 0; i < shown.length; i++)
                SizedBox(
                  width: width,
                  child: _GameCard(
                    game: shown[i],
                    palette: ModePalettes.byIndex(i),
                    draft: widget.draft,
                    info: _info?.gameId == shown[i].id ? _info : null,
                    onAllModes: () => _pickAllModes(shown[i].id),
                    onMode: (String modeId) => _pickMode(shown[i].id, modeId),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.game,
    required this.palette,
    required this.draft,
    required this.info,
    required this.onAllModes,
    required this.onMode,
  });

  final StudyGameInfo game;
  final ModePalette palette;
  final StudyPlanDraft draft;
  final _Info? info;
  final VoidCallback onAllModes;
  final ValueChanged<String> onMode;

  @override
  Widget build(BuildContext context) {
    final bool inPlan = draft.hasAny(game.id);
    final String grade = game.entry.gradeRangeLabel ?? 'All';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: inPlan ? BrandTheme.ocean : Colors.transparent,
          width: 2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: BrandTheme.ink.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[palette.start, palette.end],
                ),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: palette.effectiveIconBackground,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(game.entry.icon, color: palette.foreground),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          game.title,
                          style: TextStyle(
                            color: palette.foreground,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          game.entry.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: palette.foreground.withValues(alpha: 0.92),
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      grade,
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _AllModesButton(
                    key: ValueKey<String>('all-modes-${game.id}'),
                    selected: draft.hasAllModes(game.id),
                    showing: info != null && info!.modeId == null,
                    onTap: onAllModes,
                  ),
                  if (game.modes.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 12),
                    const Text(
                      'OR PICK ONE MODE',
                      style: TextStyle(
                        color: Color(0xFF5A6878),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        for (final StudyModeInfo mode in game.modes)
                          _ModeBubble(
                            key: ValueKey<String>('mode-${game.id}-${mode.id}'),
                            label: mode.title,
                            selected: draft.hasMode(game.id, mode.id),
                            showing: info?.modeId == mode.id,
                            onTap: () => onMode(mode.id),
                          ),
                      ],
                    ),
                  ] else ...<Widget>[
                    const SizedBox(height: 8),
                    const Text(
                      'This game has no separate modes.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF5A6878), fontSize: 13),
                    ),
                  ],
                  if (info != null) ...<Widget>[
                    const SizedBox(height: 10),
                    _Explanation(game: game, info: info!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllModesButton extends StatelessWidget {
  const _AllModesButton({
    super.key,
    required this.selected,
    required this.showing,
    required this.onTap,
  });

  final bool selected;
  final bool showing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color fg = selected ? Colors.white : BrandTheme.ocean;
    return Semantics(
      button: true,
      selected: selected,
      label:
          'All Modes, tap to ${selected ? 'remove' : 'add'} and see what it means',
      excludeSemantics: true,
      child: Material(
        color: selected ? BrandTheme.ocean : const Color(0xFFEAF5FB),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selected ? BrandTheme.ocean : const Color(0xFFB7D8EA),
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: const BoxConstraints(minHeight: 50),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: showing
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: BrandTheme.ocean.withValues(alpha: 0.25),
                        spreadRadius: 3,
                      ),
                    ],
                  )
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  selected
                      ? Icons.check_circle_outline
                      : Icons.add_circle_outline,
                  color: fg,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'All Modes',
                  style: TextStyle(
                    color: fg,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.info_outline,
                  color: fg.withValues(alpha: 0.75),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeBubble extends StatelessWidget {
  const _ModeBubble({
    super.key,
    required this.label,
    required this.selected,
    required this.showing,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool showing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color fg = selected ? Colors.white : BrandTheme.ink;
    return Semantics(
      button: true,
      selected: selected,
      label:
          '$label, tap to ${selected ? 'remove' : 'add'} and see what it means',
      excludeSemantics: true,
      child: Material(
        color: selected ? BrandTheme.ocean : Colors.white,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? BrandTheme.ocean : const Color(0xFFB9C6D3),
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: showing
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: BrandTheme.ocean.withValues(alpha: 0.2),
                        spreadRadius: 3,
                      ),
                    ],
                  )
                : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (selected) ...<Widget>[
                  Icon(Icons.check, color: fg, size: 16),
                  const SizedBox(width: 4),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: fg,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.info_outline,
                  color: fg.withValues(alpha: 0.7),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Explanation extends StatelessWidget {
  const _Explanation({required this.game, required this.info});

  final StudyGameInfo game;
  final _Info info;

  @override
  Widget build(BuildContext context) {
    final StudyModeInfo? mode = info.modeId == null
        ? null
        : game.modeById(info.modeId!);
    final String title = mode?.title ?? 'All Modes';
    final String body = mode?.description ?? game.allModesNote;
    return Container(
      key: const ValueKey<String>('study-explanation'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0D9A0)),
      ),
      child: Text.rich(
        TextSpan(
          children: <InlineSpan>[
            TextSpan(
              text: '$title: ',
              style: const TextStyle(
                color: BrandTheme.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            TextSpan(text: body),
          ],
        ),
        style: const TextStyle(
          color: Color(0xFF4A3B10),
          fontSize: 13.5,
          height: 1.4,
        ),
      ),
    );
  }
}

class _Tray extends StatelessWidget {
  const _Tray({
    required this.draft,
    required this.gameById,
    required this.onStart,
  });

  final StudyPlanDraft draft;
  final StudyGameInfo Function(String id) gameById;
  final VoidCallback onStart;

  String _label(StudyPlanItem item) {
    final StudyGameInfo game = gameById(item.gameId);
    final StudyModeInfo? mode = item.modeId == null
        ? null
        : game.modeById(item.modeId!);
    return mode == null ? game.title : '${game.title}: ${mode.title}';
  }

  @override
  Widget build(BuildContext context) {
    final StudyPlanSuggestion? advice = suggestStudyMinutes(
      items: draft.items,
      totalMinutes: draft.totalMinutes,
      modeCountFor: (String id) => gameById(id).modes.length,
    );
    final Widget time = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: 6,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Text(
                'Total time',
                style: TextStyle(
                  color: BrandTheme.ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            for (final int minutes in kStudyPlanMinuteOptions)
              ChoiceChip(
                key: ValueKey<String>('study-minutes-$minutes'),
                label: Text('$minutes min'),
                selected: draft.totalMinutes == minutes,
                showCheckmark: false,
                selectedColor: BrandTheme.ocean,
                labelStyle: TextStyle(
                  color: draft.totalMinutes == minutes
                      ? Colors.white
                      : BrandTheme.ink,
                  fontWeight: FontWeight.w800,
                ),
                onSelected: (_) => draft.setTotalMinutes(minutes),
              ),
          ],
        ),
        if (advice != null && advice.isTight)
          _Suggestion(
            advice: advice,
            itemCount: draft.items.length,
            totalMinutes: draft.totalMinutes,
            onUse: draft.setTotalMinutes,
          ),
      ],
    );
    final Widget start = FilledButton(
      key: const ValueKey<String>('study-start'),
      onPressed: draft.isEmpty ? null : onStart,
      style: FilledButton.styleFrom(
        backgroundColor: BrandTheme.ocean,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
      ),
      child: const Text('Start Study Plan'),
    );
    return Material(
      elevation: 12,
      color: Colors.white.withValues(alpha: 0.97),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (draft.isEmpty)
                  const Text(
                    'Nothing picked yet. Add a game or a mode above.',
                    style: TextStyle(color: Color(0xFF5A6878), fontSize: 14),
                  )
                else
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: <Widget>[
                      for (final StudyPlanItem item in draft.items)
                        InputChip(
                          key: ValueKey<String>(
                            'tray-${item.gameId}-${item.modeId ?? 'all'}',
                          ),
                          label: Text(_label(item)),
                          onDeleted: () => draft.remove(item),
                          backgroundColor: const Color(0xFFE6F3FB),
                          labelStyle: const TextStyle(
                            color: BrandTheme.ocean,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints c) {
                    if (c.maxWidth < 700) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          time,
                          const SizedBox(height: 12),
                          start,
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(child: time),
                        const SizedBox(width: 16),
                        start,
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Suggestion extends StatelessWidget {
  const _Suggestion({
    required this.advice,
    required this.itemCount,
    required this.totalMinutes,
    required this.onUse,
  });

  final StudyPlanSuggestion advice;
  final int itemCount;
  final int totalMinutes;
  final ValueChanged<int> onUse;

  static String _each(double minutes) {
    final String text = minutes.toStringAsFixed(1);
    return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
  }

  @override
  Widget build(BuildContext context) {
    final int? suggested = advice.suggestedMinutes;
    final String message = suggested == null
        ? 'This plan has a lot to cover for $totalMinutes min. Try fewer games or modes, or pick single modes.'
        : '$itemCount ${itemCount == 1 ? 'item' : 'items'} in $totalMinutes min is tight, about ${_each(totalMinutes / itemCount)} min each. We suggest $suggested min.';
    return Container(
      key: const ValueKey<String>('study-suggestion'),
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0D9A0)),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          Text(
            message,
            style: const TextStyle(
              color: Color(0xFF4A3B10),
              fontSize: 13.5,
              height: 1.4,
            ),
          ),
          if (suggested != null)
            FilledButton(
              key: const ValueKey<String>('study-use-suggestion'),
              onPressed: () => onUse(suggested),
              style: FilledButton.styleFrom(
                backgroundColor: BrandTheme.ocean,
                visualDensity: VisualDensity.compact,
              ),
              child: Text('Use $suggested min'),
            ),
        ],
      ),
    );
  }
}
