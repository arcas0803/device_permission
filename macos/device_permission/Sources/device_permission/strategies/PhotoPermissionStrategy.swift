import Photos

class PhotoPermissionStrategy: NSObject, PermissionStrategy {
    private let addOnlyAccess: Bool

    init(addOnlyAccess: Bool) {
        self.addOnlyAccess = addOnlyAccess
    }

    func checkPermissionStatus(permission: PermissionGroup) -> PermissionStatusEnum {
        return PhotoPermissionStrategy.permissionStatus(addOnlyAccess: addOnlyAccess)
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

        if #available(macOS 11.0, *) {
            let accessLevel: PHAccessLevel = addOnlyAccess ? .addOnly : .readWrite
            PHPhotoLibrary.requestAuthorization(for: accessLevel) { authorizationStatus in
                completionHandler(PhotoPermissionStrategy.determinePermissionStatus(authorizationStatus))
            }
        } else {
            PHPhotoLibrary.requestAuthorization { authorizationStatus in
                completionHandler(PhotoPermissionStrategy.determinePermissionStatus(authorizationStatus))
            }
        }
    }

    static func permissionStatus(addOnlyAccess: Bool) -> PermissionStatusEnum {
        let status: PHAuthorizationStatus

        if #available(macOS 11.0, *) {
            let accessLevel: PHAccessLevel = addOnlyAccess ? .addOnly : .readWrite
            status = PHPhotoLibrary.authorizationStatus(for: accessLevel)
        } else {
            status = PHPhotoLibrary.authorizationStatus()
        }

        return determinePermissionStatus(status)
    }

    static func determinePermissionStatus(_ authorizationStatus: PHAuthorizationStatus) -> PermissionStatusEnum {
        switch authorizationStatus {
        case .notDetermined:
            return .denied
        case .restricted:
            return .restricted
        case .denied:
            return .permanentlyDenied
        case .authorized:
            return .granted
        case .limited:
            return .limited
        @unknown default:
            return .denied
        }
    }
}
