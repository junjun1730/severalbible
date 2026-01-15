import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:severalbible/main.dart';

void main() {
  testWidgets('App displays welcome message', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    expect(find.text('Welcome to One Message'), findsOneWidget);
    expect(find.text('One Message'), findsOneWidget);
  });
}
