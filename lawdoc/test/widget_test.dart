import 'package:flutter_test/flutter_test.dart';
import 'package:lawdoc/app.dart';

void main() {
  testWidgets('LawDoc app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const LawDocApp());
    expect(find.byType(LawDocApp), findsOneWidget);
  });
}
