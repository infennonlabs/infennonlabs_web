import 'package:flutter_test/flutter_test.dart';

import 'package:infennon_labs_home/main.dart';

void main() {
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
  });
}
