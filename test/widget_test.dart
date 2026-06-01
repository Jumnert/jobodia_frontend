import 'package:flutter_test/flutter_test.dart';
import 'package:jobodia_frontend/main.dart';

void main() {
  testWidgets('shows hello text', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Hello'), findsOneWidget);
  });
}
