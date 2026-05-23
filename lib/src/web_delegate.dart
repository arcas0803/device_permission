import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'permission.dart';
import 'permission_status.dart';
import 'service_status.dart';

class WebDelegate {
  WebDelegate(
    web.MediaDevices? devices,
    web.Geolocation? geolocation,
    web.Permissions? permissions,
  )   : _devices = devices,
        _geolocation = geolocation,
        _htmlPermissions = permissions;

  final web.MediaDevices? _devices;
  final web.Geolocation? _geolocation;
  final web.Permissions? _htmlPermissions;

  static const _microphonePermissionName = 'microphone';
  static const _cameraPermissionName = 'camera';
  static const _notificationsPermissionName = 'notifications';
  static const _locationPermissionName = 'geolocation';
  static const _grantedPermissionStatus = 'granted';
  static const _deniedPermissionStatus = 'denied';
  static const _promptPermissionStatus = 'prompt';

  PermissionStatus _toPermissionStatus(String? webPermissionStatus) {
    switch (webPermissionStatus) {
      case _grantedPermissionStatus:
        return PermissionStatus.granted;
      case _deniedPermissionStatus:
        return PermissionStatus.permanentlyDenied;
      case _promptPermissionStatus:
      default:
        return PermissionStatus.denied;
    }
  }

  Future<PermissionStatus> _permissionStatusState(
      String webPermissionName, web.Permissions? permissions) async {
    final webPermissionStatus = await permissions
        ?.query(_PermissionDescriptor(name: webPermissionName))
        .toDart;
    return _toPermissionStatus(webPermissionStatus?.state);
  }

  Future<bool> _requestMicrophonePermission() async {
    if (_devices == null) {
      return false;
    }

    try {
      web.MediaStream? mediaStream = await _devices
          .getUserMedia(web.MediaStreamConstraints(audio: true.toJS))
          .toDart;

      if (mediaStream.active) {
        final audioTracks = mediaStream.getAudioTracks().toDart;
        if (audioTracks.isNotEmpty) {
          audioTracks[0].stop();
        }
      }
    } catch (_) {
      return false;
    }

    return true;
  }

  Future<bool> _requestCameraPermission() async {
    if (_devices == null) {
      return false;
    }

    try {
      web.MediaStream? mediaStream = await _devices
          .getUserMedia(web.MediaStreamConstraints(video: true.toJS))
          .toDart;

      if (mediaStream.active) {
        final videoTracks = mediaStream.getVideoTracks().toDart;
        if (videoTracks.isNotEmpty) {
          videoTracks[0].stop();
        }
      }
    } catch (_) {
      return false;
    }

    return true;
  }

  Future<bool> _requestNotificationPermission() async {
    return web.Notification.requestPermission()
        .toDart
        .then((permission) => (permission == 'granted'.toJS));
  }

  Future<bool> _requestLocationPermission() async {
    Completer<bool> completer = Completer<bool>();
    try {
      _geolocation?.getCurrentPosition(
        (JSAny _) {
          completer.complete(true);
        }.toJS,
        (JSAny _) {
          completer.complete(false);
        }.toJS,
      );
    } catch (_) {
      completer.complete(false);
    }
    return completer.future;
  }

  Future<PermissionStatus> _requestSingularPermission(
      Permission permission) async {
    bool permissionGranted = switch (permission) {
      Permission.microphone => await _requestMicrophonePermission(),
      Permission.camera => await _requestCameraPermission(),
      Permission.notification => await _requestNotificationPermission(),
      Permission.location => await _requestLocationPermission(),
      _ => throw UnsupportedError(
          'The ${permission.toString()} permission is currently not supported on web.')
    };

    if (!permissionGranted) {
      return PermissionStatus.permanentlyDenied;
    }
    return PermissionStatus.granted;
  }

  Future<Map<Permission, PermissionStatus>> requestPermissions(
      List<Permission> permissions) async {
    final Map<Permission, PermissionStatus> permissionStatusMap = {};

    for (final permission in permissions) {
      try {
        permissionStatusMap[permission] =
            await _requestSingularPermission(permission);
      } on UnimplementedError {
        rethrow;
      }
    }
    return permissionStatusMap;
  }

  Future<PermissionStatus> checkPermissionStatus(Permission permission) async {
    String webPermissionName;
    switch (permission) {
      case Permission.microphone:
        webPermissionName = _microphonePermissionName;
        break;
      case Permission.camera:
        webPermissionName = _cameraPermissionName;
        break;
      case Permission.notification:
        webPermissionName = _notificationsPermissionName;
        break;
      case Permission.location:
        webPermissionName = _locationPermissionName;
        break;
      default:
        throw UnimplementedError(
          'checkPermissionStatus() has not been implemented for ${permission.toString()} '
          'on web.',
        );
    }
    return _permissionStatusState(webPermissionName, _htmlPermissions);
  }

  Future<ServiceStatus> checkServiceStatus(Permission permission) async {
    try {
      final permissionStatus = await checkPermissionStatus(permission);
      switch (permissionStatus) {
        case PermissionStatus.granted:
          return ServiceStatus.enabled;
        default:
          return ServiceStatus.disabled;
      }
    } on UnimplementedError {
      rethrow;
    }
  }
}

extension type _PermissionDescriptor._(JSObject _) implements JSObject {
  external factory _PermissionDescriptor({required String name});

  external set name(String value);
  external String get name;
}
