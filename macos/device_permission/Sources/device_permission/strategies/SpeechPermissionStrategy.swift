import Speech

class SpeechPermissionStrategy: NSObject, PermissionStrategy {
    func checkPermissionStatus(permission: PermissionGroup) -> PermissionStatusEnum {
        return SpeechPermissionStrategy.permissionStatus()
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

        SFSpeechRecognizer.requestAuthorization { authorizationStatus in
            completionHandler(SpeechPermissionStrategy.determinePermissionStatus(authorizationStatus))
        }
    }

    static func permissionStatus() -> PermissionStatusEnum {
        let status = SFSpeechRecognizer.authorizationStatus()
        return determinePermissionStatus(status)
    }

    static func determinePermissionStatus(_ status: SFSpeechRecognizerAuthorizationStatus) -> PermissionStatusEnum {
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
