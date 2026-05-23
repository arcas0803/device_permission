import CoreTelephony
import UIKit

class PhonePermissionStrategy: NSObject, PermissionStrategy {
    private let cellularData = CTCellularData()

    func checkPermissionStatus(permission: PermissionGroup) -> PermissionStatusEnum {
        return PhonePermissionStrategy.permissionStatus()
    }

    func checkServiceStatus(permission: PermissionGroup, completionHandler: @escaping ServiceStatusHandler) {
        guard let url = URL(string: "tel://") else {
            completionHandler(.notApplicable)
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            let networkInfo = CTTelephonyNetworkInfo()
            if let carrier = networkInfo.subscriberCellularProvider,
               let mnc = carrier.mobileNetworkCode,
               mnc != "0", mnc != "65535" {
                completionHandler(.enabled)
            } else {
                completionHandler(.disabled)
            }
        } else {
            completionHandler(.notApplicable)
        }
    }

    func requestPermission(permission: PermissionGroup, completionHandler: @escaping PermissionStatusHandler, errorHandler: @escaping PermissionErrorHandler) {
        completionHandler(.granted)
    }

    static func permissionStatus() -> PermissionStatusEnum {
        return .granted
    }
}
