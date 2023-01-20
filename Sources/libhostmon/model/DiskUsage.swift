import Foundation

public struct DiskUsage: Codable {
    public let availableCapacity: UInt64
    public let totalCapacity: UInt64

    var asKeyValuePairs: [KeyValuePair] {
        [
            KeyValuePair(key: "available", value: .uInt64(self.availableCapacity)),
            KeyValuePair(key: "total", value: .uInt64(self.totalCapacity))
        ]
    }
}
