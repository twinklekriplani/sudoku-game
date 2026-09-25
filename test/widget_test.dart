import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/main.dart';

void main() {
  testWidgets('App starts on welcome screen when no player exists', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SudokuQuestApp(initialRoute: '/'));

    // Verify that the welcome screen elements exist.
    expect(find.text('SUDOKU\nQUEST'), findsOneWidget);
    expect(find.text('CONTINUE'), findsOneWidget);
  });
}
