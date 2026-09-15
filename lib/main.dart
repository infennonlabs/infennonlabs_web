import 'package:flutter/material.dart';
import 'package:game_settings_shared/game_settings_shared.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mode_selection_shared/mode_selection_shared.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> _launchUri(Uri uri) async {
  await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
    webOnlyWindowName: '_blank',
  );
}

class BrandTheme {
  static const Color ink = Color(0xFF0F2231);
  static const Color ocean = Color(0xFF0B5E8B);
  static const Color lime = Color(0xFF8FD060);
  static const Color peach = Color(0xFFFFB36A);
  static const Color sky = Color(0xFF4CB4E7);
}

void main() {
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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const String _projectBaseUrl = 'https://infennonlabs.com';

  static final List<ProjectEntry> _projects = <ProjectEntry>[
    ProjectEntry(
      title: 'Alpha Kids',
      description: 'Emphasis on the alphabet and associated words and sounds',
      slug: 'alpha-kids',
      icon: Icons.abc,
      gradeRangeLabel: 'Early-PreK',
      ageOrder: 0,
    ),
    ProjectEntry(
      title: 'Does It Solve',
      description: 'Simple math logical thinking',
      slug: 'does-it-solve',
      icon: Icons.extension_outlined,
      gradeRangeLabel: 'K-1st',
      ageOrder: 20,
    ),
    ProjectEntry(
      title: 'Tile Match Learning',
      description: 'Fun pattern recognition learning',
      slug: 'tile-match',
      icon: Icons.grid_view_rounded,
      gradeRangeLabel: 'PreK-5th',
      ageOrder: 13,
    ),
    ProjectEntry(
      title: 'Make It',
      description: 'Critical thinking and spelling through recipe creations',
      slug: 'make-it',
      icon: Icons.build_circle_outlined,
      gradeRangeLabel: 'PreK-2nd',
      ageOrder: 10,
    ),
    ProjectEntry(
      title: 'Math Adventures Kids',
      description:
          'Build strong math skills through patterns and problem solving',
      slug: 'math-adventure',
      icon: Icons.calculate_outlined,
      gradeRangeLabel: 'PreK-2nd',
      ageOrder: 11,
    ),
    ProjectEntry(
      title: 'Memory Match',
      description:
          'Card-flip memory games designed for recognition and recall.',
      slug: 'memory-match',
      icon: Icons.style_outlined,
      gradeRangeLabel: 'PreK-2nd',
      ageOrder: 12,
    ),
    ProjectEntry(
      title: 'Reading Writing Kids',
      description: 'Read and write with confidence',
      slug: 'reading-writing',
      icon: Icons.menu_book_outlined,
      gradeRangeLabel: 'K-3rd',
      ageOrder: 21,
    ),
    ProjectEntry(
      title: 'Sight Word Search',
      description: 'Word search and spelling practice',
      slug: 'sight-word',
      icon: Icons.search_outlined,
      gradeRangeLabel: 'K-5th',
      ageOrder: 22,
    ),
  ];

  Future<void> _openProject(ProjectEntry entry) async {
    final uri = Uri.parse('$_projectBaseUrl/${entry.slug}/');
    await _launchUri(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          const _Backdrop(),
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
                    _ProjectSection(projects: _projects, onTap: _openProject),
                    SizedBox(height: Responsive.spacing(context, 3)),
                    const _AboutSection(),
                    SizedBox(height: Responsive.spacing(context, 3)),
                    const _ContactSection(),
                    SizedBox(height: Responsive.spacing(context, 1.5)),
                    const _LegalPlaceholderLinks(),
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

class ProjectEntry {
  const ProjectEntry({
    required this.title,
    required this.description,
    required this.slug,
    required this.icon,
    this.gradeRangeLabel,
    this.ageOrder,
    this.isPlaceholder = false,
  });

  final String title;
  final String description;
  final String slug;
  final IconData icon;
  final String? gradeRangeLabel;
  final int? ageOrder;
  final bool isPlaceholder;
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

class _Backdrop extends StatelessWidget {
  const _Backdrop();

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

class _ProjectSection extends StatelessWidget {
  const _ProjectSection({required this.projects, required this.onTap});

  final List<ProjectEntry> projects;
  final ValueChanged<ProjectEntry> onTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 1120
        ? 3
        : width >= 720
        ? 2
        : 1;
    final liveProjects =
        projects.where((ProjectEntry entry) => !entry.isPlaceholder).toList()
          ..sort((ProjectEntry a, ProjectEntry b) {
            final left = a.ageOrder ?? 999;
            final right = b.ageOrder ?? 999;
            return left.compareTo(right);
          });
    final remainder = liveProjects.length % columns;
    final placeholderCount = remainder == 0 ? columns : columns - remainder;
    final displayProjects = <ProjectEntry>[
      ...liveProjects,
      for (var i = 0; i < placeholderCount; i++)
        ProjectEntry(
          title: 'More Games Soon',
          description:
              'New learning games are on the way. Check back for future launches.',
          slug: '__coming-soon-$i',
          icon: Icons.auto_awesome,
          isPlaceholder: true,
        ),
    ];
    final aspectRatio = projectCardAspectRatioForWidth(width);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        GridView.builder(
          itemCount: displayProjects.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: aspectRatio,
          ),
          itemBuilder: (BuildContext context, int index) {
            final entry = displayProjects[index];
            final palette = ModePalettes.byIndex(index);
            return _StaggeredReveal(
              index: index,
              child: _ProjectCard(
                entry: entry,
                palette: palette,
                onTap: entry.isPlaceholder ? null : () => onTap(entry),
              ),
            );
          },
        ),
      ],
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
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
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              isCompact ? 16 : 20,
              isCompact ? 16 : 20,
              isCompact ? 16 : 20,
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
                        Icons.open_in_new_rounded,
                        color: palette.foreground.withValues(alpha: 0.9),
                        size: isCompact ? 18 : 20,
                      ),
                  ],
                ),
                SizedBox(height: isCompact ? 12 : 18),
                Text(
                  entry.title,
                  style: TextStyle(
                    color: palette.foreground,
                    fontSize: isCompact ? 20 : 24,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                SizedBox(height: isCompact ? 5 : 10),
                Text(
                  entry.description,
                  style: TextStyle(
                    color: palette.foreground.withValues(alpha: 0.92),
                    fontSize: isCompact ? 13.5 : 15.5,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: isCompact ? 10 : 20),
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final badgeGap = isCompact ? 8.0 : 10.0;
                    final availableWidth = constraints.maxWidth;
                    final badgeWidth = (availableWidth - (badgeGap * 2)) / 3;
                    final badgeHeight = badgeWidth.clamp(
                      isCompact ? 34.0 : 38.0,
                      isCompact ? 48.0 : 54.0,
                    );
                    final iconSize = (badgeHeight * 0.44).clamp(16.0, 22.0);

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
              : Center(
                  child: Icon(icon, size: iconSize, color: badgeForeground),
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
            'InfennonLabs learning is an effort to provide truly free learning experiences for young children as they begin their journey through school. The goal is to present a clear experience without the need for a subscription or distracting interface/characters. The focus should be on learning and getting stronger skills for life. These projects have been built based on the experiences I\'ve had with my own two kids. One day I would like for this platform to be a vessel in which any child could interact to have their own tailored games made for their specific development needs.',
            style: TextStyle(
              fontSize: isCompact ? 15 : 17,
              height: 1.55,
              color: const Color(0xFF334155),
              fontWeight: FontWeight.w700,
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

class _LegalPlaceholderLinks extends StatelessWidget {
  const _LegalPlaceholderLinks();

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      color: const Color(0xFF667085),
      fontSize: 13,
      fontWeight: FontWeight.w700,
      decoration: TextDecoration.underline,
      decorationColor: const Color(0xFF98A2B3),
    );

    return Center(
      child: Text.rich(
        TextSpan(
          children: <InlineSpan>[
            TextSpan(text: 'Privacy Policy', style: textStyle),
            const TextSpan(text: '  |  '),
            TextSpan(text: 'Terms of Service', style: textStyle),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
