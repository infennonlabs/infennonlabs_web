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
      title: 'Infennon Labs',
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
      description:
          'Foundational learning tools for letters, sounds, and early wins.',
      slug: 'alpha-kids',
      icon: Icons.abc,
    ),
    ProjectEntry(
      title: 'Does It Solve',
      description:
          'Puzzle-driven practice that rewards clear thinking and persistence.',
      slug: 'does-it-solve',
      icon: Icons.extension_outlined,
    ),
    ProjectEntry(
      title: 'Mahjong',
      description:
          'A classic tile-matching experience tuned for quick, satisfying play.',
      slug: 'mahjong',
      icon: Icons.grid_view_rounded,
    ),
    ProjectEntry(
      title: 'Make It',
      description:
          'Creative building and making games that encourage imagination.',
      slug: 'make-it',
      icon: Icons.build_circle_outlined,
    ),
    ProjectEntry(
      title: 'Math Adventures Kids',
      description:
          'Playful math paths for patterns, equations, and confidence.',
      slug: 'math-adventures-kids',
      icon: Icons.calculate_outlined,
    ),
    ProjectEntry(
      title: 'Memory Match',
      description:
          'Card-flip memory games designed for recognition and recall.',
      slug: 'memory-match',
      icon: Icons.style_outlined,
    ),
    ProjectEntry(
      title: 'Reading Writing Kids',
      description:
          'Reading and writing practice presented with calm, friendly structure.',
      slug: 'reading-writing-kids',
      icon: Icons.menu_book_outlined,
    ),
    ProjectEntry(
      title: 'Sight Word Search',
      description:
          'Word-search gameplay built to reinforce sight-word fluency.',
      slug: 'sight-word-search',
      icon: Icons.search_outlined,
    ),
  ];

  Future<void> _openProject(ProjectEntry entry) async {
    final uri = Uri.parse('$_projectBaseUrl/${entry.slug}');
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
                    _Header(
                      projectCount: _projects.length,
                      baseUrl: _projectBaseUrl,
                    ),
                    SizedBox(height: Responsive.spacing(context, 3)),
                    _ProjectSection(projects: _projects, onTap: _openProject),
                    SizedBox(height: Responsive.spacing(context, 3)),
                    const _MissionSection(),
                    SizedBox(height: Responsive.spacing(context, 2.5)),
                    const _ContactSection(email: 'contact@infennonlabs.com'),
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

class ProjectEntry {
  const ProjectEntry({
    required this.title,
    required this.description,
    required this.slug,
    required this.icon,
  });

  final String title;
  final String description;
  final String slug;
  final IconData icon;
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
  const _Header({required this.projectCount, required this.baseUrl});

  final int projectCount;
  final String baseUrl;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 760;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            const _BrandLockup(),
            _InfoChip(label: 'Flutter Web homepage'),
            _InfoChip(label: '$projectCount projects'),
          ],
        ),
        SizedBox(height: Responsive.spacing(context, 2.5)),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Text(
            'Infennon Labs builds playful learning products with crisp, simple navigation.',
            style: TextStyle(
              fontFamily: GoogleFonts.fredoka().fontFamily,
              fontSize: isCompact ? 36 : 54,
              height: 0.98,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.2,
              color: BrandTheme.ink,
            ),
          ),
        ),
        SizedBox(height: Responsive.spacing(context, 1.5)),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 740),
          child: Text(
            'Choose a project below to open the live experience. Each card points directly to its Cloudflare home so the landing page stays lightweight and easy to scan.',
            style: TextStyle(
              fontSize: isCompact ? 17 : 19,
              height: 1.6,
              color: const Color(0xFF445062),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(height: Responsive.spacing(context, 2)),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            _HeroPill(text: 'Simple UI'),
            _HeroPill(text: 'Kids learning'),
            _HeroPill(text: 'Cloudflare links'),
            _HeroPill(text: baseUrl),
          ],
        ),
      ],
    );
  }
}

