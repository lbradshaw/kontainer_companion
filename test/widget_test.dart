import 'package:flutter_test/flutter_test.dart';

import 'package:kontainer_mobile/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ToteTraxApp());
    expect(find.text('Kontainer'), findsOneWidget);
  });
}
