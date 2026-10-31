/// One mode a parent can pick. [id] is what the game reads from `?mode=`.
class StudyModeInfo {
  const StudyModeInfo({
    required this.id,
    required this.title,
    required this.description,
  });

  final String id;
  final String title;
  final String description;
}

/// What the Study Plan data file says about one game. See
/// `.github/learning/study_plan.json` in the workspace hub; the generated
/// `study_catalog_data.dart` is built from it.
class StudyGameData {
  const StudyGameData({
    required this.ready,
    required this.allModesNote,
    this.modes = const <StudyModeInfo>[],
  });

  /// True once the game reports activity to the Study Plan frame and opens the
  /// modes below from `?mode=`. Only ready games are offered to parents.
  final bool ready;

  /// What "All Modes" means for this game, for the (i) note.
  final String allModesNote;

  /// Empty when the game has no separate modes to pick.
  final List<StudyModeInfo> modes;
}
