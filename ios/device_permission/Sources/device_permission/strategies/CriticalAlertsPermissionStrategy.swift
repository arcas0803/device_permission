import UserNotifications

class CriticalAlertsPermissionStrategy: NSObject, PermissionStrategy {
    func checkPermissionStatus(permission: PermissionGroup) -> PermissionStatusEnum {
        return CriticalAlertsPermissionStrategy.permissionStatus()
    }

    func checkServiceStatus(permission: PermissionGroup, completionHandler: @escaping ServiceStatusHandler) {
        completionHandler(.notApplicable)
    }

    func requestPermission(permission: PermissionGroup, completionHandler: @escaping PermissionStatusHandler, errorHandler: @escaping PermissionErrorHandler) {
        let status = checkPermissionStatus(permission: permission)
        if status != .denied {
            completionHandler(status)
            return
        }

        if #available(iOS 12.0, *) {
            let center = UNUserNotificationCenter.current()
            var options: UNAuthorizationOptions = [.sound, .alert, .badge]
            if #available(iOS 15.0, *) {
                options.insert(.criticalAlert)
            }

            center.requestAuthorization(options: options) { granted, error in
                if error != nil || !granted {
                    completionHandler(.permanentlyDenied)
                } else {
                    completionHandler(.granted)
                }
            }
        } else {
            completionHandler(.permanentlyDenied)
        }
    }

    static func permissionStatus() -> PermissionStatusEnum {
        var permissionStatus: PermissionStatusEnum = .denied
        let semaphore = DispatchSemaphore(value: 0)

        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if #available(iOS 12.0, *) {
                if settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional {
                    permissionStatus = .granted
                } else if settings.authorizationStatus == .denied {
                    permissionStatus = .permanentlyDenied
                } else {
                    permissionStatus = .denied
                }
            }
            semaphore.signal()
        }
        semaphore.wait()
        return permissionStatus
    }
}
