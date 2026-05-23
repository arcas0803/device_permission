import AppTrackingTransparency

@available(iOS 14.0, *)
class AppTrackingTransparencyPermissionStrategy: NSObject, PermissionStrategy {
    func checkPermissionStatus(permission: PermissionGroup) -> PermissionStatusEnum {
        return AppTrackingTransparencyPermissionStrategy.permissionStatus()
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

        ATTrackingManager.requestTrackingAuthorization { authorizationStatus in
            completionHandler(AppTrackingTransparencyPermissionStrategy.determinePermissionStatus(authorizationStatus))
        }
    }

    static func permissionStatus() -> PermissionStatusEnum {
        let status = ATTrackingManager.trackingAuthorizationStatus
        return determinePermissionStatus(status)
    }

    static func determinePermissionStatus(_ status: ATTrackingManager.AuthorizationStatus) -> PermissionStatusEnum {
        switch status {
        case .notDetermined:
            return .denied
        case .restricted:
            return .restricted
        case .denied:
            return .permanentlyDenied
        case .authorized:
            return .granted
        @unknown default:
            return .denied
        }
    }
}
