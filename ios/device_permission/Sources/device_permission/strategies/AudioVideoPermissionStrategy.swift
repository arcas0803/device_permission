import AVFoundation

class AudioVideoPermissionStrategy: NSObject, PermissionStrategy {
    func checkPermissionStatus(permission: PermissionGroup) -> PermissionStatusEnum {
        if permission == .camera {
            return AudioVideoPermissionStrategy.permissionStatus(for: .video)
        } else if permission == .microphone {
            return AudioVideoPermissionStrategy.permissionStatus(for: .audio)
        }
        return .denied
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

        let mediaType: AVMediaType

        if permission == .camera {
            mediaType = .video
        } else if permission == .microphone {
            mediaType = .audio
        } else {
            completionHandler(.denied)
            return
        }

        AVCaptureDevice.requestAccess(for: mediaType) { granted in
            if granted {
                completionHandler(.granted)
            } else {
                completionHandler(.permanentlyDenied)
            }
        }
    }

    static func permissionStatus(for mediaType: AVMediaType) -> PermissionStatusEnum {
        let status = AVCaptureDevice.authorizationStatus(for: mediaType)
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
