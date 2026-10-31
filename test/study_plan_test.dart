import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grade_filter_shared/grade_filter_shared.dart';
import 'package:infennon_labs_home/main.dart';
import 'package:infennon_labs_home/project_registry.dart';
import 'package:infennon_labs_home/study_plan/study_catalog.dart';
import 'package:infennon_labs_home/study_plan/study_catalog_data.dart';
import 'package:infennon_labs_home/study_plan/study_plan_card.dart';
import 'package:infennon_labs_home/study_plan/study_plan_page.dart';
import 'package:infennon_labs_home/study_plan/study_runner_page.dart';
import 'package:study_plan_shared/study_plan_shared.dart';

void main() {
  Future<void> pumpHome(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 6000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const InfennonLabsApp());
  }

  /// Opens the plan page on its own. (The full home is not kept underneath:
  /// its tiles overflow under the test font once time passes, which is true of
  /// the home without this feature too.)
  Future<StudyPlanDraft> openPlanner(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final StudyPlanDraft draft = StudyPlanDraft();
    await tester.pumpWidget(MaterialApp(home: StudyPlanPage(draft: draft)));
    await tester.pump();
    return draft;
  }

  Future<void> tapKey(WidgetTester tester, String key) async {
    final Finder finder = find.byKey(ValueKey<String>(key));
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pump();
  }

  Future<void> leave(WidgetTester tester) =>
      tester.pumpWidget(const SizedBox.shrink());

  group('catalog', () {
    test('offers exactly the games the data file marks ready', () {
      final List<String> offered = studyGames()
          .map((StudyGameInfo g) => g.id)
          .toList();
      final List<String> ready = <String>[
        for (final ProjectEntry e in kProjectRegistry)
          if (!e.isPlaceholder && (kStudyGameData[e.id]?.ready ?? false)) e.id,
      ];
      expect(offered, ready);
      expect(offered, isNotEmpty);
      for (final StudyGameInfo game in studyGames()) {
        expect(game.allModesNote, isNotEmpty);
        for (final StudyModeInfo mode in game.modes) {
          expect(mode.description, isNotEmpty);
        }
      }
    });

    test('a game that is not ready is not offered', () {
      final List<StudyGameInfo> games =
          studyGames(kProjectRegistry, const <String, StudyGameData>{
            'alpha_kids': StudyGameData(ready: false, allModesNote: 'x'),
            'farm_kids': StudyGameData(ready: true, allModesNote: 'y'),
          });
      expect(games.map((StudyGameInfo g) => g.id), <String>['farm_kids']);
    });

    test('mode ids are unique inside each game', () {
      for (final StudyGameInfo game in studyGames()) {
        final List<String> ids = game.modes
            .map((StudyModeInfo m) => m.id)
            .toList();
        expect(ids.toSet().length, ids.length, reason: game.id);
      }
    });

    test('the game url asks for a mode only when one is picked', () {
      final StudyGameInfo piano = studyGames().firstWhere(
        (StudyGameInfo g) => g.id == 'piano_synth_demo',
      );
      expect(
        piano.urlFor(null, baseUrl: 'https://x.test').toString(),
        'https://x.test/piano/',
      );
      expect(
        piano.urlFor('listen', baseUrl: 'https://x.test').toString(),
        'https://x.test/piano/?mode=listen',
      );
    });
  });

  group('Study Plan data', () {
    final Set<String> liveIds = <String>{
      for (final ProjectEntry e in kProjectRegistry)
        if (!e.isPlaceholder) e.id,
    };

    test('every live game on the home has a Study Plan decision', () {
      // Adding a game to the home registry fails here until it is added to
      // .github/learning/study_plan.json (as a game, or under notYet with a
      // reason) and scripts/gen_study_plan_catalog.py is run.
      final Set<String> decided = <String>{
        ...kStudyGameData.keys,
        ...kStudyPlanNotYet.keys,
      };
      expect(liveIds.difference(decided), isEmpty);
    });

    test('the data names no game the home does not have', () {
      final Set<String> allIds = <String>{
        for (final ProjectEntry e in kProjectRegistry) e.id,
      };
      expect(kStudyGameData.keys.toSet().difference(allIds), isEmpty);
      expect(kStudyPlanNotYet.keys.toSet().difference(allIds), isEmpty);
    });

    test('no game is both in Study Plans and left out of them', () {
      expect(
        kStudyGameData.keys.toSet().intersection(kStudyPlanNotYet.keys.toSet()),
        isEmpty,
      );
    });

    test('mode ids are tidy and unique, and no mode is random', () {
      final RegExp kebab = RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$');
      final RegExp random = RegExp(
        'random|progression|surprise|shuffle',
        caseSensitive: false,
      );
      kStudyGameData.forEach((String gameId, StudyGameData game) {
        final List<String> ids = game.modes
            .map((StudyModeInfo m) => m.id)
            .toList();
        expect(
          ids.toSet().length,
          ids.length,
          reason: '$gameId has a repeated id',
        );
        for (final StudyModeInfo mode in game.modes) {
          expect(kebab.hasMatch(mode.id), isTrue, reason: '$gameId ${mode.id}');
          expect(mode.title.trim(), isNotEmpty, reason: '$gameId ${mode.id}');
          expect(
            mode.description.trim(),
            isNotEmpty,
            reason: '$gameId ${mode.id}',
          );
          expect(
            random.hasMatch('${mode.title} ${mode.description}'),
            isFalse,
            reason:
                '$gameId ${mode.id} reads like a random mode; leave it out '
                'and let All Modes cover it',
          );
        }
      });
    });
  });

  group('home card and planner', () {
    testWidgets('the home shows the Study Plan card with its subtitle', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);
      expect(find.text('Prepare Study Plan'), findsOneWidget);
      expect(find.text(kStudyPlanSubtitle), findsOneWidget);
      expect(
        kStudyPlanSubtitle,
        'Custom tailor a plan for your child to focus on their specific needs.',
      );
      await leave(tester);
    });

    testWidgets('the plan page repeats the subtitle and lists the games', (
      WidgetTester tester,
    ) async {
      await openPlanner(tester);
      expect(find.text('Study Plan'), findsOneWidget);
      expect(find.text(kStudyPlanSubtitle), findsOneWidget);
      for (final StudyGameInfo game in studyGames()) {
        expect(find.text(game.title), findsWidgets, reason: game.title);
      }
      // Grade buttons appear only once a game with a grade range is on offer.
      final bool hasGradedGame = studyGames().any(
        (StudyGameInfo g) =>
            GradeSpan.parse(g.entry.gradeRangeLabel ?? 'All') != null,
      );
      expect(
        find.byKey(const ValueKey<String>('study-grade-K')),
        hasGradedGame ? findsOneWidget : findsNothing,
      );
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(const ValueKey<String>('study-start')),
            )
            .onPressed,
        isNull,
      );
      await leave(tester);
    });

    testWidgets(
      'All Modes adds the game, shows what it means, and a single mode replaces it',
      (WidgetTester tester) async {
        await openPlanner(tester);

        await tapKey(tester, 'all-modes-piano_synth_demo');
        expect(
          find.byKey(const ValueKey<String>('tray-piano_synth_demo-all')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey<String>('study-explanation')),
          findsOneWidget,
        );
        expect(find.textContaining('every piano activity'), findsOneWidget);

        await tapKey(tester, 'mode-piano_synth_demo-listen');
        expect(
          find.byKey(const ValueKey<String>('tray-piano_synth_demo-all')),
          findsNothing,
        );
        expect(
          find.byKey(const ValueKey<String>('tray-piano_synth_demo-listen')),
          findsOneWidget,
        );
        expect(find.textContaining('Hear a short song'), findsOneWidget);

        // Tapping the same mode again removes it.
        await tapKey(tester, 'mode-piano_synth_demo-listen');
        expect(
          find.byKey(const ValueKey<String>('tray-piano_synth_demo-listen')),
          findsNothing,
        );
        await leave(tester);
      },
    );

    testWidgets('modes from different games can be mixed', (
      WidgetTester tester,
    ) async {
      await openPlanner(tester);
      await tapKey(tester, 'mode-paint_by_number-free');
      await tapKey(tester, 'mode-cooking_kids-spell');
      await tapKey(tester, 'all-modes-farm_kids');
      expect(find.byType(InputChip), findsNWidgets(3));
      await leave(tester);
    });

    testWidgets('a tight total shows a suggestion that one tap applies', (
      WidgetTester tester,
    ) async {
      await openPlanner(tester);
      await tapKey(tester, 'all-modes-piano_synth_demo');
      await tapKey(tester, 'study-minutes-5');
      expect(
        find.byKey(const ValueKey<String>('study-suggestion')),
        findsOneWidget,
      );
      expect(find.textContaining('We suggest 10 min'), findsOneWidget);

      await tapKey(tester, 'study-use-suggestion');
      expect(
        find.byKey(const ValueKey<String>('study-suggestion')),
        findsNothing,
      );
      expect(
        tester
            .widget<ChoiceChip>(
              find.byKey(const ValueKey<String>('study-minutes-10')),
            )
            .selected,
        isTrue,
      );
      await leave(tester);
    });

    testWidgets('a roomy total shows no suggestion', (
      WidgetTester tester,
    ) async {
      await openPlanner(tester);
      await tapKey(tester, 'all-modes-farm_kids');
      expect(
        find.byKey(const ValueKey<String>('study-suggestion')),
        findsNothing,
      );
      await leave(tester);
    });

    testWidgets(
      'the card becomes Edit plan and Start once something is picked',
      (WidgetTester tester) async {
        final StudyPlanDraft draft = StudyPlanDraft();
        var prepared = 0;
        var started = 0;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StudyPlanCard(
                draft: draft,
                onPrepare: () => prepared++,
                onStart: () => started++,
              ),
            ),
          ),
        );
        expect(find.text('Prepare Study Plan'), findsOneWidget);
        expect(
          find.byKey(const ValueKey<String>('study-card-start')),
          findsNothing,
        );

        draft.toggleAllModes('farm_kids');
        await tester.pump();
        expect(find.text('Your Study Plan'), findsOneWidget);
        expect(find.text('1 item · 10 min total'), findsOneWidget);
        expect(find.text('Edit plan'), findsOneWidget);

        await tester.tap(
          find.byKey(const ValueKey<String>('study-card-start')),
        );
        await tester.tap(find.byKey(const ValueKey<String>('study-prepare')));
        expect(started, 1);
        expect(prepared, 1);
        await leave(tester);
      },
    );

    testWidgets(
      'the home grade filter carries over once a graded game is offered',
      (WidgetTester tester) async {
        final List<StudyGameInfo> games = studyGames();
        final StudyPlanDraft draft = StudyPlanDraft();
        await tester.pumpWidget(
          MaterialApp(
            home: StudyPlanPage(
              draft: draft,
              initialGrade: GradeFilter.kindergarten,
              games: games,
            ),
          ),
        );
        await tester.pump();
        // Grade chips appear, K is carried over, and Chem Kids (5th) is hidden.
        expect(
          tester
              .widget<ChoiceChip>(
                find.byKey(const ValueKey<String>('study-grade-K')),
              )
              .selected,
          isTrue,
        );
        expect(find.text('Chem Kids'), findsNothing);
        expect(find.text('Farm Kids'), findsOneWidget);

        await tester.tap(
          find.byKey(const ValueKey<String>('study-grade-5th+')),
        );
        await tester.pump();
        expect(find.text('Chem Kids'), findsOneWidget);
        await leave(tester);
      },
    );
  });

  group('runner', () {
    final List<StudyGameInfo> games = studyGames();
    const List<StudyPlanItem> items = <StudyPlanItem>[
      StudyPlanItem(gameId: 'piano_synth_demo', modeId: 'listen'),
      StudyPlanItem(gameId: 'farm_kids'),
    ];

    Future<void> pumpRunner(
      WidgetTester tester, {
      int minutes = 2,
      VoidCallback? onFinished,
      int idleAfter = 20,
    }) async {
      tester.view.physicalSize = const Size(1000, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute<void>(
              builder: (_) => StudyRunnerPage(
                items: items,
                totalMinutes: minutes,
                games: games,
                onFinished: onFinished ?? () {},
                idleAfterSeconds: idleAfter,
              ),
            ),
          ),
        ),
      );
    }

    String clock(WidgetTester tester) => tester
        .widget<Text>(find.byKey(const ValueKey<String>('study-clock')))
        .data!;

    testWidgets('does not count down until the first tap in the game', (
      WidgetTester tester,
    ) async {
      await pumpRunner(tester);
      expect(clock(tester), '2:00');
      expect(
        find.byKey(const ValueKey<String>('study-ready-hint')),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 30));
      expect(clock(tester), '2:00');

      await tester.tap(find.byKey(const ValueKey<String>('study-frame')));
      await tester.pump();
      expect(
        find.byKey(const ValueKey<String>('study-ready-hint')),
        findsNothing,
      );
      await tester.pump(const Duration(seconds: 5));
      expect(clock(tester), '1:55');
      await leave(tester);
    });

    testWidgets('the game is asked to open in the picked mode', (
      WidgetTester tester,
    ) async {
      await pumpRunner(tester);
      expect(find.textContaining('/piano/?mode=listen'), findsOneWidget);
      await leave(tester);
    });

    testWidgets(
      'going quiet pauses the clock and asks if the child is still playing',
      (WidgetTester tester) async {
        await pumpRunner(tester, minutes: 5);
        await tester.tap(find.byKey(const ValueKey<String>('study-frame')));
        await tester.pump();
        await tester.pump(const Duration(seconds: 25));
        expect(find.text('Still playing?'), findsOneWidget);
        final String paused = clock(tester);
        await tester.pump(const Duration(seconds: 10));
        expect(clock(tester), paused);

        await tester.tap(find.byKey(const ValueKey<String>('study-resume')));
        await tester.pump();
        expect(find.text('Still playing?'), findsNothing);
        await tester.pump(const Duration(seconds: 3));
        expect(clock(tester), isNot(paused));
        await leave(tester);
      },
    );

    testWidgets(
      'the game\'s Back to Home returns to a menu of the plan items',
      (WidgetTester tester) async {
        await pumpRunner(tester);
        await tester.tap(
          find.byKey(const ValueKey<String>('study-frame-exit')),
        );
        await tester.pump();
        expect(find.text('What next?'), findsOneWidget);

        await tester.tap(find.byKey(const ValueKey<String>('study-menu-1')));
        await tester.pump();
        expect(find.text('What next?'), findsNothing);
        expect(find.textContaining('Game: '), findsOneWidget);
        // Picking from the menu does not start the clock by itself.
        expect(clock(tester), '2:00');
        await leave(tester);
      },
    );

    testWidgets('using all the time finishes with a summary and goes home', (
      WidgetTester tester,
    ) async {
      var finished = false;
      await pumpRunner(
        tester,
        minutes: 2,
        idleAfter: 1000,
        onFinished: () => finished = true,
      );
      await tester.tap(find.byKey(const ValueKey<String>('study-frame')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 120));
      expect(find.text('Great work!'), findsOneWidget);
      expect(find.textContaining('2:00'), findsWidgets);

      await tester.tap(find.byKey(const ValueKey<String>('study-done')));
      await tester.pump();
      expect(finished, isTrue);
      await leave(tester);
    });

    testWidgets('Done with this one ticks the item off and moves to the next', (
      WidgetTester tester,
    ) async {
      await pumpRunner(tester, idleAfter: 1000);
      expect(find.textContaining('/piano/?mode=listen'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey<String>('study-item-done')));
      await tester.pump();
      expect(find.textContaining('/farming/'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey<String>('study-tab-0')),
          matching: find.byIcon(Icons.check_circle),
        ),
        findsOneWidget,
      );
      // Marking done does not start the clock by itself.
      expect(clock(tester), '2:00');
      await leave(tester);
    });

    testWidgets('finishing every item ends the plan with a congratulation', (
      WidgetTester tester,
    ) async {
      await pumpRunner(tester, idleAfter: 1000);
      await tester.tap(find.byKey(const ValueKey<String>('study-frame')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 7));

      await tester.tap(find.byKey(const ValueKey<String>('study-item-done')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey<String>('study-item-done')));
      await tester.pump();

      expect(find.text('Great work!'), findsOneWidget);
      expect(
        find.textContaining('You finished everything in your plan.'),
        findsOneWidget,
      );
      expect(
        find.textContaining('✓ Piano Practice: Listen: 0:07'),
        findsOneWidget,
      );
      await leave(tester);
    });

    testWidgets(
      'a plan ended before the timer started says no time was counted',
      (WidgetTester tester) async {
        await pumpRunner(tester);
        await tester.tap(find.byKey(const ValueKey<String>('study-end')));
        await tester.pump();
        expect(find.text('Study Plan ended'), findsOneWidget);
        expect(
          find.textContaining(
            'The timer never started, so no practice time was counted.',
          ),
          findsOneWidget,
        );
        await leave(tester);
      },
    );

    testWidgets('ending early shows what was practiced', (
      WidgetTester tester,
    ) async {
      await pumpRunner(tester, idleAfter: 1000);
      await tester.tap(find.byKey(const ValueKey<String>('study-frame')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 10));
      await tester.tap(find.byKey(const ValueKey<String>('study-end')));
      await tester.pump();
      expect(find.text('Study Plan ended'), findsOneWidget);
      expect(
        find.textContaining('Piano Practice: Listen: 0:10'),
        findsOneWidget,
      );
      await leave(tester);
    });
  });
}