class _BrandLockup extends StatelessWidget {
  const _BrandLockup();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BrandTheme.lime.withValues(alpha: 0.55)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x2213293A),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[BrandTheme.ocean, BrandTheme.sky],
              ),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Infennon Labs',
                style: TextStyle(
                  fontFamily: GoogleFonts.fredoka().fontFamily,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  letterSpacing: 0.1,
                  color: BrandTheme.ink,
                ),
              ),
              const Text(
                'Playful Learning Studio',
                style: TextStyle(
                  color: Color(0xFF3E566B),
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: BrandTheme.ocean,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD7E2EA)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Color(0xFF334155),
        ),
      ),
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
    final aspectRatio = columns == 1
        ? 0.84
        : columns == 2
        ? 1.14
        : 1.35;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _SectionLabel(
          title: 'Projects',
          subtitle: 'Tap a card to open the live app.',
        ),
        const SizedBox(height: 18),
        GridView.builder(
          itemCount: projects.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: aspectRatio,
          ),
          itemBuilder: (BuildContext context, int index) {
            final entry = projects[index];
            final palette = ModePalettes.byIndex(index);
            return _StaggeredReveal(
              index: index,
              child: _ProjectCard(
                entry: entry,
                palette: palette,
                onTap: () => onTap(entry),
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
  final VoidCallback onTap;

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
            padding: EdgeInsets.all(isCompact ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const Spacer(),
                    Icon(
                      Icons.open_in_new_rounded,
                      color: palette.foreground.withValues(alpha: 0.9),
                      size: isCompact ? 18 : 20,
                    ),
                  ],
                ),
                SizedBox(height: isCompact ? 14 : 18),
                Text(
                  entry.title,
                  style: TextStyle(
                    color: palette.foreground,
                    fontSize: isCompact ? 20 : 24,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                SizedBox(height: isCompact ? 6 : 10),
                Text(
                  entry.description,
                  style: TextStyle(
                    color: palette.foreground.withValues(alpha: 0.92),
                    fontSize: isCompact ? 13.5 : 15.5,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: isCompact ? 10 : 18),
                Text(
                  'infennonlabs.com/${entry.slug}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.foreground.withValues(alpha: 0.92),
                    fontSize: isCompact ? 12.5 : 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MissionSection extends StatelessWidget {
  const _MissionSection();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 860;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: BrandTheme.sky.withValues(alpha: 0.35)),
      ),
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                _SectionLabel(
                  title: 'About',
                  subtitle:
                      'Simple, friendly learning tools with a playful edge.',
                ),
                SizedBox(height: 16),
                _SectionBody(
                  text:
                      'Infennon Labs creates approachable learning experiences that stay focused on clarity, delight, and fast access to the actual project.',
                ),
                SizedBox(height: 24),
                _SectionLabel(
                  title: 'Mission',
                  subtitle: 'Make the homepage feel calm, quick, and useful.',
                ),
                SizedBox(height: 16),
                _SectionBody(
                  text:
                      'This hub is intentionally lightweight: one page, clear project cards, and direct links to the live experiences.',
                ),
              ],
            )
          : const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _SectionLabel(
                        title: 'About',
                        subtitle:
                            'Simple, friendly learning tools with a playful edge.',
                      ),
                      SizedBox(height: 16),
                      _SectionBody(
                        text:
                            'Infennon Labs creates approachable learning experiences that stay focused on clarity, delight, and fast access to the actual project.',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 28),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _SectionLabel(
                        title: 'Mission',
                        subtitle:
                            'Make the homepage feel calm, quick, and useful.',
                      ),
                      SizedBox(height: 16),
                      _SectionBody(
                        text:
                            'This hub is intentionally lightweight: one page, clear project cards, and direct links to the live experiences.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection({required this.email});

  final String email;

  Future<void> _openEmail(String subject) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
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
            subtitle: 'Reach out anytime at contact@infennonlabs.com.',
            titleColor: Colors.white,
            subtitleColor: Color(0xFFD3D9E3),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              _ContactChip(
                icon: Icons.email_outlined,
                label: 'General',
                value: email,
                onTap: () => _openEmail('Infennon Labs Inquiry'),
              ),
              _ContactChip(
                icon: Icons.campaign_outlined,
                label: 'Partnerships',
                value: email,
                onTap: () => _openEmail('Partnership Request'),
              ),
              _ContactChip(
                icon: Icons.support_agent_outlined,
                label: 'Support',
                value: email,
                onTap: () => _openEmail('Support Request'),
              ),
              _ContactChip(
                icon: Icons.lightbulb_outline,
                label: 'Ideas',
                value: email,
                onTap: () => _openEmail('New Project Idea'),
              ),
            ],
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
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFFD4DCEA),
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
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
    required this.subtitle,
    this.titleColor = const Color(0xFF111827),
    this.subtitleColor = const Color(0xFF4B5563),
  });

  final String title;
  final String subtitle;
  final Color titleColor;
  final Color subtitleColor;

  @override
  Widget build(BuildContext context) {
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
    );
  }
}

class _SectionBody extends StatelessWidget {
  const _SectionBody({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF334155),
        fontSize: 16,
        height: 1.65,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
