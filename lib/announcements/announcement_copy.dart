import 'announcement_item.dart';

/// Every word the home ticker shows, in one place. Game entries use the game's own title;
/// "New game" notes use its card description unless the deploy carried a line.
class AnnouncementCopy {
  static const String stripLabel = "What's new";
  static const String tagNew = 'New';
  static const String tagUpdated = 'Updated';
  static const String tagFeature = 'New feature';
  static const String tagTip = 'Tip';

  static const String pause = 'Pause announcements';
  static const String play = 'Play announcements';
  static const String previous = 'Previous announcement';
  static const String next = 'Next announcement';

  /// Static reminders, always in the feed. Rank 40 puts the Study Plan one ahead of the rest.
  static const List<AnnouncementItem> tips = <AnnouncementItem>[
    AnnouncementItem(
      id: 'tip-study-plan',
      kind: AnnouncementKind.tip,
      title: "Don't forget to set a Study Plan",
      note: 'Pick games and modes for the week',
      target: AnnouncementTarget.studyPlan(),
      priority: 40,
    ),
    AnnouncementItem(
      id: 'tip-hints',
      kind: AnnouncementKind.tip,
      title: 'Hints are there when you get stuck',
      note: 'One clue at a time, no spoilers',
    ),
    AnnouncementItem(
      id: 'tip-grade',
      kind: AnnouncementKind.tip,
      title: 'Pick a grade to see the right games',
      target: AnnouncementTarget.filter(),
    ),
  ];
}
