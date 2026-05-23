import 'dart:async';

import 'package:web/web.dart' as web;
import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'device_permission_platform_interface.dart';
import 'src/permission.dart';
import 'src/permission_status.dart';
import 'src/service_status.dart';
import 'src/web_delegate.dart';

class DevicePermissionWeb extends DevicePermissionPlatform {
  static final web.MediaDevices? _devices = _getMediaDevices();
  static final web.Geolocation _geolocation = web.window.navigator.geolocation;
  static final web.Permissions? _htmlPermissions = _getPermissions();

  static web.MediaDevices? _getMediaDevices() {
    try {
      return web.window.navigator.mediaDevices;
    } catch (_) {
      return null;
    }
  }

  static web.Permissions? _getPermissions() {
    try {
      return web.window.navigator.permissions;
    } catch (_) {
      return null;
    }
  }

  final WebDelegate _webDelegate;

  static void registerWith(Registrar registrar) {
    DevicePermissionPlatform.instance = DevicePermissionWeb(
      webDelegate: WebDelegate(
        _devices,
        _geolocation,
        _htmlPermissions,
      ),
    );
  }

  DevicePermissionWeb({
    required this._webDelegate,
  });

  @override
  Future<Map<Permission, PermissionStatus>> requestPermissions(
      List<Permission> permissions) async {
    return _webDelegate.requestPermissions(permissions);
  }

  @override
  Future<PermissionStatus> checkPermissionStatus(Permission permission) async {
    return _webDelegate.checkPermissionStatus(permission);
  }

  @override
  Future<ServiceStatus> checkServiceStatus(Permission permission) async {
    return _webDelegate.checkServiceStatus(permission);
  }

  @override
  Future<bool> shouldShowRequestPermissionRationale(
      Permission permission) async {
    return SynchronousFuture(false);
  }

  @override
  Future<bool> openAppSettings() {
    return SynchronousFuture(false);
  }
}
