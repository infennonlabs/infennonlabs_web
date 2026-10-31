import 'package:flutter/material.dart';
import 'package:game_settings_shared/game_settings_shared.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grade_filter_shared/grade_filter_shared.dart';
import 'package:mode_selection_shared/mode_selection_shared.dart';
import 'package:study_plan_bridge_shared/study_plan_bridge_shared.dart';
import 'package:study_plan_shared/study_plan_shared.dart';
import 'package:url_launcher/url_launcher.dart';

import 'brand_theme.dart';
import 'grade_filter_store.dart';
import 'home_backdrop.dart';
import 'project_registry.dart';
import 'study_plan/study_catalog.dart';
import 'study_plan/study_plan_card.dart';
import 'study_plan/study_plan_page.dart';
import 'study_plan/study_runner_page.dart';

export 'brand_theme.dart' show BrandTheme;

const String _appBuildChannel = String.fromEnvironment(
  'APP_BUILD_CHANNEL',
  defaultValue: 'stable',
);

Future<void> _launchUri(Uri uri, {String windowName = '_self'}) async {
  await launchUrl(
    uri,
    mode: LaunchMode.platformDefault,
    webOnlyWindowName: windowName,
  );
}

void main() {
  // If a game's old Back to Home loaded this page inside a Study Plan frame,
  // hand the child back to the plan instead of showing the home in the frame.
  if (StudyPlanBridge.isFramed) StudyPlanBridge.requestExit();
  runApp(const InfennonLabsApp());
}

class InfennonLabsApp extends StatelessWidget {
  const InfennonLabsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Learning Games',
      scrollBehavior: const _NoScrollbarBehavior(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: BrandTheme.ocean,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4FAFF),
        textTheme: GoogleFonts.nunitoTextTheme(),
        primaryTextTheme: GoogleFonts.nunitoTextTheme(),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String _projectBaseUrl = 'https://infennonlabs.com';

  /// Restored from this tab's session, so coming back from a game keeps it.
  GradeFilter? _filter = GradeFilter.fromLabel(readSavedGradeLabel());

  /// The Study Plan being put together. Lives only while this page is open.
  final StudyPlanDraft _plan = StudyPlanDraft();

  @override
  void dispose() {
    _plan.dispose();
    super.dispose();
  }

