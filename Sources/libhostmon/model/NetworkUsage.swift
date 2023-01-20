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

    var asKeyValuePairs: [KeyValuePair] {
        [
            KeyValuePair(key: "bytes-sent", value: .uInt32(self.bytesSent)),
            KeyValuePair(key: "bytes-received", value: .uInt32(self.bytesReceieved)),
            KeyValuePair(key: "timeframe", value: .timeInterval(self.timeframe)),
            KeyValuePair(key: "bytes-sent-per-second", value: .double(Double(self.bytesSent) / self.timeframe)),
            KeyValuePair(key: "bytes-received-per-second", value: .double(Double(self.bytesReceieved) / self.timeframe))
        ]
    }
}
