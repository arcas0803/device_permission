import CoreMotion

class SensorPermissionStrategy: NSObject, PermissionStrategy {
    private let motionActivityManager = CMMotionActivityManager()

    func checkPermissionStatus(permission: PermissionGroup) -> PermissionStatusEnum {
        return SensorPermissionStrategy.permissionStatus()
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

        if CMMotionActivityManager.isActivityAvailable() {
            let now = Date()
            motionActivityManager.queryActivityStarting(from: now, to: now, to: .main) { _, error in
                if error != nil {
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
        if #available(iOS 11.0, *) {
            let status = CMMotionActivityManager.authorizationStatus()
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
        return .granted
    }
}
