import Foundation
import AppKit

class PhonePermissionStrategy: NSObject, PermissionStrategy {
    func checkPermissionStatus(permission: PermissionGroup) -> PermissionStatusEnum {
        return .granted
    }

    func checkServiceStatus(permission: PermissionGroup, completionHandler: @escaping ServiceStatusHandler) {
        completionHandler(.notApplicable)
    }

    func requestPermission(permission: PermissionGroup, completionHandler: @escaping PermissionStatusHandler, errorHandler: @escaping PermissionErrorHandler) {
        completionHandler(.granted)
    }
}
