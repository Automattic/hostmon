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
}
