import 'package:flutter_test/flutter_test.dart';

import 'package:Keifu/app.dart';

void main() {
  testWidgets('app bootstraps', (WidgetTester tester) async {
    await tester.pumpWidget(const KeifuKiApp());

    expect(find.byType(KeifuKiApp), findsOneWidget);
  });
}
