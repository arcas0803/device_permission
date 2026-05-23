import MediaPlayer

class MediaLibraryPermissionStrategy: NSObject, PermissionStrategy {
    func checkPermissionStatus(permission: PermissionGroup) -> PermissionStatusEnum {
        return MediaLibraryPermissionStrategy.permissionStatus()
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

        if #available(iOS 9.3, *) {
            MPMediaLibrary.requestAuthorization { authorizationStatus in
                completionHandler(MediaLibraryPermissionStrategy.determinePermissionStatus(authorizationStatus))
            }
        } else {
            completionHandler(.permanentlyDenied)
        }
    }

    static func permissionStatus() -> PermissionStatusEnum {
        if #available(iOS 9.3, *) {
            let status = MPMediaLibrary.authorizationStatus()
            return determinePermissionStatus(status)
        }
        return .granted
    }

    static func determinePermissionStatus(_ status: MPMediaLibraryAuthorizationStatus) -> PermissionStatusEnum {
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
