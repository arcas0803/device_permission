import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'src/permission.dart';
import 'src/permission_status.dart';
import 'src/service_status.dart';

abstract class DevicePermissionPlatform extends PlatformInterface {
  DevicePermissionPlatform() : super(token: _token);

  static final Object _token = Object();

  static DevicePermissionPlatform? _instance;

  static DevicePermissionPlatform get instance {
    if (_instance == null) {
      throw StateError(
        'DevicePermissionPlatform.instance has not been initialized. '
        'Ensure that device_permission is properly imported.',
      );
    }
    return _instance!;
  }

  static set instance(DevicePermissionPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<PermissionStatus> checkPermissionStatus(Permission permission) {
    throw UnimplementedError(
        'checkPermissionStatus() has not been implemented.');
  }

  Future<ServiceStatus> checkServiceStatus(Permission permission) {
    throw UnimplementedError('checkServiceStatus() has not been implemented.');
  }

  Future<bool> openAppSettings() {
    throw UnimplementedError('openAppSettings() has not been implemented.');
  }

  Future<Map<Permission, PermissionStatus>> requestPermissions(
      List<Permission> permissions) {
    throw UnimplementedError('requestPermissions() has not been implemented.');
  }

  Future<bool> shouldShowRequestPermissionRationale(Permission permission) {
    throw UnimplementedError(
        'shouldShowRequestPermissionRationale() has not been implemented.');
  }
}
