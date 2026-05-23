import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:device_permission/device_permission.dart';

class MockDevicePermissionPlatform
    with MockPlatformInterfaceMixin
    implements DevicePermissionPlatform {
  @override
  Future<PermissionStatus> checkPermissionStatus(Permission permission) async {
    if (permission == Permission.camera) {
      return PermissionStatus.granted;
    }
    return PermissionStatus.denied;
  }

  @override
  Future<ServiceStatus> checkServiceStatus(Permission permission) async {
    return ServiceStatus.notApplicable;
  }

  @override
  Future<bool> openAppSettings() async {
    return true;
  }

  @override
  Future<Map<Permission, PermissionStatus>> requestPermissions(
      List<Permission> permissions) async {
    return {
      for (final p in permissions) p: PermissionStatus.granted,
    };
  }

  @override
  Future<bool> shouldShowRequestPermissionRationale(
      Permission permission) async {
    return false;
  }
}

void main() {
  setUp(() {
    try {
      DevicePermissionPlatform.instance;
    } on StateError {
      DevicePermissionPlatform.instance = MethodChannelDevicePermission();
    }
  });

  final DevicePermissionPlatform initialPlatform = MethodChannelDevicePermission();

  test('$MethodChannelDevicePermission is the default instance', () {
    DevicePermissionPlatform.instance = initialPlatform;
    expect(DevicePermissionPlatform.instance,
        isInstanceOf<MethodChannelDevicePermission>());
  });

  test('checkPermissionStatus via mock platform', () async {
    final fakePlatform = MockDevicePermissionPlatform();
    DevicePermissionPlatform.instance = fakePlatform;

    final status = await DevicePermissionPlatform.instance
        .checkPermissionStatus(Permission.camera);
    expect(status, PermissionStatus.granted);

    final deniedStatus = await DevicePermissionPlatform.instance
        .checkPermissionStatus(Permission.microphone);
    expect(deniedStatus, PermissionStatus.denied);

    DevicePermissionPlatform.instance = initialPlatform;
  });

  test('PermissionStatus enum values', () {
    expect(PermissionStatus.denied.value, 0);
    expect(PermissionStatus.granted.value, 1);
    expect(PermissionStatus.restricted.value, 2);
    expect(PermissionStatus.limited.value, 3);
    expect(PermissionStatus.permanentlyDenied.value, 4);
    expect(PermissionStatus.provisional.value, 5);
  });

  test('ServiceStatus enum values', () {
    expect(ServiceStatus.disabled.value, 0);
    expect(ServiceStatus.enabled.value, 1);
    expect(ServiceStatus.notApplicable.value, 2);
  });

  test('Permission values are unique', () {
    final values = Permission.values.map((p) => p.value).toList();
    final uniqueValues = values.toSet();
    expect(values.length, uniqueValues.length);
  });

  test('Permission.byValue creates correct permissions', () {
    expect(Permission.byValue(0), Permission.calendar);
    expect(Permission.byValue(1), Permission.camera);
    expect(Permission.byValue(7), Permission.microphone);
    expect(Permission.byValue(17), Permission.notification);
  });

  test('PermissionWithService is a subtype of Permission', () {
    expect(Permission.location, isA<Permission>());
    expect(Permission.locationAlways, isA<PermissionWithService>());
  });

  test('openAppSettings calls platform', () async {
    final fakePlatform = MockDevicePermissionPlatform();
    DevicePermissionPlatform.instance = fakePlatform;

    final result = await openAppSettings();
    expect(result, true);

    DevicePermissionPlatform.instance = initialPlatform;
  });
}
