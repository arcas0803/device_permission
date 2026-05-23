import CoreMotion
import Foundation

class SensorPermissionStrategy: NSObject, PermissionStrategy {
    func checkPermissionStatus(permission: PermissionGroup) -> PermissionStatusEnum {
        return SensorPermissionStrategy.permissionStatus()
    }

    func checkServiceStatus(permission: PermissionGroup, completionHandler: @escaping ServiceStatusHandler) {
        completionHandler(.notApplicable)
    }

    func requestPermission(permission: PermissionGroup, completionHandler: @escaping PermissionStatusHandler, errorHandler: @escaping PermissionErrorHandler) {
        completionHandler(.denied)
    }

    static func permissionStatus() -> PermissionStatusEnum {
        return .denied
    }
}
