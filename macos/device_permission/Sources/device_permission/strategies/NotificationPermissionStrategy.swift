import UserNotifications

class NotificationPermissionStrategy: NSObject, PermissionStrategy {
    func checkPermissionStatus(permission: PermissionGroup) -> PermissionStatusEnum {
        return NotificationPermissionStrategy.permissionStatus()
    }

    func checkServiceStatus(permission: PermissionGroup, completionHandler: @escaping ServiceStatusHandler) {
        completionHandler(.notApplicable)
    }

    func requestPermission(permission: PermissionGroup, completionHandler: @escaping PermissionStatusHandler, errorHandler: @escaping PermissionErrorHandler) {
        let status = checkPermissionStatus(permission: permission)

        if #available(macOS 10.14, *) {
            if status != .denied && status != .provisional {
                completionHandler(status)
                return
            }
        } else if status != .denied {
            completionHandler(status)
            return
        }

        DispatchQueue.main.async {
            let center = UNUserNotificationCenter.current()
            var authorizationOptions: UNAuthorizationOptions = []
            authorizationOptions.insert(.sound)
            authorizationOptions.insert(.alert)
            authorizationOptions.insert(.badge)

            center.requestAuthorization(options: authorizationOptions) { granted, error in
                if error != nil || !granted {
                    completionHandler(.permanentlyDenied)
                    return
                }

                DispatchQueue.main.async {
                    completionHandler(.granted)
                }
            }
        }
    }

    static func permissionStatus() -> PermissionStatusEnum {
        var permissionStatus: PermissionStatusEnum = .granted
        let semaphore = DispatchSemaphore(value: 0)

        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if #available(macOS 10.14, *) {
                if settings.authorizationStatus == .provisional {
                    permissionStatus = .provisional
                } else if settings.authorizationStatus == .denied {
                    permissionStatus = .permanentlyDenied
                } else if settings.authorizationStatus == .notDetermined {
                    permissionStatus = .denied
                }
            } else {
                if settings.authorizationStatus == .denied {
                    permissionStatus = .permanentlyDenied
                } else if settings.authorizationStatus == .notDetermined {
                    permissionStatus = .denied
                }
            }
            semaphore.signal()
        }
        semaphore.wait()
        return permissionStatus
    }
}
