import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../brand_theme.dart';
import 'announcement_copy.dart';
import 'announcement_item.dart';

/// How fast the band scrolls, in logical pixels per second.
const double kTickerSpeed = 40;

/// How long the carousel (reduced motion) stays on one entry.
const Duration kCarouselDwell = Duration(seconds: 6);

const double _stripHeight = 56;

/// The "What's new" strip: entries scroll past like a ticker tape, or, when the system asks
/// for reduced motion, show one at a time with arrows. It pauses on hover, on keyboard focus
/// and from its own button.
class AnnouncementTicker extends StatefulWidget {
  const AnnouncementTicker({
    super.key,
    required this.items,
    required this.onSelect,
    this.speed = kTickerSpeed,
  });

  final List<AnnouncementItem> items;
  final ValueChanged<AnnouncementTarget> onSelect;
  final double speed;

  @override
  State<AnnouncementTicker> createState() => _AnnouncementTickerState();
}

class _AnnouncementTickerState extends State<AnnouncementTicker>
    with SingleTickerProviderStateMixin {
  final ScrollController _scroll = ScrollController();
  late final Ticker _ticker = createTicker(_onTick);
  Duration _last = Duration.zero;
  Timer? _dwell;
  bool _userPaused = false;
  bool _hovered = false;
  bool _focused = false;
  bool _carousel = false;
  int _index = 0;

  bool get _paused => _userPaused || _hovered || _focused;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.disableAnimationsOf(context);
    if (reduced != _carousel || (!_ticker.isActive && !reduced)) {
      _carousel = reduced;
      _restart();
    }
  }

  @override
  void didUpdateWidget(AnnouncementTicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_index >= widget.items.length) _index = 0;
  }

  @override
  void dispose() {
    _dwell?.cancel();
    _ticker.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _restart() {
    _ticker.stop();
    _dwell?.cancel();
    _last = Duration.zero;
    if (_carousel) {
      _dwell = Timer.periodic(kCarouselDwell, (_) {
        if (!_paused && mounted) _step(1);
      });
    } else {
      _ticker.start();
    }
  }

  void _onTick(Duration elapsed) {
    final dt =
        (elapsed - _last).inMicroseconds / Duration.microsecondsPerSecond;
    _last = elapsed;
    if (_paused || !_scroll.hasClients) return;
    _scroll.jumpTo(_scroll.offset + dt * widget.speed);
  }

  void _step(int by) {
    final n = widget.items.length;
    if (n == 0) return;
    setState(() => _index = (_index + by + n) % n);
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    if (items.isEmpty) return const SizedBox.shrink();
    return Semantics(
      container: true,
      label: AnnouncementCopy.stripLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: BrandTheme.ocean.withValues(alpha: 0.15)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: BrandTheme.ink.withValues(alpha: 0.10),
              blurRadius: 26,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: _stripHeight,
            child: Row(
              children: <Widget>[
                const _Label(),
                Expanded(
                  child: MouseRegion(
                    onEnter: (_) => setState(() => _hovered = true),
                    onExit: (_) => setState(() => _hovered = false),
                    child: Focus(
                      canRequestFocus: false,
                      skipTraversal: true,
                      onFocusChange: (bool focused) =>
                          setState(() => _focused = focused),
                      child: _carousel
                          ? _buildCarousel(items)
                          : _buildBand(items),
                    ),
                  ),
                ),
                if (_carousel) ...<Widget>[
                  _StripButton(
                    icon: Icons.chevron_left,
                    label: AnnouncementCopy.previous,
                    onPressed: () => _step(-1),
                  ),
                  _StripButton(
                    icon: Icons.chevron_right,
                    label: AnnouncementCopy.next,
                    onPressed: () => _step(1),
                  ),
                ],
                _StripButton(
                  icon: _userPaused ? Icons.play_arrow : Icons.pause,
                  label: _userPaused
                      ? AnnouncementCopy.play
                      : AnnouncementCopy.pause,
                  onPressed: () => setState(() => _userPaused = !_userPaused),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBand(List<AnnouncementItem> items) {
    return ListView.builder(
      controller: _scroll,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemBuilder: (BuildContext context, int i) => Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Center(
          child: _Pill(
            item: items[i % items.length],
            onSelect: widget.onSelect,
          ),
        ),
      ),
    );
  }

  Widget _buildCarousel(List<AnnouncementItem> items) {
    final item = items[_index % items.length];
    return Row(
      children: <Widget>[
        Expanded(
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              // Scales down rather than overflowing in a narrow window.
              child: FittedBox(
                key: ValueKey<String>(item.id),
                fit: BoxFit.scaleDown,
                child: _Pill(item: item, onSelect: widget.onSelect),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '${(_index % items.length) + 1} of ${items.length}',
            style: const TextStyle(
              color: Color(0xFF445062),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: BrandTheme.ocean,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            AnnouncementCopy.stripLabel.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _StripButton extends StatelessWidget {
  const _StripButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: Color(0xFFE3EAF0))),
      ),
      child: IconButton(
        icon: Icon(icon, color: BrandTheme.ocean),
        tooltip: label,
        onPressed: onPressed,
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      ),
    );
  }
}

class _Style {
  const _Style(this.tag, this.background, this.border, this.tagColor);
  final String tag;
  final Color background;
  final Color border;
  final Color tagColor;
}

const Map<AnnouncementKind, _Style> _styles = <AnnouncementKind, _Style>{
  AnnouncementKind.newGame: _Style(
    AnnouncementCopy.tagNew,
    Color(0xFFEEFADF),
    BrandTheme.lime,
    BrandTheme.lime,
  ),
  AnnouncementKind.update: _Style(
    AnnouncementCopy.tagUpdated,
    Color(0xFFE3F4FD),
    BrandTheme.sky,
    BrandTheme.sky,
  ),
  AnnouncementKind.feature: _Style(
    AnnouncementCopy.tagFeature,
    Color(0xFFFFF1E1),
    BrandTheme.peach,
    BrandTheme.peach,
  ),
  AnnouncementKind.tip: _Style(
    AnnouncementCopy.tagTip,
    Color(0xFFF2F5F8),
    Color(0xFFD3DCE5),
    Color(0xFFD3DCE5),
  ),
};

class _Pill extends StatelessWidget {
  const _Pill({required this.item, required this.onSelect});

  final AnnouncementItem item;
  final ValueChanged<AnnouncementTarget> onSelect;

  @override
  Widget build(BuildContext context) {
    final style = _styles[item.kind]!;
    final target = item.target;
    final spoken = <String>[
      style.tag,
      item.title,
      if (item.note.isNotEmpty) item.note,
    ].join(', ');
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              color: style.tagColor,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              child: Text(
                style.tag.toUpperCase(),
                style: const TextStyle(
                  color: BrandTheme.ink,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            item.title,
            style: const TextStyle(
              color: BrandTheme.ink,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (item.note.isNotEmpty) ...<Widget>[
            const SizedBox(width: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Text(
                item.note,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF445062),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          if (target != null) ...<Widget>[
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: BrandTheme.ocean, size: 20),
          ],
        ],
      ),
    );
    return Semantics(
      button: target != null,
      label: spoken,
      excludeSemantics: true,
      child: Material(
        color: style.background,
        shape: StadiumBorder(side: BorderSide(color: style.border, width: 2)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: target == null ? null : () => onSelect(target),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: content,
          ),
        ),
      ),
    );
  }
}
