import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:device_permission/device_permission.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final Map<Permission, PermissionStatus?> statusResults = {};
  final Map<Permission, PermissionStatus?> requestResults = {};
  final Set<Permission> unsupported = {};
  final Map<Permission, String> errors = {};

  final allPermissions = Permission.values;

  test('Permission diagnostic - check all statuses', () async {
    for (final permission in allPermissions) {
      final name = permission.toString().replaceAll('Permission.', '');
      try {
        final status = await permission.status;
        statusResults[permission] = status;

        // ignore: avoid_print
        print('  $name: ${status.name}');
      } on UnimplementedError catch (e) {
        unsupported.add(permission);
        errors[permission] = 'Unimplemented: $e';

        // ignore: avoid_print
        print('  $name: UNSUPPORTED (Unimplemented)');
      } on UnsupportedError catch (e) {
        unsupported.add(permission);
        errors[permission] = 'Unsupported: $e';

        // ignore: avoid_print
        print('  $name: UNSUPPORTED (Unsupported)');
      } catch (e) {
        unsupported.add(permission);
        errors[permission] = 'Error: $e';

        // ignore: avoid_print
        print('  $name: ERROR ($e)');
      }
    }
  });

  test('Permission diagnostic - request permissions', () async {
    for (final permission in allPermissions) {
      if (unsupported.contains(permission)) continue;
      final name = permission.toString().replaceAll('Permission.', '');
      try {
        final result = await permission.request();
        requestResults[permission] = result;

        // ignore: avoid_print
        print('  $name: requested -> ${result.name}');
      } on UnimplementedError catch (e) {
        unsupported.add(permission);
        errors[permission] = 'Unimplemented: $e';
        statusResults.remove(permission);

        // ignore: avoid_print
        print('  $name: UNSUPPORTED (Unimplemented)');
      } on UnsupportedError catch (e) {
        unsupported.add(permission);
        errors[permission] = 'Unsupported: $e';
        statusResults.remove(permission);

        // ignore: avoid_print
        print('  $name: UNSUPPORTED (Unsupported)');
      } catch (e) {
        unsupported.add(permission);
        errors[permission] = 'Error: $e';
        statusResults.remove(permission);

        // ignore: avoid_print
        print('  $name: ERROR ($e)');
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
  });

  test('Diagnostic report', () {
    final buffer = StringBuffer();
    buffer.writeln('');
    buffer.writeln('=' * 65);
    buffer.writeln('          PERMISSION DIAGNOSTIC REPORT');
    buffer.writeln('=' * 65);
    buffer.writeln('');

    buffer.writeln('SUPPORTED (status check works):');
    var working = 0;
    for (final entry in statusResults.entries) {
      if (!unsupported.contains(entry.key)) {
        final name = entry.key.toString().replaceAll('Permission.', '');
        buffer.writeln(
            '  ${name.padRight(35)} | status: ${entry.value?.name.padRight(18)} | request: ${requestResults[entry.key]?.name ?? "not tested"}');
        working++;
      }
    }
    if (working == 0) buffer.writeln('  (none)');
    buffer.writeln('');

    buffer.writeln('UNSUPPORTED / FAILED:');
    for (final p in unsupported) {
      final name = p.toString().replaceAll('Permission.', '');
      buffer.writeln(
          '  ${name.padRight(35)} | ${errors[p] ?? "unknown error"}');
    }
    buffer.writeln('');

    buffer.writeln('SUMMARY:');
    buffer.writeln('  Total:    ${allPermissions.length}');
    buffer.writeln('  Working:  $working');
    buffer.writeln('  Failed:   ${unsupported.length}');
    buffer.writeln('');

    buffer.writeln('TIPS:');
    for (final p in unsupported) {
      final name = p.toString().replaceAll('Permission.', '');
      switch (p.value) {
        case 1:
          buffer
              .writeln('  $name: Add NSCameraUsageDescription to Info.plist');
        case 2:
          buffer
              .writeln('  $name: Add NSContactsUsageDescription to Info.plist');
        case 3:
        case 4:
        case 5:
          buffer.writeln(
              '  $name: Add NSLocationWhenInUseUsageDescription to Info.plist');
        case 7:
        case 14:
          buffer.writeln(
              '  $name: Add NSMicrophoneUsageDescription to Info.plist');
        case 9:
        case 10:
          buffer.writeln(
              '  $name: Add NSPhotoLibraryUsageDescription to Info.plist');
        case 12:
          buffer
              .writeln('  $name: Add NSMotionUsageDescription to Info.plist');
        case 13:
          buffer.writeln('  $name: Android only.');
        case 17:
          buffer.writeln('  $name: Requires UNUserNotificationCenter access.');
        case 21:
          buffer.writeln(
              '  $name: Add NSBluetoothAlwaysUsageDescription to Info.plist');
        case 25:
          buffer.writeln(
              '  $name: Add NSUserTrackingUsageDescription, iOS 14+');
        case 38:
          buffer.writeln('  $name: Requires Siri entitlement.');
        case 0:
        case 36:
        case 37:
          buffer.writeln(
              '  $name: Add NSCalendarsUsageDescription to Info.plist');
        default:
          if (p.value >= 16 && p.value <= 35 && p.value != 17 && p.value != 21) {
            buffer.writeln('  $name: Android-only permission.');
          } else {
            buffer.writeln('  $name: Check README for platform support.');
          }
      }
    }
    buffer.writeln('');
    buffer.writeln('=' * 65);

    // ignore: avoid_print
    print(buffer.toString());

    expect(statusResults.length + unsupported.length, allPermissions.length);
  });
}
