import Foundation

enum PermissionGroup: Int, CaseIterable {
    case calendar = 0
    case camera
    case contacts
    case location
    case locationAlways
    case locationWhenInUse
    case mediaLibrary
    case microphone
    case phone
    case photos
    case photosAddOnly
    case reminders
    case sensors
    case sms
    case speech
    case storage
    case ignoreBatteryOptimizations
    case notification
    case accessMediaLocation
    case activityRecognition
    case unknown
    case bluetooth
    case manageExternalStorage
    case systemAlertWindow
    case requestInstallPackages
    case appTrackingTransparency
    case criticalAlerts
    case accessNotificationPolicy
    case bluetoothScan
    case bluetoothAdvertise
    case bluetoothConnect
    case nearbyWifiDevices
    case videos
    case audio
    case scheduleExactAlarm
    case sensorsAlways
    case calendarWriteOnly
    case calendarFullAccess
    case assistant
    case backgroundRefresh
}

enum PermissionStatusEnum: Int {
    case denied = 0
    case granted = 1
    case restricted = 2
    case limited = 3
    case permanentlyDenied = 4
    case provisional = 5
}

enum ServiceStatusEnum: Int {
    case disabled = 0
    case enabled = 1
    case notApplicable = 2
}
