import Foundation
import UIKit
import Flutter

class PermissionManager: NSObject {

    static func checkPermissionStatus(permission: PermissionGroup, result: @escaping FlutterResult) {
        let strategy = PermissionManager.createPermissionStrategy(permission: permission)
        let status = strategy.checkPermissionStatus(permission: permission)
        result(Codec.encodePermissionStatus(status))
    }

    static func checkServiceStatus(permission: PermissionGroup, result: @escaping FlutterResult) {
        let strategy = PermissionManager.createPermissionStrategy(permission: permission)
        strategy.checkServiceStatus(permission: permission) { serviceStatus in
            result(Codec.encodeServiceStatus(serviceStatus))
        }
    }

    private var strategyInstances: [PermissionStrategy] = []

    func requestPermissions(
        permissions: [PermissionGroup],
        completion: @escaping ([Int: Int]) -> Void,
        errorHandler: @escaping (String, String) -> Void
    ) {
        var permissionStatusResult = [Int: Int]()

        if permissions.isEmpty {
            completion(permissionStatusResult)
            return
        }

        var requestQueue = Set(permissions.map { $0.rawValue })

        for permission in permissions {
            let strategy = PermissionManager.createPermissionStrategy(permission: permission)
            strategyInstances.append(strategy)

            strategy.requestPermission(
                permission: permission,
                completionHandler: { [weak self] permissionStatus in
                    guard let self = self else { return }
                    permissionStatusResult[permission.rawValue] = permissionStatus.rawValue
                    requestQueue.remove(permission.rawValue)

                    self.strategyInstances.removeAll { ($0 as AnyObject) === (strategy as AnyObject) }

                    if requestQueue.isEmpty {
                        completion(permissionStatusResult)
                    }
                },
                errorHandler: { errorCode, errorDescription in
                    errorHandler(errorCode, errorDescription)
                }
            )
        }
    }

    static func openAppSettings(result: @escaping FlutterResult) {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            result(false)
            return
        }
        UIApplication.shared.open(url, options: [:]) { success in
            result(success)
        }
    }

    static func createPermissionStrategy(permission: PermissionGroup) -> any PermissionStrategy {
        switch permission {
        case .calendar, .calendarWriteOnly, .calendarFullAccess:
            return EventPermissionStrategy()
        case .camera, .microphone:
            return AudioVideoPermissionStrategy()
        case .contacts:
            return ContactPermissionStrategy()
        case .location, .locationAlways, .locationWhenInUse:
            return LocationPermissionStrategy()
        case .mediaLibrary:
            return MediaLibraryPermissionStrategy()
        case .phone:
            return PhonePermissionStrategy()
        case .photos:
            return PhotoPermissionStrategy(addOnlyAccess: false)
        case .photosAddOnly:
            return PhotoPermissionStrategy(addOnlyAccess: true)
        case .reminders:
            return EventPermissionStrategy()
        case .sensors:
            return SensorPermissionStrategy()
        case .speech:
            return SpeechPermissionStrategy()
        case .notification:
            return NotificationPermissionStrategy()
        case .storage:
            return StoragePermissionStrategy()
        case .bluetooth:
            return BluetoothPermissionStrategy()
        case .appTrackingTransparency:
            if #available(iOS 14.0, *) {
                return AppTrackingTransparencyPermissionStrategy()
            }
            return UnknownPermissionStrategy()
        case .criticalAlerts:
            return CriticalAlertsPermissionStrategy()
        case .assistant:
            return AssistantPermissionStrategy()
        case .backgroundRefresh:
            return BackgroundRefreshStrategy()
        default:
            return UnknownPermissionStrategy()
        }
    }
}
