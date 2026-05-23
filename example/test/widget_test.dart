import 'package:flutter_test/flutter_test.dart';
import 'package:device_permission_example/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Device Permissions'), findsOneWidget);
  });
}
