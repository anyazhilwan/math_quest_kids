import 'package:flutter_test/flutter_test.dart';

import 'package:math_quest_kids/main.dart';

void main() {
  testWidgets('App launches and shows Play screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MathQuestApp());

    expect(find.text('Math Quest Kids'), findsOneWidget);
    expect(find.text('Calculate'), findsOneWidget);
  });
}
