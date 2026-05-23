import Flutter
import UIKit

public class DevicePermissionPlugin: NSObject, FlutterPlugin {
    private let permissionManager = PermissionManager()
    private var methodResult: FlutterResult?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.arcas0803.device_permission/permissions",
            binaryMessenger: registrar.messenger()
        )
        let instance = DevicePermissionPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "checkPermissionStatus":
            let permission = Codec.decodePermissionGroup(from: (call.arguments as? Int) ?? 0)
            PermissionManager.checkPermissionStatus(permission: permission, result: result)

        case "checkServiceStatus":
            let permission = Codec.decodePermissionGroup(from: (call.arguments as? Int) ?? 0)
            PermissionManager.checkServiceStatus(permission: permission, result: result)

        case "requestPermissions":
            if methodResult != nil {
                result(FlutterError(
                    code: "ERROR_ALREADY_REQUESTING_PERMISSIONS",
                    message: "A request for permissions is already running, please wait for it to finish before doing another request (note that you can request multiple permissions at the same time).",
                    details: nil
                ))
                return
            }

            methodResult = result
            let permissionValues = (call.arguments as? [Int]) ?? []
            let permissions = permissionValues.map { PermissionGroup(rawValue: $0) ?? .unknown }

            permissionManager.requestPermissions(
                permissions: permissions,
                completion: { [weak self] permissionRequestResults in
                    guard let self = self else { return }
                    if let methodResult = self.methodResult {
                        methodResult(permissionRequestResults)
                    }
                    self.methodResult = nil
                },
                errorHandler: { [weak self] errorCode, errorDescription in
                    guard let self = self else { return }
                    self.methodResult?(FlutterError(code: errorCode, message: errorDescription, details: nil))
                    self.methodResult = nil
                }
            )

        case "shouldShowRequestPermissionRationale":
            result(false)

        case "openAppSettings":
            PermissionManager.openAppSettings(result: result)

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
