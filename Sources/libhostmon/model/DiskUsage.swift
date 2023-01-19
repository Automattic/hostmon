import Foundation

public struct DiskUsage: Codable {
    public let availableCapacity: UInt64
    public let totalCapacity: UInt64
}
