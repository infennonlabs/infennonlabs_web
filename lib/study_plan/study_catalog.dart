import 'package:flutter/widgets.dart';
import 'package:grade_filter_shared/grade_filter_shared.dart' show HomeBand;
import 'package:study_plan_shared/study_plan_shared.dart';

import '../project_registry.dart';
import 'study_frame.dart';

/// Where the games run when a Study Plan embeds them. Local testing points
/// this at a local server with `--dart-define=STUDY_PLAN_GAME_BASE_URL=...`.
const String kStudyPlanGameBaseUrl = String.fromEnvironment(
  'STUDY_PLAN_GAME_BASE_URL',
  defaultValue: 'https://infennonlabs.com',
);

/// The page to embed for [game]: the game's own page, asking for [modeId] if
/// given.
Uri studyGameUrl(
  StudyGameInfo game,
  String? modeId, {
  List<ProjectEntry> registry = kProjectRegistry,
  String baseUrl = kStudyPlanGameBaseUrl,
}) {
  final ProjectEntry entry = registry.firstWhere(
    (ProjectEntry e) => e.id == game.id,
  );
  final Uri base = Uri.parse(entry.launchUrl ?? '$baseUrl/${entry.slug}/');
  if (modeId == null) return base;
  return base.replace(
    queryParameters: <String, String>{...base.queryParameters, 'mode': modeId},
  );
}

/// Runs a plan item in a frame on the page. Pass it to the Study Plan screens.
Widget studyFrameBuilder(
  BuildContext context,
  StudyGameInfo game,
  String? modeId,
  VoidCallback onActivity,
  VoidCallback onExit,
) => StudyFrame(
  url: studyGameUrl(game, modeId),
  onActivity: onActivity,
  onExit: onExit,
);

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
        id: entry.id,
        title: entry.title,
        description: entry.description,
        icon: entry.icon,
        gradeRangeLabel: entry.gradeRangeLabel,
        subjects: entry.subjects,
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
