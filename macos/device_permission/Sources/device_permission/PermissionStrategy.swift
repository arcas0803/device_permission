import Foundation

typealias ServiceStatusHandler = (ServiceStatusEnum) -> Void
typealias PermissionStatusHandler = (PermissionStatusEnum) -> Void
typealias PermissionErrorHandler = (String, String) -> Void

protocol PermissionStrategy: AnyObject {
    func checkPermissionStatus(permission: PermissionGroup) -> PermissionStatusEnum
    func checkServiceStatus(permission: PermissionGroup, completionHandler: @escaping ServiceStatusHandler)
    func requestPermission(permission: PermissionGroup, completionHandler: @escaping PermissionStatusHandler, errorHandler: @escaping PermissionErrorHandler)
}
