import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/main.dart';

void main() {
  testWidgets('App renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const PaytmApp());
    expect(find.text('Paytm'), findsOneWidget);
  });
}
