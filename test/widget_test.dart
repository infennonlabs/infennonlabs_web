import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:infennon_labs_home/main.dart';
import 'package:infennon_labs_home/project_registry.dart';

void main() {
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

  test('home registry marks Math Solitaire as non-live and uses K-1st label', () {
    final mathAdventures = kProjectRegistry.firstWhere(
      (ProjectEntry entry) => entry.id == 'math_adventures_kids',
    );
    expect(mathAdventures.gradeRangeLabel, 'K-1st');

    final mathSolitaire = kProjectRegistry.firstWhere(
      (ProjectEntry entry) => entry.id == 'math_solitaire_kids',
    );
    expect(mathSolitaire.isPlaceholder, isTrue);
  });

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
}
