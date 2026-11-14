/// What a ticker entry is. Declaration order is the default rank order.
enum AnnouncementKind { feature, newGame, update, tip }

enum AnnouncementTargetType { studyPlan, filter, game }

/// Where a click on an entry goes on the home page. Null target: not clickable.
class AnnouncementTarget {
  const AnnouncementTarget.studyPlan()
    : type = AnnouncementTargetType.studyPlan,
      gameId = null;
  const AnnouncementTarget.filter()
    : type = AnnouncementTargetType.filter,
      gameId = null;
  const AnnouncementTarget.game(String this.gameId)
    : type = AnnouncementTargetType.game;

  final AnnouncementTargetType type;
  final String? gameId;

  /// 'studyPlan', 'filter' or 'game:' plus an id (the form used in announcements.json); else null.
  static AnnouncementTarget? parse(Object? raw) {
    if (raw is! String) return null;
    if (raw == 'studyPlan') return const AnnouncementTarget.studyPlan();
    if (raw == 'filter') return const AnnouncementTarget.filter();
    if (raw.startsWith('game:') && raw.length > 5) {
      return AnnouncementTarget.game(raw.substring(5));
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is AnnouncementTarget &&
      other.type == type &&
      other.gameId == gameId;

  @override
  int get hashCode => Object.hash(type, gameId);
}

class AnnouncementItem {
  const AnnouncementItem({
    required this.id,
    required this.kind,
    required this.title,
    this.note = '',
    this.target,
    this.priority,
    this.expiresAt,
  });

  final String id;
  final AnnouncementKind kind;
  final String title;
  final String note;
  final AnnouncementTarget? target;

  /// Lower shows first. Null uses the default for [kind].
  final int? priority;

  /// When the entry stops showing; null for entries that never expire.
  final DateTime? expiresAt;

  /// Pins 1-9 jump the queue; otherwise the kind decides.
  int get rank => priority ?? _baseRank[kind]!;

  static const Map<AnnouncementKind, int> _baseRank = <AnnouncementKind, int>{
    AnnouncementKind.feature: 10,
    AnnouncementKind.newGame: 20,
    AnnouncementKind.update: 30,
    AnnouncementKind.tip: 90,
  };
}
