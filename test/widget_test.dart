import 'package:flutter_test/flutter_test.dart';

import 'package:infennon_labs_home/main.dart';

void main() {
  testWidgets('homepage renders project hub', (WidgetTester tester) async {
    await tester.pumpWidget(const InfennonLabsApp());

    expect(find.text('Infennon Labs'), findsWidgets);
    expect(find.text('Projects'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
    expect(find.text('Contact'), findsOneWidget);
    expect(find.text('Alpha Kids'), findsOneWidget);
  });
}
