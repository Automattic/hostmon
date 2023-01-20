import Foundation

public struct NetworkUsage: Codable {

    public let bytesSent: UInt32
    public let bytesReceieved: UInt32

    let timeframe: TimeInterval

    public init(
        currentUsageStatistics current: NetworkInterfaceStatistics,
        previousUsageStatistics previous: NetworkInterfaceStatistics
    ) {
        self.bytesSent = current.bytesSent - previous.bytesSent
        self.bytesReceieved = current.bytesReceived - previous.bytesReceived
        self.timeframe = TimeInterval(current.timestamp - previous.timestamp)
    }

    var asDictionary: [String: Double] {
        [
            "bytes-sent": Double(self.bytesSent),
            "bytes-received": Double(self.bytesReceieved),

            "bytes-sent-per-second": Double(self.bytesSent) / self.timeframe,
            "bytes-received-per-second": Double(self.bytesReceieved) / self.timeframe
        ]
    }
}