  void _prepareStudyPlan() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StudyPlanPage(draft: _plan, initialGrade: _filter),
      ),
    );
  }

  void _startStudyPlan() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StudyRunnerPage(
          items: _plan.items,
          totalMinutes: _plan.totalMinutes,
          games: studyGames(),
          onFinished: _plan.clear,
        ),
      ),
    );
  }

  void _setFilter(GradeFilter? value) {
    setState(() => _filter = value);
    saveGradeLabel(value?.label);
  }

  Future<void> _openProject(ProjectEntry entry) async {
    final uri = Uri.parse(entry.launchUrl ?? '$_projectBaseUrl/${entry.slug}/');
    await _launchUri(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          const HomeBackdrop(),
          SafeArea(
            child: ResponsivePage(
              maxWidth: 1180,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const _Header(),
                    SizedBox(height: Responsive.spacing(context, 3)),
                    LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints c) {
                        final filterBar = _GradeFilterBar(
                          selected: _filter,
                          onChanged: _setFilter,
                        );
                        final planCard = StudyPlanCard(
                          draft: _plan,
                          onPrepare: _prepareStudyPlan,
                          onStart: _startStudyPlan,
                        );
                        if (c.maxWidth < 900) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              planCard,
                              const SizedBox(height: 14),
                              filterBar,
                            ],
                          );
                        }
                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Expanded(flex: 3, child: filterBar),
                              const SizedBox(width: 16),
                              Expanded(flex: 2, child: planCard),
                            ],
                          ),
                        );
                      },
                    ),
                    _ProjectSection(
                      projects: kProjectRegistry,
                      filter: _filter,
                      onTap: _openProject,
                    ),
                    SizedBox(height: Responsive.spacing(context, 3)),
                    const _AboutSection(),
                    SizedBox(height: Responsive.spacing(context, 3)),
                    const _ContactSection(),
                    SizedBox(height: Responsive.spacing(context, 1.5)),
                    const _LegalLinks(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

double projectCardAspectRatioForWidth(double width) {
  final columns = width >= 1120
      ? 3
      : width >= 720
      ? 2
      : 1;

  if (columns == 1) {
    final normalized = ((width - 320) / 200).clamp(0.0, 1.0);
    return 1.28 + (normalized * 0.12);
  }

  if (columns == 2) {
    final normalized = ((width - 720) / 360).clamp(0.0, 1.0);
    return 1.28 + (normalized * 0.10);
  }

  final normalized = ((width - 1120) / 320).clamp(0.0, 1.0);
  return 1.36 + (normalized * 0.08);
}

class _NoScrollbarBehavior extends MaterialScrollBehavior {
  const _NoScrollbarBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 760;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: Responsive.spacing(context, 0.75)),
        Text(
          'Learning Games',
          style: TextStyle(
            color: BrandTheme.ocean.withValues(alpha: 0.9),
            fontSize: isCompact ? 12 : 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.4,
          ),
        ),
        SizedBox(height: Responsive.spacing(context, 0.9)),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Flexible(
                child: Text(
                  'InfennonLabs',
                  style: TextStyle(
                    fontFamily: GoogleFonts.fredoka().fontFamily,
                    fontSize: isCompact ? 38 : 58,
                    height: 0.96,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.4,
                    color: BrandTheme.ink,
                  ),
                ),
              ),
              SizedBox(width: isCompact ? 10 : 16),
              Image.asset(
                'assets/images/infennon_logo.png',
                width: isCompact ? 56 : 88,
                height: isCompact ? 56 : 88,
                semanticLabel: 'InfennonLabs logo',
              ),
            ],
          ),
        ),
        SizedBox(height: Responsive.spacing(context, 0.7)),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Text(
            'Early learning tools for the developing child PreK-5th grades',
            style: TextStyle(
              fontSize: isCompact ? 16 : 18,
              height: 1.45,
              color: const Color(0xFF445062),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _StaggeredReveal extends StatelessWidget {
  const _StaggeredReveal({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 360 + (index * 80)),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (BuildContext context, double value, Widget? childWidget) {
        final eased = Curves.easeOut.transform(value);
        return Opacity(
          opacity: eased,
          child: Transform.translate(
            offset: Offset(0, (1 - eased) * 20),
            child: childWidget,
          ),
        );
      },
    );
  }
}

/// Grade buttons for the home, with a note and a reset while one is chosen.
class _GradeFilterBar extends StatelessWidget {
  const _GradeFilterBar({required this.selected, required this.onChanged});

  final GradeFilter? selected;
  final ValueChanged<GradeFilter?> onChanged;

  @override
  Widget build(BuildContext context) {
    final current = selected;
    // No panel of its own: the title and buttons sit on the page background.
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 4, 2, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Semantics(
            header: true,
            child: const Text(
              'Find games for your grade',
              style: TextStyle(
                color: BrandTheme.ink,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final grade in GradeFilter.values)
                ChoiceChip(
                  key: ValueKey<String>('filter-${grade.label}'),
                  label: Text(grade.label),
                  selected: current == grade,
                  showCheckmark: false,
                  // White buttons with a soft border read clearly on the
                  // page background; the chosen grade fills in.
                  backgroundColor: Colors.white,
                  selectedColor: BrandTheme.ocean,
                  elevation: 0,
                  pressElevation: 0,
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: current == grade
                          ? BrandTheme.ocean
                          : const Color(0xFF9FB2C4),
                      width: 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 8,
                  ),
                  labelStyle: TextStyle(
                    color: current == grade ? Colors.white : BrandTheme.ink,
                    fontWeight: FontWeight.w700,
                  ),
                  // Tapping the selected grade again shows every game.
                  onSelected: (_) => onChanged(current == grade ? null : grade),
                ),
            ],
          ),
          if (current != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                key: const ValueKey<String>('filter-reset'),
                onPressed: () => onChanged(null),
                child: Text('Showing games for ${current.label}. Show all'),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProjectSection extends StatelessWidget {
  const _ProjectSection({
    required this.projects,
    required this.filter,
    required this.onTap,
  });

  final List<ProjectEntry> projects;
  final GradeFilter? filter;
  final ValueChanged<ProjectEntry> onTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 1120
        ? 3
        : width >= 720
        ? 2
        : 1;
    final liveProjects = projects
        .where((ProjectEntry entry) => !entry.isPlaceholder)
        .where(_isVisibleOnCurrentChannel)
        .where(
          (ProjectEntry entry) =>
              gradeRangeMatches(entry.gradeRangeLabel ?? 'All', filter),
        )
        .toList();
    final aspectRatio = projectCardAspectRatioForWidth(width);

    // Bands in display order; a band with no matching game is left out.
    final bands = <HomeBand, List<ProjectEntry>>{
      for (final band in HomeBand.values)
        band:
            liveProjects
                .where(
                  (ProjectEntry entry) =>
                      (entry.band ?? HomeBand.everyone) == band,
                )
                .toList()
              ..sort(
                (ProjectEntry a, ProjectEntry b) =>
                    (a.ageOrder ?? 999).compareTo(b.ageOrder ?? 999),
              ),
    }..removeWhere((HomeBand _, List<ProjectEntry> list) => list.isEmpty);

    if (bands.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 28),
        child: Text(
          'No games for this grade yet.',
          style: TextStyle(
            color: BrandTheme.ink,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    // The unfiltered page still ends with "coming soon" tiles that fill the
    // last row; they are left out while a grade is chosen.
    final lastBand = bands.keys.last;
    var paletteIndex = 0;
    var revealIndex = 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final band in bands.keys) ...<Widget>[
          _BandHeading(band: band, count: bands[band]!.length),
          Builder(
            builder: (BuildContext context) {
              final entries = bands[band]!;
              final displayProjects = <ProjectEntry>[
                ...entries,
                if (filter == null && band == lastBand)
                  ..._comingSoonEntries(entries.length, columns),
              ];
              final startPalette = paletteIndex;
              final startReveal = revealIndex;
              paletteIndex += displayProjects.length;
              revealIndex += displayProjects.length;
              return GridView.builder(
                itemCount: displayProjects.length,
                shrinkWrap: true,
                clipBehavior: Clip.none,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: aspectRatio,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final entry = displayProjects[index];
                  final palette = ModePalettes.byIndex(startPalette + index);
                  return _StaggeredReveal(
                    index: startReveal + index,
                    child: _ProjectCard(
                      entry: entry,
                      palette: palette,
                      onTap: entry.isPlaceholder ? null : () => onTap(entry),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ],
    );
  }

  List<ProjectEntry> _comingSoonEntries(int liveCount, int columns) {
    final remainder = liveCount % columns;
    final placeholderCount = remainder == 0 ? columns : columns - remainder;
    return <ProjectEntry>[
      for (var i = 0; i < placeholderCount; i++)
        ProjectEntry(
          id: '__coming_soon_$i',
          title: 'Coming Soon',
          description:
              'New learning games are on the way. Check back for future launches.',
          slug: '__coming-soon-$i',
          icon: Icons.auto_awesome,
          isPlaceholder: true,
        ),
    ];
  }

  bool _isVisibleOnCurrentChannel(ProjectEntry entry) {
    if (entry.channelPolicy == 'dev') {
      return _appBuildChannel == 'dev';
    }
    return true;
  }
}

class _BandHeading extends StatelessWidget {
  const _BandHeading({required this.band, required this.count});

  final HomeBand band;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 14),
      child: Row(
        children: <Widget>[
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: band.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Semantics(
              header: true,
              child: Text(
                band.label,
                style: const TextStyle(
                  color: BrandTheme.ink,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            count == 1 ? '1 game' : '$count games',
            style: const TextStyle(
              color: Color(0xFF5A6878),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.entry,
    required this.palette,
    required this.onTap,
  });

  final ProjectEntry entry;
  final ModePalette palette;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 420;
    final descriptionStyle = TextStyle(
      color: palette.foreground.withValues(alpha: 0.92),
      fontSize: isCompact ? 13.5 : 15.5,
      height: 1.35,
      fontWeight: FontWeight.w500,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[palette.start, palette.end],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: palette.start.withValues(alpha: 0.24),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final horizontalPadding = isCompact ? 16.0 : 20.0;
              final verticalPadding = isCompact ? 12.0 : 18.0;
              final titleStyle = TextStyle(
                color: palette.foreground,
                fontSize: isCompact ? 20 : 24,
                fontWeight: FontWeight.w900,
                height: 1.05,
              );

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  verticalPadding,
                  horizontalPadding,
                  isCompact ? 12 : 18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: isCompact ? 44 : 52,
                          height: isCompact ? 44 : 52,
                          decoration: BoxDecoration(
                            color: palette.effectiveIconBackground,
                            borderRadius: BorderRadius.circular(
                              isCompact ? 14 : 16,
                            ),
                          ),
                          child: Icon(
                            entry.icon,
                            color: palette.foreground,
                            size: isCompact ? 26 : 30,
                          ),
                        ),
                        if (!entry.isPlaceholder &&
                            entry.gradeRangeLabel != null) ...<Widget>[
                          SizedBox(width: isCompact ? 8 : 10),
                          Flexible(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isCompact ? 10 : 12,
                                  vertical: isCompact ? 5 : 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  entry.gradeRangeLabel!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: const Color(0xFF1E293B),
                                    fontWeight: FontWeight.w900,
                                    fontSize: isCompact ? 12 : 13,
                                    height: 1,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        if (!entry.isPlaceholder)
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: palette.foreground.withValues(alpha: 0.9),
                            size: isCompact ? 18 : 20,
                          ),
                      ],
                    ),
                    SizedBox(height: isCompact ? 12 : 18),
                    Text(entry.title, style: titleStyle),
                    SizedBox(height: isCompact ? 5 : 10),
                    Text(entry.description, style: descriptionStyle),
                    const Spacer(),
                    LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                            final badgeGap = isCompact ? 8.0 : 10.0;
                            final availableWidth = constraints.maxWidth;
                            final badgeWidth =
                                (availableWidth - (badgeGap * 2)) / 3;
                            final badgeHeight = badgeWidth.clamp(
                              isCompact ? 34.0 : 38.0,
                              isCompact ? 48.0 : 54.0,
                            );
                            final iconSize = (badgeHeight * 0.44).clamp(
                              16.0,
                              22.0,
                            );

                            return Row(
                              children: <Widget>[
                                Expanded(
                                  child: _PlatformBadge(
                                    icon: Icons.desktop_windows_rounded,
                                    label: 'Desktop/Web',
                                    foreground: palette.foreground,
                                    background: palette.effectiveIconBackground,
                                    height: badgeHeight,
                                    iconSize: iconSize,
                                    comingSoon: entry.isPlaceholder,
                                  ),
                                ),
                                SizedBox(width: badgeGap),
                                Expanded(
                                  child: _PlatformBadge(
                                    icon: Icons.apple,
                                    label: 'iOS',
                                    foreground: palette.foreground,
                                    background: palette.effectiveIconBackground,
                                    height: badgeHeight,
                                    iconSize: iconSize,
                                    comingSoon: true,
                                  ),
                                ),
                                SizedBox(width: badgeGap),
                                Expanded(
                                  child: _PlatformBadge(
                                    icon: Icons.android_rounded,
                                    label: 'Android',
                                    foreground: palette.foreground,
                                    background: palette.effectiveIconBackground,
                                    height: badgeHeight,
                                    iconSize: iconSize,
                                    comingSoon: true,
                                  ),
                                ),
                              ],
                            );
                          },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PlatformBadge extends StatelessWidget {
  const _PlatformBadge({
    required this.icon,
    required this.label,
    required this.foreground,
    required this.background,
    required this.height,
    required this.iconSize,
    required this.comingSoon,
  });

  final IconData icon;
  final String label;
  final Color foreground;
  final Color background;
  final double height;
  final double iconSize;
  final bool comingSoon;

  @override
  Widget build(BuildContext context) {
    final mutedForeground = Colors.white.withValues(alpha: 0.62);
    final badgeForeground = comingSoon
        ? mutedForeground
        : foreground.withValues(alpha: 0.92);
    final badgeBackground = comingSoon
        ? const Color(0xFFF1F4F8)
        : background.withValues(alpha: 0.18);

    return Tooltip(
      message: comingSoon ? '$label coming soon' : label,
      child: SizedBox(
        height: height,
        child: Container(
          decoration: BoxDecoration(
            color: badgeBackground,
            borderRadius: BorderRadius.circular(
              comingSoon ? height * 0.22 : height * 0.36,
            ),
            border: Border.all(
              color: comingSoon
                  ? const Color(0xFFD7DEE8)
                  : foreground.withValues(alpha: 0.16),
            ),
          ),
          child: comingSoon
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(icon, size: iconSize, color: const Color(0xFF738091)),
                    SizedBox(height: height * 0.08),
                    Text(
                      'Coming soon',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF738091),
                        fontSize: height * 0.18,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(icon, size: iconSize, color: badgeForeground),
                    const SizedBox(height: 2),
                    Text(
                      'Play Now',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: badgeForeground,
                        fontSize: height * 0.18,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection();

  Future<void> _openEmail(String to, String subject) async {
    final uri = Uri(
      scheme: 'mailto',
      path: to,
      queryParameters: <String, String>{'subject': subject},
    );
    await _launchUri(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: BrandTheme.ink,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x40112537),
            blurRadius: 26,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _SectionLabel(
            title: 'Contact',
            subtitle: '',
            titleColor: Colors.white,
            subtitleColor: Color(0xFFD3D9E3),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              const gap = 12.0;
              final isCompact = constraints.maxWidth < 760;
              final columns = isCompact ? 1 : 2;
              final chipWidth =
                  (constraints.maxWidth - (gap * (columns - 1))) / columns;

              Widget chip(
                IconData icon,
                String label,
                String value,
                VoidCallback? onTap,
              ) {
                return SizedBox(
                  width: chipWidth,
                  child: _ContactChip(
                    icon: icon,
                    label: label,
                    value: value,
                    onTap: onTap,
                  ),
                );
              }

              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: <Widget>[
                  chip(
                    Icons.email_outlined,
                    'General',
                    'contact@infennonlabs.com',
                    () => _openEmail(
                      'contact@infennonlabs.com',
                      'Infennon Labs Inquiry',
                    ),
                  ),
                  chip(
                    Icons.campaign_outlined,
                    'Partnerships',
                    'partners@infennonlabs.com',
                    () => _openEmail(
                      'partners@infennonlabs.com',
                      'Partnership Request',
                    ),
                  ),
                  chip(
                    Icons.support_agent_outlined,
                    'Support',
                    'support@infennonlabs.com',
                    () => _openEmail(
                      'support@infennonlabs.com',
                      'Support Request',
                    ),
                  ),
                  chip(
                    Icons.volunteer_activism_outlined,
                    'Donate Here:',
                    'GoFundMe',
                    () => _launchUri(Uri.parse('https://gofund.me/5b62c3b83')),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 760;

    return Container(
      padding: EdgeInsets.all(isCompact ? 20 : 26),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFDDE7F2)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x24112537),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'About',
            style: TextStyle(
              color: BrandTheme.ink,
              fontSize: isCompact ? 24 : 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          SizedBox(height: isCompact ? 10 : 12),
          Text(
            AboutContent.mission,
            style: TextStyle(
              fontSize: isCompact ? 15 : 17,
              height: 1.55,
              color: const Color(0xFF334155),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: isCompact ? 12 : 16),
          Text(
            AboutContent.specialThanks,
            style: TextStyle(
              fontSize: isCompact ? 15 : 17,
              height: 1.55,
              color: const Color(0xFF334155),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactChip extends StatelessWidget {
  const _ContactChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: disabled ? 0.05 : 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: disabled ? 0.08 : 0.12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Icon(
              icon,
              size: 18,
              color: Colors.white.withValues(alpha: disabled ? 0.7 : 1),
            ),
            const SizedBox(width: 8),
            Flexible(
              flex: 3,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: disabled ? 0.76 : 1),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              flex: 5,
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: const Color(
                    0xFFD4DCEA,
                  ).withValues(alpha: disabled ? 0.82 : 1),
                  fontWeight: FontWeight.w500,
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.title,
    this.subtitle = '',
    this.titleColor = const Color(0xFF111827),
    this.subtitleColor = const Color(0xFF4B5563),
  });

  final String title;
  final String subtitle;
  final Color titleColor;
  final Color subtitleColor;

  @override
  Widget build(BuildContext context) {
    final hasSubtitle = subtitle.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            color: titleColor,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        if (hasSubtitle) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: subtitleColor,
              fontSize: 15.5,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class _LegalLinks extends StatelessWidget {
  const _LegalLinks();

  @override
  Widget build(BuildContext context) {
    const dividerColor = Color(0xFF98A2B3);
    final textStyle = TextStyle(
      color: const Color(0xFF667085),
      fontSize: 13,
      fontWeight: FontWeight.w700,
      decoration: TextDecoration.underline,
      decorationColor: dividerColor,
    );

    Widget link(String label, Uri uri, Key key) {
      return InkWell(
        key: key,
        onTap: () => _launchUri(uri, windowName: '_blank'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          child: Text(label, style: textStyle),
        ),
      );
    }

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          link(
            'Privacy Policy',
            GlobalSettingsScreen.privacyPolicyUri,
            const Key('home-privacy-policy-link'),
          ),
          const Text('|', style: TextStyle(color: dividerColor)),
          link(
            'Terms of Service',
            GlobalSettingsScreen.termsOfServiceUri,
            const Key('home-terms-of-service-link'),
          ),
        ],
      ),
    );
  }
}
