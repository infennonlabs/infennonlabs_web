import '../project_registry.dart';

/// Where the games run when a Study Plan embeds them. Local testing points
/// this at a local server with `--dart-define=STUDY_PLAN_GAME_BASE_URL=...`.
const String kStudyPlanGameBaseUrl = String.fromEnvironment(
  'STUDY_PLAN_GAME_BASE_URL',
  defaultValue: 'https://infennonlabs.com',
);

/// The text under the Study Plan title, on the home card and on the plan page.
const String kStudyPlanSubtitle =
    'Custom tailor a plan for your child to focus on their specific needs.';

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

class _Data {
  const _Data(this.allModesNote, [this.modes = const <StudyModeInfo>[]]);

  final String allModesNote;
  final List<StudyModeInfo> modes;
}

/// The games open to Study Plans so far: the games with grade "All". The mode
/// ids match what each game accepts in `?mode=`.
const Map<String, _Data> _kData = <String, _Data>{
  'pumpkin_carver': _Data(
    'Your child can carve any way they like, with stencils or by drawing.',
    <StudyModeInfo>[
      StudyModeInfo(
        id: 'stencil',
        title: 'Stencil',
        description: 'Carve along a ready-made shape, like a face or a star.',
      ),
      StudyModeInfo(
        id: 'free-draw',
        title: 'Free draw',
        description:
            'Draw their own cuts with a loop or a slice, then light the pumpkin up.',
      ),
    ],
  ),
  'piano_synth_demo': _Data(
    'Your child can use every piano activity.',
    <StudyModeInfo>[
      StudyModeInfo(
        id: 'free-play',
        title: 'Free play',
        description: 'Play any keys with no goal. Good for exploring sounds.',
      ),
      StudyModeInfo(
        id: 'listen',
        title: 'Listen',
        description:
            'Hear a short song, then listen to it again. No playing required.',
      ),
      StudyModeInfo(
        id: 'play-along',
        title: 'Play along',
        description: 'Follow a song and press the keys as they light up.',
      ),
      StudyModeInfo(
        id: 'chord',
        title: 'Play this chord',
        description: 'Shown a chord, find and play its notes.',
      ),
      StudyModeInfo(
        id: 'connection',
        title: 'Connection mode',
        description: 'Match music symbols (notes and rests) to their names.',
      ),
    ],
  ),
  'cooking_kids': _Data('Your child can use every cooking activity.', <
    StudyModeInfo
  >[
    StudyModeInfo(
      id: 'mix-it',
      title: 'Mix-It Bowl',
      description: 'Drop ingredients into the bowl and see what they cook.',
    ),
    StudyModeInfo(
      id: 'word-search',
      title: 'Pantry Word Search',
      description:
          'Find ingredient words hidden in a grid. Practices reading and spelling.',
    ),
    StudyModeInfo(
      id: 'recipe-cards',
      title: 'Recipe Cards',
      description: 'Read recipe steps and sort or put them in order.',
    ),
    StudyModeInfo(
      id: 'spell',
      title: 'Spell the Ingredient',
      description: 'See an ingredient and write its name.',
    ),
    StudyModeInfo(
      id: 'measure',
      title: 'Measure & Scale',
      description:
          'Count and measure ingredients, and double or halve a recipe.',
    ),
  ]),
  'paint_by_number': _Data('Your child can use both painting styles.', <
    StudyModeInfo
  >[
    StudyModeInfo(
      id: 'guided',
      title: 'Paint by Number',
      description:
          'Match the numbers to the colors. Only the right color fits each space.',
    ),
    StudyModeInfo(
      id: 'free',
      title: 'Free Paint',
      description:
          'Use any colors they like on any space, with an eraser and custom colors.',
    ),
  ]),
  'anatomy_kids': _Data('Your child explores the body from skin to skeleton.'),
  'farm_kids': _Data('Your child runs the whole farm.'),
  'comic_kids': _Data('Your child creates comics.'),
  'arcade_lab': _Data('Your child can play any of the arcade games.'),
};

/// The games a parent can add to a Study Plan, in home-page order.
List<StudyGameInfo> studyGames([
  List<ProjectEntry> registry = kProjectRegistry,
]) {
  return <StudyGameInfo>[
    for (final ProjectEntry entry in registry)
      if (!entry.isPlaceholder && _kData.containsKey(entry.id))
        StudyGameInfo(
          entry: entry,
          allModesNote: _kData[entry.id]!.allModesNote,
          modes: _kData[entry.id]!.modes,
        ),
  ];
}
