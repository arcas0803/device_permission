import Contacts

class ContactPermissionStrategy: NSObject, PermissionStrategy {
    func checkPermissionStatus(permission: PermissionGroup) -> PermissionStatusEnum {
        return ContactPermissionStrategy.permissionStatus()
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

        let contactStore = CNContactStore()
        contactStore.requestAccess(for: .contacts) { granted, error in
            if error != nil || !granted {
                completionHandler(.permanentlyDenied)
            } else {
                completionHandler(.granted)
            }
        }
    }

    static func permissionStatus() -> PermissionStatusEnum {
        let status = CNContactStore.authorizationStatus(for: .contacts)
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
