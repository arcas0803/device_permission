import CoreLocation
import AppKit

class LocationPermissionStrategy: NSObject, PermissionStrategy, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var permissionStatusHandler: PermissionStatusHandler?
    private var requestedPermission: PermissionGroup?
    private var previousStatusWasNotDetermined = false

    private static let userDefaultPermissionRequestedKey = "org.arcas0803.device_permission.permission_requested"

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func checkPermissionStatus(permission: PermissionGroup) -> PermissionStatusEnum {
        return LocationPermissionStrategy.permissionStatus(permission: permission)
    }

    func checkServiceStatus(permission: PermissionGroup, completionHandler: @escaping ServiceStatusHandler) {
        DispatchQueue.global(qos: .default).async {
            let isEnabled = CLLocationManager.locationServicesEnabled()
            DispatchQueue.main.async {
                completionHandler(isEnabled ? .enabled : .disabled)
            }
        }
    }

    func requestPermission(permission: PermissionGroup, completionHandler: @escaping PermissionStatusHandler, errorHandler: @escaping PermissionErrorHandler) {
        let status = checkPermissionStatus(permission: permission)

        if status != .denied {
            completionHandler(status)
            return
        }

        permissionStatusHandler = completionHandler
        requestedPermission = permission

        #if os(iOS)
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse && permission == .locationAlways {
            let alreadyRequested = UserDefaults.standard.bool(forKey: LocationPermissionStrategy.userDefaultPermissionRequestedKey)
            if alreadyRequested {
                completionHandler(status)
                return
            }
        }

        switch permission {
        case .location:
            let hasAlways = Bundle.main.object(forInfoDictionaryKey: "NSLocationAlwaysUsageDescription") != nil ||
                Bundle.main.object(forInfoDictionaryKey: "NSLocationAlwaysAndWhenInUseUsageDescription") != nil

            if hasAlways && CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                locationManager.requestAlwaysAuthorization()
            } else if Bundle.main.object(forInfoDictionaryKey: "NSLocationWhenInUseUsageDescription") != nil {
                locationManager.requestWhenInUseAuthorization()
            } else {
                errorHandler(
                    "MISSING_USAGE_DESCRIPTION",
                    "To use location from iOS8 you need to define at least NSLocationWhenInUseUsageDescription and optionally NSLocationAlwaysAndWhenInUseUsageDescription in the app bundle's Info.plist file"
                )
            }

        case .locationAlways:
            if CLLocationManager.authorizationStatus() == .notDetermined {
                errorHandler(
                    "MISSING_WHENINUSE_PERMISSION",
                    "Must have \"When in use\" permission before it is allowed to request \"Always\" permission."
                )
                return
            }

            if Bundle.main.object(forInfoDictionaryKey: "NSLocationAlwaysUsageDescription") != nil ||
                Bundle.main.object(forInfoDictionaryKey: "NSLocationAlwaysAndWhenInUseUsageDescription") != nil {
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(receiveActivityNotification),
                    name: NSApplication.didBecomeActiveNotification,
                    object: nil
                )
                locationManager.requestAlwaysAuthorization()
                UserDefaults.standard.set(true, forKey: LocationPermissionStrategy.userDefaultPermissionRequestedKey)
            } else {
                errorHandler(
                    "MISSING_USAGE_DESCRIPTION",
                    "To always use location from iOS8 you need to define NSLocationAlwaysAndWhenInUseUsageDescription in the app bundle's Info.plist file"
                )
            }

        case .locationWhenInUse:
            if Bundle.main.object(forInfoDictionaryKey: "NSLocationWhenInUseUsageDescription") != nil {
                locationManager.requestWhenInUseAuthorization()
            } else {
                errorHandler(
                    "MISSING_USAGE_DESCRIPTION",
                    "To use location from iOS8 you need to define at least NSLocationWhenInUseUsageDescription in the app bundle's Info.plist file"
                )
            }

        default:
            completionHandler(.denied)
        }
        #else
        locationManager.requestAlwaysAuthorization()
        #endif
    }

    @objc private func receiveActivityNotification(_ notification: Notification) {
        let status: CLAuthorizationStatus
        if #available(macOS 11.0, *) {
            status = locationManager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }

        if requestedPermission == .locationAlways && status != .authorizedAlways && status != .authorized {
            let permStatus = LocationPermissionStrategy.determinePermissionStatus(
                permission: .locationAlways,
                authorizationStatus: status
            )
            permissionStatusHandler?(permStatus)
        }
        NotificationCenter.default.removeObserver(self, name: NSApplication.didBecomeActiveNotification, object: nil)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard let handler = permissionStatusHandler, let permission = requestedPermission else { return }

        if status == .notDetermined {
            if previousStatusWasNotDetermined {
                handler(.denied)
            }
            previousStatusWasNotDetermined = true
            return
        }
        previousStatusWasNotDetermined = false

        #if os(iOS)
        if permission == .locationAlways && status == .authorizedWhenInUse {
            handler(.denied)
            return
        }
        #endif

        let permStatus = LocationPermissionStrategy.determinePermissionStatus(
            permission: permission,
            authorizationStatus: status
        )
        handler(permStatus)
    }

    static func permissionStatus(permission: PermissionGroup) -> PermissionStatusEnum {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        return determinePermissionStatus(permission: permission, authorizationStatus: authorizationStatus)
    }

    static func determinePermissionStatus(permission: PermissionGroup, authorizationStatus: CLAuthorizationStatus) -> PermissionStatusEnum {
        #if os(iOS)
        if permission == .locationAlways {
            switch authorizationStatus {
            case .notDetermined:
                return .denied
            case .restricted:
                return .restricted
            case .authorizedWhenInUse, .denied:
                return .permanentlyDenied
            case .authorizedAlways:
                return .granted
            @unknown default:
                return .denied
            }
        }

        switch authorizationStatus {
        case .notDetermined:
            return .denied
        case .restricted:
            return .restricted
        case .denied:
            return .permanentlyDenied
        case .authorizedWhenInUse, .authorizedAlways:
            return .granted
        @unknown default:
            return .denied
        }
        #else
        switch authorizationStatus {
        case .notDetermined:
            return .denied
        case .restricted:
            return .restricted
        case .denied:
            return .permanentlyDenied
        case .authorized:
            return .granted
        case .authorizedAlways:
            return .granted
        @unknown default:
            return .denied
        }
        #endif
    }
}
