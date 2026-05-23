enum ServiceStatus {
  disabled,
  enabled,
  notApplicable,
}

extension ServiceStatusValue on ServiceStatus {
  int get value {
    switch (this) {
      case ServiceStatus.disabled:
        return 0;
      case ServiceStatus.enabled:
        return 1;
      case ServiceStatus.notApplicable:
        return 2;
    }
  }

  static ServiceStatus statusByValue(int value) {
    return [
      ServiceStatus.disabled,
      ServiceStatus.enabled,
      ServiceStatus.notApplicable,
    ][value];
  }
}

extension ServiceStatusGetters on ServiceStatus {
  bool get isDisabled => this == ServiceStatus.disabled;
  bool get isEnabled => this == ServiceStatus.enabled;
  bool get isNotApplicable => this == ServiceStatus.notApplicable;
}

extension FutureServiceStatusGetters on Future<ServiceStatus> {
  Future<bool> get isDisabled async => (await this).isDisabled;
  Future<bool> get isEnabled async => (await this).isEnabled;
  Future<bool> get isNotApplicable async => (await this).isNotApplicable;
}
