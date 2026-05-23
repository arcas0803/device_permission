import '../permission.dart';
import '../permission_status.dart';
import '../service_status.dart';

PermissionStatus decodePermissionStatus(int value) {
  return PermissionStatusValue.statusByValue(value);
}

ServiceStatus decodeServiceStatus(int value) {
  return ServiceStatusValue.statusByValue(value);
}

Map<Permission, PermissionStatus> decodePermissionRequestResult(
    Map<int, int> value) {
  return value.map((key, value) => MapEntry<Permission, PermissionStatus>(
      Permission.byValue(key), PermissionStatusValue.statusByValue(value)));
}

List<int> encodePermissions(List<Permission> permissions) {
  return permissions.map((it) => it.value).toList();
}
