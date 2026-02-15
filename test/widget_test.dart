import 'package:flutter_test/flutter_test.dart';
import 'package:vibeland/main.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const VibelandApp());
    expect(find.byType(VibelandApp), findsOneWidget);
  });
}
