import 'package:flutter_test/flutter_test.dart';

import 'package:totetrax_mobile/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ToteTraxApp());
    expect(find.text('ToteTrax'), findsOneWidget);
  });
}
