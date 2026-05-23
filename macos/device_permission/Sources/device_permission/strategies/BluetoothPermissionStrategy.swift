import CoreBluetooth

class BluetoothPermissionStrategy: NSObject, PermissionStrategy, CBPeripheralManagerDelegate {
    private var permissionStatusHandler: PermissionStatusHandler?
    private var peripheralManager: CBPeripheralManager?

    func checkPermissionStatus(permission: PermissionGroup) -> PermissionStatusEnum {
        return BluetoothPermissionStrategy.permissionStatus()
    }

    func checkServiceStatus(permission: PermissionGroup, completionHandler: @escaping ServiceStatusHandler) {
        let manager = CBPeripheralManager(delegate: nil, queue: nil)
        let isEnabled = manager.state == .poweredOn
        completionHandler(isEnabled ? .enabled : .disabled)
    }

    func requestPermission(permission: PermissionGroup, completionHandler: @escaping PermissionStatusHandler, errorHandler: @escaping PermissionErrorHandler) {
        let status = checkPermissionStatus(permission: permission)
        if status != .denied {
            completionHandler(status)
            return
        }

        permissionStatusHandler = completionHandler
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .unauthorized || peripheral.state == .poweredOff {
            permissionStatusHandler?(.permanentlyDenied)
        } else if peripheral.state == .poweredOn {
            permissionStatusHandler?(.granted)
        } else if peripheral.state == .unsupported {
            permissionStatusHandler?(.restricted)
        }
        peripheralManager = nil
        permissionStatusHandler = nil
    }

    static func permissionStatus() -> PermissionStatusEnum {
        if #available(macOS 10.15, *) {
            let manager = CBPeripheralManager()
            switch manager.authorization {
            case .notDetermined:
                return .denied
            case .restricted:
                return .restricted
            case .denied:
                return .permanentlyDenied
            case .allowedAlways:
                return .granted
            @unknown default:
                return .denied
            }
        }
        return .granted
    }
}
