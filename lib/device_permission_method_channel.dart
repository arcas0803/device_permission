import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'device_permission_platform_interface.dart';
import 'src/permission.dart';
import 'src/permission_status.dart';
import 'src/service_status.dart';
import 'src/method_channel/codec.dart';

const MethodChannel _methodChannel =
    MethodChannel('com.arcas0803.device_permission/permissions');

class MethodChannelDevicePermission extends DevicePermissionPlatform {
  @override
  Future<PermissionStatus> checkPermissionStatus(Permission permission) async {
    final status = await _methodChannel.invokeMethod(
        'checkPermissionStatus', permission.value);

    return decodePermissionStatus(status);
  }

  @override
  Future<ServiceStatus> checkServiceStatus(Permission permission) async {
    final status = await _methodChannel.invokeMethod(
        'checkServiceStatus', permission.value);

    return decodeServiceStatus(status);
  }

  @override
  Future<bool> openAppSettings() async {
    final wasOpened = await _methodChannel.invokeMethod('openAppSettings');

    return wasOpened ?? false;
  }

  @override
  Future<Map<Permission, PermissionStatus>> requestPermissions(
      List<Permission> permissions) async {
    final data = encodePermissions(permissions);
    final status =
        await _methodChannel.invokeMethod('requestPermissions', data);

    return decodePermissionRequestResult(Map<int, int>.from(status));
  }

  @override
  Future<bool> shouldShowRequestPermissionRationale(
      Permission permission) async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }

    final shouldShowRationale = await _methodChannel.invokeMethod(
        'shouldShowRequestPermissionRationale', permission.value);

    return shouldShowRationale ?? false;
  }
}
