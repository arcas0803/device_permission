import 'package:flutter/foundation.dart';

class PermissionWithService extends Permission {
  const PermissionWithService._(super.value) : super._();

  @visibleForTesting
  const PermissionWithService.private(super.value) : super._();
}

@immutable
class Permission {
  const Permission._(this.value);

  factory Permission.byValue(int value) => values[value];

  final int value;

  @Deprecated('Use [calendarWriteOnly] and [calendarFullAccess].')
  static const calendar = Permission._(0);

  static const camera = Permission._(1);

  static const contacts = Permission._(2);

  static const location = PermissionWithService._(3);

  static const locationAlways = PermissionWithService._(4);

  static const locationWhenInUse = PermissionWithService._(5);

  static const mediaLibrary = Permission._(6);

  static const microphone = Permission._(7);

  static const phone = PermissionWithService._(8);

  static const photos = Permission._(9);

  static const photosAddOnly = Permission._(10);

  static const reminders = Permission._(11);

  static const sensors = Permission._(12);

  static const sms = Permission._(13);

  static const speech = Permission._(14);

  static const storage = Permission._(15);

  static const ignoreBatteryOptimizations = Permission._(16);

  static const notification = Permission._(17);

  static const accessMediaLocation = Permission._(18);

  static const activityRecognition = Permission._(19);

  static const unknown = Permission._(20);

  static const bluetooth = PermissionWithService._(21);

  static const manageExternalStorage = Permission._(22);

  static const systemAlertWindow = Permission._(23);

  static const requestInstallPackages = Permission._(24);

  static const appTrackingTransparency = Permission._(25);

  static const criticalAlerts = Permission._(26);

  static const accessNotificationPolicy = Permission._(27);

  static const bluetoothScan = Permission._(28);

  static const bluetoothAdvertise = Permission._(29);

  static const bluetoothConnect = Permission._(30);

  static const nearbyWifiDevices = Permission._(31);

  static const videos = Permission._(32);

  static const audio = Permission._(33);

  static const scheduleExactAlarm = Permission._(34);

  static const sensorsAlways = Permission._(35);

  static const calendarWriteOnly = Permission._(36);

  static const calendarFullAccess = Permission._(37);

  static const assistant = Permission._(38);

  static const backgroundRefresh = Permission._(39);

  static const List<Permission> values = <Permission>[
    // ignore: deprecated_member_use_from_same_package
    calendar,
    camera,
    contacts,
    location,
    locationAlways,
    locationWhenInUse,
    mediaLibrary,
    microphone,
    phone,
    photos,
    photosAddOnly,
    reminders,
    sensors,
    sms,
    speech,
    storage,
    ignoreBatteryOptimizations,
    notification,
    accessMediaLocation,
    activityRecognition,
    unknown,
    bluetooth,
    manageExternalStorage,
    systemAlertWindow,
    requestInstallPackages,
    appTrackingTransparency,
    criticalAlerts,
    accessNotificationPolicy,
    bluetoothScan,
    bluetoothAdvertise,
    bluetoothConnect,
    nearbyWifiDevices,
    videos,
    audio,
    scheduleExactAlarm,
    sensorsAlways,
    calendarWriteOnly,
    calendarFullAccess,
    assistant,
    backgroundRefresh,
  ];

  static const List<String> _names = <String>[
    'calendar',
    'camera',
    'contacts',
    'location',
    'locationAlways',
    'locationWhenInUse',
    'mediaLibrary',
    'microphone',
    'phone',
    'photos',
    'photosAddOnly',
    'reminders',
    'sensors',
    'sms',
    'speech',
    'storage',
    'ignoreBatteryOptimizations',
    'notification',
    'access_media_location',
    'activity_recognition',
    'unknown',
    'bluetooth',
    'manageExternalStorage',
    'systemAlertWindow',
    'requestInstallPackages',
    'appTrackingTransparency',
    'criticalAlerts',
    'accessNotificationPolicy',
    'bluetoothScan',
    'bluetoothAdvertise',
    'bluetoothConnect',
    'nearbyWifiDevices',
    'videos',
    'audio',
    'scheduleExactAlarm',
    'sensorsAlways',
    'calendarWriteOnly',
    'calendarFullAccess',
    'assistant',
    'backgroundRefresh',
  ];

  @override
  String toString() => 'Permission.${_names[value]}';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is Permission && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}
