import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:device_permission/device_permission.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelDevicePermission platform = MethodChannelDevicePermission();
  const MethodChannel channel =
      MethodChannel('com.arcas0803.device_permission/permissions');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'checkPermissionStatus':
            return 1; // granted
          case 'checkServiceStatus':
            return 1; // enabled
          case 'requestPermissions':
            final permValues = methodCall.arguments as List<dynamic>;
            final result = <int, int>{};
            for (final p in permValues) {
              result[p as int] = 1; // granted
            }
            return result;
          case 'openAppSettings':
            return true;
          case 'shouldShowRequestPermissionRationale':
            return false;
          default:
            return null;
        }
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('checkPermissionStatus returns granted', () async {
    final status = await platform.checkPermissionStatus(
      Permission.byValue(1), // camera
    );
    expect(status, PermissionStatus.granted);
  });

  test('checkServiceStatus returns enabled', () async {
    final status = await platform.checkServiceStatus(
      PermissionWithService.private(3), // location
    );
    expect(status, ServiceStatus.enabled);
  });

  test('requestPermissions returns granted for all', () async {
    final result = await platform.requestPermissions([
      Permission.byValue(1), // camera
      Permission.byValue(7), // microphone
    ]);
    expect(result.length, 2);
    expect(result[Permission.byValue(1)], PermissionStatus.granted);
    expect(result[Permission.byValue(7)], PermissionStatus.granted);
  });

  test('openAppSettings returns true', () async {
    final result = await platform.openAppSettings();
    expect(result, true);
  });

  test('shouldShowRequestPermissionRationale returns false', () async {
    final result = await platform.shouldShowRequestPermissionRationale(
      Permission.byValue(1),
    );
    expect(result, false);
  });
}
