import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:device_permission/device_permission.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('request camera permission', (WidgetTester tester) async {
    final status = await Permission.camera.request();
    expect(status, isNotNull);
  });
}
