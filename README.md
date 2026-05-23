# device_permission

[![pub package](https://img.shields.io/pub/v/device_permission.svg)](https://pub.dev/packages/device_permission)
[![CI](https://github.com/arcas0803/device_permission/actions/workflows/ci.yaml/badge.svg)](https://github.com/arcas0803/device_permission/actions/workflows/ci.yaml)
[![codecov](https://codecov.io/gh/arcas0803/device_permission/branch/main/graph/badge.svg)](https://codecov.io/gh/arcas0803/device_permission)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A cross-platform Flutter plugin to check and request device permissions
across **Android, iOS, macOS, Web, Windows and Linux**.

> **Credits & attribution** — the public API surface, semantics and naming of
> this plugin are inspired by the excellent
> [`flutter-permission-handler`](https://github.com/Baseflow/flutter-permission-handler) plugin
> by [Baseflow](https://baseflow.com). This package is an independent
> reimplementation distributed under the MIT License.

## Features

- **40 permission types** — camera, microphone, location, notifications,
  contacts, calendar, photos, sensors, bluetooth, speech, storage and more.
- Check individual or multiple permission statuses in a single call.
- Request permissions with granular callbacks (denied, granted,
  permanentlyDenied, restricted, limited, provisional).
- Service-status checks for permissions with an associated system service
  (location, bluetooth, phone).
- Open app/system settings directly from the plugin.
- Android *should-show-rationale* support.
- iOS 14+ limited photo-access and provisional notifications.
- Permission-aware extension getters (`isGranted`, `isDenied`, etc.).

## Platform support

| Platform | Minimum version | Backend                                                   |
| -------- | --------------- | --------------------------------------------------------- |
| Android  | 7.0 (API 24)    | `ActivityCompat` / `Settings` Intents + `NotificationManagerCompat` |
| iOS      | 13.0            | `AVCaptureDevice`, `CLLocationManager`, `PHPhotoLibrary`, `UNUserNotificationCenter`, `CNContactStore`, `EKEventStore`, `SFSpeechRecognizer`, `CoreBluetooth`, `CoreMotion`, `ATTrackingManager`, `INPreferences`, `MPMediaLibrary` |
| macOS    | 10.15           | Apple frameworks: `AVFoundation`, `CoreLocation`, `Photos`, `UserNotifications`, `Contacts`, `EventKit`, `Speech`, `CoreBluetooth`, `CoreMotion`, `Intents`, `MediaPlayer` |
| Web      | Secure context  | `navigator.mediaDevices.getUserMedia`, `navigator.permissions`, `Notification.requestPermission`, `navigator.geolocation` |
| Windows  | 10 (1809+)      | `ms-settings:` URI scheme; desktop permissions implicitly granted |
| Linux    | GTK 3           | Desktop permissions implicitly granted; `gnome-control-center` for settings |

## Toolchain compatibility

- **Swift Package Manager** — the iOS and macOS plugins ship as Swift
  packages (`ios/device_permission/Package.swift`,
  `macos/device_permission/Package.swift`), so they integrate natively when
  Flutter resolves your app with SwiftPM (the default on recent Flutter
  versions). Traditional CocoaPods resolution is still supported through the
  bundled `.podspec` files.
- **Gradle 9** — the Android side targets the AGP 9 / Gradle 9 toolchain
  (Kotlin 2.x, Java 17 toolchain, namespace-based manifests).

## Permission types

| Permission | Value | Description |
|------------|------:|-------------|
| `calendar` | 0 | Calendar access *(deprecated)* |
| `camera` | 1 | Camera access |
| `contacts` | 2 | Contacts access |
| `location` | 3 | Location access *(has service)* |
| `locationAlways` | 4 | Background location *(has service)* |
| `locationWhenInUse` | 5 | Foreground location *(has service)* |
| `mediaLibrary` | 6 | Media library (iOS 9.3+) |
| `microphone` | 7 | Microphone access |
| `phone` | 8 | Phone state (Android) *(has service)* |
| `photos` | 9 | Photo library read & write |
| `photosAddOnly` | 10 | Photo library add-only (iOS) |
| `reminders` | 11 | Reminders (iOS) |
| `sensors` | 12 | Body / motion sensors |
| `sms` | 13 | SMS (Android) |
| `speech` | 14 | Speech recognition |
| `storage` | 15 | External storage |
| `ignoreBatteryOptimizations` | 16 | Ignore battery optimizations (Android) |
| `notification` | 17 | Push notifications |
| `accessMediaLocation` | 18 | Media location (Android 10+) |
| `activityRecognition` | 19 | Activity recognition (Android 10+) |
| `unknown` | 20 | Unknown (return type only) |
| `bluetooth` | 21 | Bluetooth *(has service)* |
| `manageExternalStorage` | 22 | Manage external storage (Android 11+) |
| `systemAlertWindow` | 23 | System alert window (Android) |
| `requestInstallPackages` | 24 | Request install packages (Android) |
| `appTrackingTransparency` | 25 | App Tracking Transparency (iOS 14+) |
| `criticalAlerts` | 26 | Critical alerts (iOS) |
| `accessNotificationPolicy` | 27 | Notification policy access (Android) |
| `bluetoothScan` | 28 | Bluetooth scan (Android 12+) |
| `bluetoothAdvertise` | 29 | Bluetooth advertise (Android 12+) |
| `bluetoothConnect` | 30 | Bluetooth connect (Android 12+) |
| `nearbyWifiDevices` | 31 | Nearby Wi-Fi devices (Android 13+) |
| `videos` | 32 | Video files (Android 13+) |
| `audio` | 33 | Audio files (Android 13+) |
| `scheduleExactAlarm` | 34 | Schedule exact alarm (Android 12+) |
| `sensorsAlways` | 35 | Sensors in background (Android 13+) |
| `calendarWriteOnly` | 36 | Calendar write-only |
| `calendarFullAccess` | 37 | Calendar full access |
| `assistant` | 38 | Siri / Assistant (iOS) |
| `backgroundRefresh` | 39 | Background refresh (iOS) |

## Functionality matrix

| Feature | Android | iOS | macOS | Web | Windows | Linux |
| ------- | :-----: | :-: | :---: | :-: | :-----: | :---: |
| `checkPermissionStatus` | ✅ | ✅ | ✅ | ✅¹ | ✅ | ✅ |
| `requestPermissions` (single) | ✅ | ✅ | ✅ | ✅¹ | ✅ | ✅ |
| `requestPermissions` (batch) | ✅ | ✅ | ✅ | ✅¹ | ✅ | ✅ |
| `checkServiceStatus` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `openAppSettings` | ✅ | ✅ | ✅ | —² | ✅ | ✅ |
| `shouldShowRequestPermissionRationale` | ✅ | —³ | —³ | —³ | —³ | —³ |
| Callbacks (`onDenied`, `onGranted`, etc.) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Limited photo access (iOS 14+) | — | ✅ | ✅ | — | — | — |
| Provisional notifications (iOS 12+) | — | ✅ | ✅ | — | — | — |

<sup>¹ Web supports microphone, camera, notification, and location
permissions.<br>
² Browsers do not allow programmatic navigation to permission settings;
the call returns `false`.<br>
³ The *should-show-rationale* API is Android-only; all other platforms
return `false`.</sup>

## Permissions setup

### Android (`AndroidManifest.xml`)

Add the permissions your app needs to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.READ_CONTACTS" />
<uses-permission android:name="android.permission.WRITE_CONTACTS" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
```

### iOS (`Info.plist`)

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to take photos.</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to record audio.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access while in use.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs location access always.</string>
<key>NSContactsUsageDescription</key>
<string>This app needs contacts access.</string>
<key>NSRemindersUsageDescription</key>
<string>This app needs reminders access.</string>
<key>NSCalendarsUsageDescription</key>
<string>This app needs calendar access.</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app needs speech recognition access.</string>
<key>NSMotionUsageDescription</key>
<string>This app needs motion sensor access.</string>
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app needs bluetooth access.</string>
<key>NSUserTrackingUsageDescription</key>
<string>This app needs tracking access.</string>
<key>NSAppleMusicUsageDescription</key>
<string>This app needs media library access.</string>
```

### macOS

In `macos/Runner/Info.plist`, add the corresponding usage description keys
(same as iOS).

### Web

The Permissions API works only on **HTTPS** or `localhost`. No additional
configuration is required.

### Windows

Desktop-appropriate permissions (camera, microphone, location) are managed
by the OS-level privacy settings; no manifest configuration is required.

### Linux

Desktop permissions are managed at the system level. The plugin returns
`granted` for desktop-relevant permissions (camera, microphone, storage,
etc.) and `restricted` for mobile-only permissions.

## Usage

```dart
import 'package:device_permission/device_permission.dart';

Future<void> checkCamera() async {
  // Check a single permission
  PermissionStatus status = await Permission.camera.status;

  if (status.isGranted) {
    // Camera is available
  } else if (status.isPermanentlyDenied) {
    await openAppSettings();
    return;
  }

  // Request the permission
  status = await Permission.camera.request();
  print('Camera: $status');
}

Future<void> checkMultiple() async {
  // Request multiple permissions at once
  Map<Permission, PermissionStatus> statuses = await [
    Permission.camera,
    Permission.microphone,
    Permission.location,
  ].request();

  statuses.forEach((permission, status) {
    print('${permission.toString()}: $status');
  });
}
```

### Using callbacks

```dart
await Permission.camera
    .onDeniedCallback(() => print('Camera denied'))
    .onGrantedCallback(() => print('Camera granted'))
    .onPermanentlyDeniedCallback(() => print('Camera permanently denied'))
    .request();
```

### Shortcut getters

```dart
if (await Permission.camera.isGranted) {
  // do something with camera
}

if (await Permission.location.isPermanentlyDenied) {
  await openAppSettings();
}
```

### Service status (location, bluetooth, phone)

```dart
final location = Permission.location as PermissionWithService;
final serviceStatus = await location.serviceStatus;

if (serviceStatus.isDisabled) {
  print('Location service is turned off');
}
```

## API reference

| Member | Returns |
| ------ | ------- |
| `Permission.camera.status` | `Future<PermissionStatus>` |
| `Permission.camera.request()` | `Future<PermissionStatus>` |
| `[Permission.camera, Permission.microphone].request()` | `Future<Map<Permission, PermissionStatus>>` |
| `Permission.camera.shouldShowRequestRationale` | `Future<bool>` |
| `Permission.camera.isGranted` | `Future<bool>` |
| `Permission.camera.isDenied` | `Future<bool>` |
| `Permission.camera.isPermanentlyDenied` | `Future<bool>` |
| `Permission.camera.isRestricted` | `Future<bool>` |
| `Permission.camera.isLimited` | `Future<bool>` |
| `Permission.camera.isProvisional` | `Future<bool>` |
| `(Permission.camera as PermissionWithService).serviceStatus` | `Future<ServiceStatus>` |
| `openAppSettings()` | `Future<bool>` |
| `Permission.camera.onDeniedCallback(...).request()` | `Future<PermissionStatus>` |

### PermissionStatus values

| Status | Description |
| ------ | ----------- |
| `denied` | Not yet requested or was denied |
| `granted` | Permission granted by the user |
| `restricted` | OS-level restriction (parental controls, etc.) |
| `limited` | Limited access granted (iOS 14+ photo picker) |
| `permanentlyDenied` | Permission permanently denied; must use settings |
| `provisional` | Provisional notification authorization (iOS 12+) |

### ServiceStatus values

| Status | Description |
| ------ | ----------- |
| `disabled` | The system service is disabled |
| `enabled` | The system service is enabled |
| `notApplicable` | No associated service on this platform |

## Migration from `permission_handler`

| `permission_handler` | `device_permission` |
| -------------------- | ------------------- |
| `Permission.camera.status` | `Permission.camera.status` |
| `Permission.camera.request()` | `Permission.camera.request()` |
| `Permission.camera.shouldShowRequestRationale` | `Permission.camera.shouldShowRequestRationale` |
| `Permission.camera.isGranted` | `Permission.camera.isGranted` |
| `PermissionWithService.serviceStatus` | `PermissionWithService.serviceStatus` |
| `openAppSettings()` | `openAppSettings()` |
| `PermissionStatus.neverAskAgain` | `PermissionStatus.permanentlyDenied` |

The API surface is intentionally kept compatible. The main differences are:
- Package name: `permission_handler` → `device_permission`
- ~30 of the deprecated `neverAskAgain` status replaced by `permanentlyDenied`

## License

[MIT](LICENSE). Portions inspired by
[`flutter-permission-handler`](https://github.com/Baseflow/flutter-permission-handler) by
Baseflow.
