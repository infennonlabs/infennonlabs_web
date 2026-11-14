import '../project_registry.dart';
import 'announcement_copy.dart';
import 'announcement_item.dart';

/// A game shows as NEW this long after its first deploy.
const Duration kNewWindow = Duration(hours: 72);

/// A game shows as UPDATED this long after a deploy that carried an announcement.
const Duration kUpdateWindow = Duration(hours: 48);

/// UPDATED pills are off for now. The deploy still records announcement lines, so turning
/// this on later needs no hub change.
const bool kShowUpdatedGames = false;

/// Most entries the ticker carries, so one loop stays short.
const int kMaxAnnouncements = 8;

/// Where the deploy's announcements-feed.json lives for a page at [base]: the GitHub Pages
/// test host serves everything under /learning-play/, the real site from the root.
String announcementFeedPath(Uri base) {
  final onTestHost = base.path.startsWith('/learning-play/');
  return '${onTestHost ? '/learning-play' : ''}/announcements-feed.json';
}

DateTime? _time(Object? raw) =>
    raw is String ? DateTime.tryParse(raw)?.toUtc() : null;

/// The ordered entries for [now]: games from [feed] inside their windows, the hand-written
/// pins inside theirs, and [tips]. [feed] is the decoded announcements-feed.json, or null
/// when it could not be fetched (tips only). Never throws on a malformed feed.
List<AnnouncementItem> buildAnnouncements({
  required Map<String, dynamic>? feed,
  required DateTime now,
  required List<ProjectEntry> projects,
  List<AnnouncementItem> tips = AnnouncementCopy.tips,
  bool showUpdates = kShowUpdatedGames,
}) {
  final today = now.toUtc();
  final live = <String, ProjectEntry>{
    for (final p in projects)
      if (!p.isPlaceholder) p.id: p,
  };
  final items = <AnnouncementItem>[];

  final games = feed?['games'];
  if (games is Map) {
    for (final MapEntry<dynamic, dynamic> e in games.entries) {
      final entry = live[e.key];
      final data = e.value;
      if (entry == null || data is! Map) continue;
      final first = _time(data['firstDeployedAt']);
      final note = data['announcement'] is Map
          ? (data['announcement']['text'] as Object?)
          : null;
      final noteText = note is String && note.trim().isNotEmpty
          ? note.trim()
          : null;
      if (first != null && today.isBefore(first.add(kNewWindow))) {
        items.add(
          AnnouncementItem(
            id: 'new-${entry.id}',
            kind: AnnouncementKind.newGame,
            title: entry.title,
            note: noteText ?? entry.description,
            target: AnnouncementTarget.game(entry.id),
            expiresAt: first.add(kNewWindow),
          ),
        );
        continue;
      }
      final at = data['announcement'] is Map
          ? _time(data['announcement']['at'])
          : null;
      if (showUpdates &&
          noteText != null &&
          at != null &&
          today.isBefore(at.add(kUpdateWindow))) {
        items.add(
          AnnouncementItem(
            id: 'update-${entry.id}',
            kind: AnnouncementKind.update,
            title: entry.title,
            note: noteText,
            target: AnnouncementTarget.game(entry.id),
            expiresAt: at.add(kUpdateWindow),
          ),
        );
      }
    }
  }

  final pins = feed?['pins'];
  if (pins is List) {
    for (final pin in pins) {
      if (pin is! Map) continue;
      final id = pin['id'];
      final text = pin['text'];
      final ends = _time(pin['endsAt']);
      final starts = _time(pin['startsAt']);
      if (id is! String || text is! String || text.isEmpty || ends == null) {
        continue;
      }
      if (!today.isBefore(ends) || (starts != null && today.isBefore(starts))) {
        continue;
      }
      final target = AnnouncementTarget.parse(pin['target']);
      if (target?.type == AnnouncementTargetType.game &&
          !live.containsKey(target!.gameId)) {
        continue;
      }
      final priority = pin['priority'];
      items.add(
        AnnouncementItem(
          id: 'pin-$id',
          kind: AnnouncementKind.feature,
          title: text,
          note: pin['note'] is String ? pin['note'] as String : '',
          target: target,
          priority: priority is int && priority >= 1 && priority <= 9
              ? priority
              : null,
          expiresAt: ends,
        ),
      );
    }
  }

  items.addAll(tips);

  // Rank first; ties go to whichever expires soonest so it still gets seen, then to the
  // order the entries were added (tips keep the order of AnnouncementCopy.tips).
  final far = DateTime.utc(9999);
  final added = <AnnouncementItem, int>{
    for (var i = 0; i < items.length; i++) items[i]: i,
  };
  items.sort((a, b) {
    final byRank = a.rank.compareTo(b.rank);
    if (byRank != 0) return byRank;
    final byExpiry = (a.expiresAt ?? far).compareTo(b.expiresAt ?? far);
    return byExpiry != 0 ? byExpiry : added[a]!.compareTo(added[b]!);
  });
  return items.take(kMaxAnnouncements).toList();
}
