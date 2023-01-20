import Foundation

public struct DiskUsage: Codable {
    public let availableCapacity: UInt64
    public let totalCapacity: UInt64

    var asDictionary: [String: UInt64] {
        [
            "available": self.availableCapacity,
            "total": self.totalCapacity
        ]
    }
}
