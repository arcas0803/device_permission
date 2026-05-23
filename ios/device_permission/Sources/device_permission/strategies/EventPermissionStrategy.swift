import EventKit

class EventPermissionStrategy: NSObject, PermissionStrategy {
    private let eventStore = EKEventStore()

    func checkPermissionStatus(permission: PermissionGroup) -> PermissionStatusEnum {
        let entityType: EKEntityType
        switch permission {
        case .calendar, .calendarWriteOnly, .calendarFullAccess:
            entityType = .event
        case .reminders:
            entityType = .reminder
        default:
            entityType = .event
        }
        let status = EKEventStore.authorizationStatus(for: entityType)
        return EventPermissionStrategy.determinePermissionStatus(status)
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

        let entityType: EKEntityType = (permission == .reminders) ? .reminder : .event
        eventStore.requestAccess(to: entityType) { granted, error in
            if error != nil || !granted {
                completionHandler(.permanentlyDenied)
            } else {
                completionHandler(.granted)
            }
        }
    }

    static func determinePermissionStatus(_ status: EKAuthorizationStatus) -> PermissionStatusEnum {
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
