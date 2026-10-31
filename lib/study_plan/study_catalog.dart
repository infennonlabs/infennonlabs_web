import 'package:grade_filter_shared/grade_filter_shared.dart' show HomeBand;
import '../project_registry.dart';
import 'study_catalog_data.dart';
import 'study_game_data.dart';

export 'study_game_data.dart';

/// Where the games run when a Study Plan embeds them. Local testing points
/// this at a local server with `--dart-define=STUDY_PLAN_GAME_BASE_URL=...`.
const String kStudyPlanGameBaseUrl = String.fromEnvironment(
  'STUDY_PLAN_GAME_BASE_URL',
  defaultValue: 'https://infennonlabs.com',
);

/// The text under the Study Plan title, on the home card and on the plan page.
const String kStudyPlanSubtitle =
    'Custom tailor a plan for your child to focus on their specific needs.';

/// A game in the Study Plan picker: its home tile plus the modes a parent can
/// choose and the explanations shown for them.
class StudyGameInfo {
  const StudyGameInfo({
    required this.entry,
    required this.allModesNote,
    this.modes = const <StudyModeInfo>[],
  });

  final ProjectEntry entry;

  /// What "All Modes" means for this game, for the (i) note.
  final String allModesNote;

  /// Empty when the game has no separate modes to pick.
  final List<StudyModeInfo> modes;

  String get id => entry.id;
  String get title => entry.title;

  StudyModeInfo? modeById(String id) {
    for (final StudyModeInfo mode in modes) {
      if (mode.id == id) return mode;
    }
    return null;
  }

  /// The page to embed: the game's own page, asking for [modeId] if given.
  Uri urlFor(String? modeId, {String baseUrl = kStudyPlanGameBaseUrl}) {
    final Uri base = Uri.parse(entry.launchUrl ?? '$baseUrl/${entry.slug}/');
    if (modeId == null) return base;
    return base.replace(
      queryParameters: <String, String>{
        ...base.queryParameters,
        'mode': modeId,
      },
    );
  }
}

/// The games a parent can add to a Study Plan, in home-page order (band, then
/// age order): the games the data file marks `ready`.
List<StudyGameInfo> studyGames([
  List<ProjectEntry> registry = kProjectRegistry,
  Map<String, StudyGameData> data = kStudyGameData,
]) {
  final List<ProjectEntry> ordered = <ProjectEntry>[
    for (final ProjectEntry entry in registry)
      if (!entry.isPlaceholder && (data[entry.id]?.ready ?? false)) entry,
  ]..sort(_homeOrder);
  return <StudyGameInfo>[
    for (final ProjectEntry entry in ordered)
      StudyGameInfo(
        entry: entry,
        allModesNote: data[entry.id]!.allModesNote,
        modes: data[entry.id]!.modes,
      ),
  ];
}

/// The home page's order: bands in declared order, then `ageOrder` inside a band.
int _homeOrder(ProjectEntry a, ProjectEntry b) {
  final int band = (a.band ?? HomeBand.everyone).index.compareTo(
    (b.band ?? HomeBand.everyone).index,
  );
  return band != 0 ? band : (a.ageOrder ?? 999).compareTo(b.ageOrder ?? 999);
}
