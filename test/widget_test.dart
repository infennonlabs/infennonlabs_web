import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grade_filter_shared/grade_filter_shared.dart';

import 'package:infennon_labs_home/grade_filter_store.dart';
import 'package:infennon_labs_home/main.dart';
import 'package:infennon_labs_home/project_registry.dart';

void main() {
  setUp(() {
    saveGradeLabel(null);
    saveSubjectLabel(null);
  });

  Future<void> pumpAtSize(WidgetTester tester, {required Size size}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const InfennonLabsApp());
  }

  testWidgets('homepage renders project hub', (WidgetTester tester) async {
    await tester.pumpWidget(const InfennonLabsApp());

    expect(find.text('Learning Games'), findsOneWidget);
    expect(find.text('InfennonLabs'), findsOneWidget);
    expect(
      find.text(
        'Early learning tools for the developing child PreK-5th grades',
      ),
      findsOneWidget,
    );
    expect(find.text('Contact'), findsOneWidget);
    expect(find.text('Alpha Kids'), findsOneWidget);
    expect(find.text('Play Now'), findsWidgets);
  });

  testWidgets('footer links to the published privacy policy and terms', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const InfennonLabsApp());

    expect(
      find.byKey(const Key('home-privacy-policy-link'), skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('home-terms-of-service-link'), skipOffstage: false),
      findsOneWidget,
    );
    expect(find.text('Privacy Policy', skipOffstage: false), findsOneWidget);
    expect(find.text('Terms of Service', skipOffstage: false), findsOneWidget);
  });

  test(
    'home registry marks Math Solitaire as non-live and uses K-3rd label',
    () {
      final mathAdventures = kProjectRegistry.firstWhere(
        (ProjectEntry entry) => entry.id == 'math_adventures_kids',
      );
      expect(mathAdventures.gradeRangeLabel, 'K-3rd');

      final mathSolitaire = kProjectRegistry.firstWhere(
        (ProjectEntry entry) => entry.id == 'math_solitaire_kids',
      );
      expect(mathSolitaire.isPlaceholder, isTrue);
    },
  );

  testWidgets('mobile tiles scale compactly with available width', (
    WidgetTester tester,
  ) async {
    await pumpAtSize(tester, size: const Size(390, 844));

    final grid = tester.widget<GridView>(find.byType(GridView).first);
    final delegate =
        grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

    expect(delegate.crossAxisCount, 1);
    expect(delegate.childAspectRatio, closeTo(1.322, 0.001));
  });

  testWidgets('very narrow mobile keeps a tighter compact aspect ratio', (
    WidgetTester tester,
  ) async {
    await pumpAtSize(tester, size: const Size(360, 800));

    final grid = tester.widget<GridView>(find.byType(GridView).first);
    final delegate =
        grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

    expect(delegate.crossAxisCount, 1);
    expect(delegate.childAspectRatio, closeTo(1.304, 0.001));
  });

  test('aspect ratio scales with width', () {
    expect(projectCardAspectRatioForWidth(320), closeTo(1.28, 0.001));
    expect(projectCardAspectRatioForWidth(390), closeTo(1.322, 0.001));
    expect(projectCardAspectRatioForWidth(520), closeTo(1.40, 0.001));
  });

  test('every live game on the home has a band', () {
    for (final entry in kProjectRegistry.where((e) => !e.isPlaceholder)) {
      expect(entry.band, isNotNull, reason: '${entry.id} has no band');
    }
  });

  testWidgets('games are grouped under the four band headings', (
    WidgetTester tester,
  ) async {
    await pumpAtSize(tester, size: const Size(1200, 6000));

    for (final band in HomeBand.values) {
      expect(find.text(band.label), findsOneWidget);
    }
    expect(find.text('Alpha Kids'), findsOneWidget);
    expect(find.text('Coming Soon'), findsWidgets);
  });

  testWidgets('choosing a grade filters games and hides empty bands', (
    WidgetTester tester,
  ) async {
    await pumpAtSize(tester, size: const Size(1200, 6000));

    await tester.tap(find.byKey(const ValueKey<String>('filter-PreK')));
    await tester.pump();

    expect(find.text('Alpha Kids'), findsOneWidget);
    expect(find.text('Make It'), findsOneWidget);
    // Piano Practice is an "All" game, so it shows under every grade.
    expect(find.text('Piano Practice'), findsOneWidget);
    expect(find.text('Chem Kids'), findsNothing);
    expect(find.text('Clockwork'), findsNothing);
    // No 1st-3rd games remain, so the Big kids band is gone.
    expect(find.text(HomeBand.bigKids.label), findsNothing);
    expect(find.text('Coming Soon'), findsNothing);
    expect(readSavedGradeLabel(), 'PreK');
  });

  testWidgets('5th+ shows the games that reach 5th grade', (
    WidgetTester tester,
  ) async {
    await pumpAtSize(tester, size: const Size(1200, 6000));

    await tester.tap(find.byKey(const ValueKey<String>('filter-5th+')));
    await tester.pump();

    expect(find.text('Chem Kids'), findsOneWidget);
    expect(find.text('Sight Word Search'), findsOneWidget);
    expect(find.text('Alpha Kids'), findsNothing);
  });

  testWidgets('tapping the grade again or Show all clears the filter', (
    WidgetTester tester,
  ) async {
    await pumpAtSize(tester, size: const Size(1200, 6000));
    const chip = ValueKey<String>('filter-K');

    await tester.tap(find.byKey(chip));
    await tester.pump();
    expect(find.text('Chem Kids'), findsNothing);

    await tester.tap(find.byKey(chip));
    await tester.pump();
    expect(find.text('Chem Kids'), findsOneWidget);
    expect(readSavedGradeLabel(), isNull);

    await tester.tap(find.byKey(chip));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey<String>('filter-reset')));
    await tester.pump();
    expect(find.text('Chem Kids'), findsOneWidget);
    expect(readSavedGradeLabel(), isNull);
  });

  testWidgets('a grade chosen earlier in the session is restored', (
    WidgetTester tester,
  ) async {
    saveGradeLabel('2nd');
    await pumpAtSize(tester, size: const Size(1200, 6000));

    expect(find.text('Chem Kids'), findsNothing);
    expect(find.text('Clockwork'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('filter-reset')), findsOneWidget);
  });

  group('subject filter', () {
    Future<void> pickSubject(WidgetTester tester, String label) async {
      await tester.tap(find.byKey(ValueKey<String>('subject-$label')));
      await tester.pump();
    }

    testWidgets('choosing a subject filters games and hides empty bands', (
      WidgetTester tester,
    ) async {
      await pumpAtSize(tester, size: const Size(1200, 6000));

      await pickSubject(tester, 'Science');

      expect(find.text('Earth Lab'), findsOneWidget);
      expect(find.text('Chem Kids'), findsOneWidget);
      expect(find.text('Anatomy Kids'), findsOneWidget);
      expect(find.text('Alpha Kids'), findsNothing);
      expect(find.text('Clockwork'), findsNothing);
      // No Science game sits in Early learners or Growing learners.
      expect(find.text(HomeBand.early.label), findsNothing);
      expect(find.text(HomeBand.growing.label), findsNothing);
      expect(find.text('Coming Soon'), findsNothing);
      expect(readSavedSubjectLabel(), 'Science');
    });

    testWidgets('the Holidays section comes after every grade band', (
      WidgetTester tester,
    ) async {
      await pumpAtSize(tester, size: const Size(1200, 8000));

      final holidays = tester.getTopLeft(find.text('Holidays')).dy;
      for (final band in HomeBand.values) {
        final heading = find.text(band.label);
        if (heading.evaluate().isNotEmpty) {
          expect(tester.getTopLeft(heading).dy, lessThan(holidays));
        }
      }
      // The coming-soon tiles close the last grade band, above Holidays.
      expect(
        tester.getTopLeft(find.text('Coming Soon').first).dy,
        lessThan(holidays),
      );
    });

    testWidgets('holiday games sit in their own section, not in a band', (
      WidgetTester tester,
    ) async {
      await pumpAtSize(tester, size: const Size(1200, 6000));

      expect(find.text('Holidays'), findsOneWidget);
      expect(find.text('Pumpkin Carving'), findsOneWidget);

      await pickSubject(tester, 'Holiday');

      expect(find.text('Pumpkin Carving'), findsOneWidget);
      expect(find.text('Alpha Kids'), findsNothing);
      expect(find.text(HomeBand.everyone.label), findsNothing);
      expect(find.text('Coming Soon'), findsNothing);
    });

    testWidgets('a game with several subjects shows under each of them', (
      WidgetTester tester,
    ) async {
      await pumpAtSize(tester, size: const Size(1200, 6000));

      for (final label in <String>[
        'Life Skills',
        'Read & Write',
        'Math',
      ]) {
        await pickSubject(tester, label);
        expect(find.text('Cooking Kids'), findsOneWidget, reason: label);
      }
      await pickSubject(tester, 'Science');
      expect(find.text('Cooking Kids'), findsNothing);
    });

    testWidgets('subject and grade combine', (WidgetTester tester) async {
      await pumpAtSize(tester, size: const Size(1200, 6000));

      await tester.tap(find.byKey(const ValueKey<String>('filter-PreK')));
      await pickSubject(tester, 'Math');

      expect(find.text('Countin Kids'), findsOneWidget);
      expect(find.text('Memory Match'), findsOneWidget);
      // Math, but not PreK.
      expect(find.text('Slice It'), findsNothing);
      expect(find.text('Math Adventures Kids'), findsNothing);
      // PreK, but not Math.
      expect(find.text('Alpha Kids'), findsNothing);
    });

    testWidgets('chip counts follow the chosen grade', (
      WidgetTester tester,
    ) async {
      await pumpAtSize(tester, size: const Size(1200, 6000));
      Finder chip(String label, int n) => find.descendant(
        of: find.byKey(ValueKey<String>('subject-$label')),
        matching: find.text('$label  $n'),
      );

      expect(chip('Faith & Values', 1), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey<String>('filter-PreK')));
      await tester.pump();
      // Anatomy Kids is the only Science game that reaches PreK.
      expect(chip('Science', 1), findsOneWidget);
    });

    testWidgets('tapping again or Show all clears both filters', (
      WidgetTester tester,
    ) async {
      await pumpAtSize(tester, size: const Size(1200, 6000));

      await pickSubject(tester, 'Math');
      await pickSubject(tester, 'Math');
      expect(find.text('Alpha Kids'), findsOneWidget);
      expect(readSavedSubjectLabel(), isNull);

      await tester.tap(find.byKey(const ValueKey<String>('filter-K')));
      await pickSubject(tester, 'Math');
      await tester.tap(find.byKey(const ValueKey<String>('filter-reset')));
      await tester.pump();
      expect(find.text('Chem Kids'), findsOneWidget);
      expect(readSavedGradeLabel(), isNull);
      expect(readSavedSubjectLabel(), isNull);
    });

    testWidgets('a subject chosen earlier in the session is restored', (
      WidgetTester tester,
    ) async {
      saveSubjectLabel('Faith & Values');
      await pumpAtSize(tester, size: const Size(1200, 6000));

      expect(find.text('Be With God'), findsOneWidget);
      expect(find.text('Alpha Kids'), findsNothing);
      expect(
        find.byKey(const ValueKey<String>('filter-reset')),
        findsOneWidget,
      );
    });

    test('every live game is tagged with at least one subject', () {
      final untagged = <String>[
        for (final entry in kProjectRegistry)
          if (!entry.isPlaceholder && entry.subjects.isEmpty) entry.id,
      ];
      expect(untagged, isEmpty);
    });
  });
}
