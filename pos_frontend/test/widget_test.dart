import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/main.dart';

void main() {
  testWidgets('App renders POS home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const PaytmPosApp());
    expect(find.text('Paytm POS'), findsOneWidget);
  });
}
