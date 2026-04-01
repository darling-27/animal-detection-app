// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:animal_detection/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WildAnimalDetectionApp());
    await tester.pumpAndSettle();

    // Verify splash screen appears (Firebase init complete)
    expect(find.text('WILD GUARDIAN'), findsOneWidget);
    expect(find.text('Animal Detection System'), findsOneWidget);
  });
}
