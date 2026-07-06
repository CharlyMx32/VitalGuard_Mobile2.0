import 'package:flutter_test/flutter_test.dart';
import 'package:vitalguard_mobile/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const VitalGuardApp());
    expect(find.text('Splash Screen'), findsOneWidget);
  });
}
