export 'src/permission.dart'
    show Permission, PermissionWithService;
export 'src/permission_status.dart'
    show
        PermissionStatus,
        PermissionStatusGetters,
        PermissionStatusValue,
        FuturePermissionStatusGetters;
export 'src/service_status.dart'
    show
        ServiceStatus,
        ServiceStatusGetters,
        ServiceStatusValue,
        FutureServiceStatusGetters;
export 'device_permission_platform_interface.dart'
    show DevicePermissionPlatform;
export 'device_permission_method_channel.dart'
    show MethodChannelDevicePermission;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'device_permission_platform_interface.dart';
import 'device_permission_method_channel.dart';
import 'src/permission.dart';
import 'src/permission_status.dart';
import 'src/service_status.dart';

void _ensureInitialized() {
  try {
    DevicePermissionPlatform.instance;
  } on StateError {
    DevicePermissionPlatform.instance = MethodChannelDevicePermission();
  }
}

DevicePermissionPlatform get _handler {
  _ensureInitialized();
  return DevicePermissionPlatform.instance;
}

Future<bool> openAppSettings() async {
  _ensureInitialized();
  return _handler.openAppSettings();
}

extension PermissionActions on Permission {
  static FutureOr<void>? Function()? _onDenied;
  static FutureOr<void>? Function()? _onGranted;
  static FutureOr<void>? Function()? _onPermanentlyDenied;
  static FutureOr<void>? Function()? _onRestricted;
  static FutureOr<void>? Function()? _onLimited;
  static FutureOr<void>? Function()? _onProvisional;

  Permission onDeniedCallback(FutureOr<void>? Function()? callback) {
    _onDenied = callback;
    return this;
  }

  Permission onGrantedCallback(FutureOr<void>? Function()? callback) {
    _onGranted = callback;
    return this;
  }

  Permission onPermanentlyDeniedCallback(FutureOr<void>? Function()? callback) {
    _onPermanentlyDenied = callback;
    return this;
  }

  Permission onRestrictedCallback(FutureOr<void>? Function()? callback) {
    _onRestricted = callback;
    return this;
  }

  Permission onLimitedCallback(FutureOr<void>? Function()? callback) {
    _onLimited = callback;
    return this;
  }

  Permission onProvisionalCallback(FutureOr<void>? Function()? callback) {
    _onProvisional = callback;
    return this;
  }

  Future<PermissionStatus> get status => _handler.checkPermissionStatus(this);

  Future<bool> get shouldShowRequestRationale async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }

    return _handler.shouldShowRequestPermissionRationale(this);
  }

  Future<PermissionStatus> request() async {
    final permissionStatus =
        (await [this].request())[this] ?? PermissionStatus.denied;

    if (permissionStatus.isDenied) {
      _onDenied?.call();
    } else if (permissionStatus.isGranted) {
      _onGranted?.call();
    } else if (permissionStatus.isPermanentlyDenied) {
      _onPermanentlyDenied?.call();
    } else if (permissionStatus.isRestricted) {
      _onRestricted?.call();
    } else if (permissionStatus.isLimited) {
      _onLimited?.call();
    } else if (permissionStatus.isProvisional) {
      _onProvisional?.call();
    }

    return permissionStatus;
  }
}

extension PermissionCheckShortcuts on Permission {
  Future<bool> get isGranted => status.isGranted;
  Future<bool> get isDenied => status.isDenied;
  Future<bool> get isRestricted => status.isRestricted;
  Future<bool> get isLimited => status.isLimited;
  Future<bool> get isPermanentlyDenied => status.isPermanentlyDenied;
  Future<bool> get isProvisional => status.isProvisional;
}

extension ServicePermissionActions on PermissionWithService {
  Future<ServiceStatus> get serviceStatus =>
      _handler.checkServiceStatus(this);
}

extension PermissionListActions on List<Permission> {
  Future<Map<Permission, PermissionStatus>> request() =>
      _handler.requestPermissions(this);
}
