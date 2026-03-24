import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:front_elearning_flutter/app/app.dart';

void main() {
  testWidgets('App boots to auth screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: EnglishLearningApp()));

    await tester.pumpAndSettle();

    expect(find.text('Chao mung tro lai'), findsOneWidget);
  });
}
