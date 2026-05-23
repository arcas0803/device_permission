import UIKit

class BackgroundRefreshStrategy: NSObject, PermissionStrategy {
    func checkPermissionStatus(permission: PermissionGroup) -> PermissionStatusEnum {
        return BackgroundRefreshStrategy.permissionStatus()
    }

    func checkServiceStatus(permission: PermissionGroup, completionHandler: @escaping ServiceStatusHandler) {
        completionHandler(.notApplicable)
    }

    func requestPermission(permission: PermissionGroup, completionHandler: @escaping PermissionStatusHandler, errorHandler: @escaping PermissionErrorHandler) {
        completionHandler(.permanentlyDenied)
    }

    static func permissionStatus() -> PermissionStatusEnum {
        let status = UIApplication.shared.backgroundRefreshStatus
        switch status {
        case .available:
            return .granted
        case .denied:
            return .permanentlyDenied
        case .restricted:
            return .restricted
        @unknown default:
            return .denied
        }
    }
}
