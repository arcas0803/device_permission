import Foundation

struct Codec {
    static func decodePermissionGroup(from value: Int) -> PermissionGroup {
        return PermissionGroup(rawValue: value) ?? .unknown
    }

    static func decodePermissionGroups(from values: [Int]) -> [PermissionGroup] {
        return values.map { decodePermissionGroup(from: $0) }
    }

    static func encodePermissionStatus(_ status: PermissionStatusEnum) -> Int {
        return status.rawValue
    }

    static func encodeServiceStatus(_ status: ServiceStatusEnum) -> Int {
        return status.rawValue
    }
}
