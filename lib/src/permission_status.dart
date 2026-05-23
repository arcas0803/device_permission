/// Defines the state of a [Permission].
enum PermissionStatus {
  denied,
  granted,
  restricted,
  limited,
  permanentlyDenied,
  provisional,
}

extension PermissionStatusValue on PermissionStatus {
  int get value {
    switch (this) {
      case PermissionStatus.denied:
        return 0;
      case PermissionStatus.granted:
        return 1;
      case PermissionStatus.restricted:
        return 2;
      case PermissionStatus.limited:
        return 3;
      case PermissionStatus.permanentlyDenied:
        return 4;
      case PermissionStatus.provisional:
        return 5;
    }
  }

  static PermissionStatus statusByValue(int value) {
    return [
      PermissionStatus.denied,
      PermissionStatus.granted,
      PermissionStatus.restricted,
      PermissionStatus.limited,
      PermissionStatus.permanentlyDenied,
      PermissionStatus.provisional,
    ][value];
  }
}

extension PermissionStatusGetters on PermissionStatus {
  bool get isDenied => this == PermissionStatus.denied;
  bool get isGranted => this == PermissionStatus.granted;
  bool get isRestricted => this == PermissionStatus.restricted;
  bool get isPermanentlyDenied => this == PermissionStatus.permanentlyDenied;
  bool get isLimited => this == PermissionStatus.limited;
  bool get isProvisional => this == PermissionStatus.provisional;
}

extension FuturePermissionStatusGetters on Future<PermissionStatus> {
  Future<bool> get isGranted async => (await this).isGranted;
  Future<bool> get isDenied async => (await this).isDenied;
  Future<bool> get isRestricted async => (await this).isRestricted;
  Future<bool> get isPermanentlyDenied async =>
      (await this).isPermanentlyDenied;
  Future<bool> get isLimited async => (await this).isLimited;
  Future<bool> get isProvisional async => (await this).isProvisional;
}
