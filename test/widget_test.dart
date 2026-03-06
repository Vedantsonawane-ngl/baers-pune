// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:red_link/main.dart';

void main() {
  testWidgets('Splash screen shows RedLink text', (WidgetTester tester) async {
    await tester.pumpWidget(const RedLinkApp());
    await tester.pump();

    expect(find.text('Red'), findsOneWidget);
    expect(find.text('Link'), findsOneWidget);
  });
}
