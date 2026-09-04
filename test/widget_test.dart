// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:self_improvement_app/main.dart';

void main() {
  testWidgets('Truck Stop App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TruckStopApp());

    // Verify that our app name exists on the header.
    expect(find.text('Truck Stop LTE ERP Store 1'), findsOneWidget);
  });
}
