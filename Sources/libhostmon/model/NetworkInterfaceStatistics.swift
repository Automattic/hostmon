import Foundation

public struct NetworkInterfaceStatistics {
    public let bytesSent: UInt32
    public let bytesReceived: UInt32

    public let timestamp: Int = Int(Date().timeIntervalSince1970)

    enum Errors: Error {
        case unableToReadStatisticsForNonLinkLayerInterface
    }

    static func from(_ pointer: UnsafeMutablePointer<ifaddrs>) throws -> NetworkInterfaceStatistics {

        /// We can't collect metrics for non-link-layer interfaces, so we won't try to convert those
        guard pointer.pointee.ifa_addr.pointee.sa_family == AF_LINK else {
            throw Errors.unableToReadStatisticsForNonLinkLayerInterface
        }

        let networkData = unsafeBitCast(pointer.pointee.ifa_data, to: UnsafeMutablePointer<if_data>.self)

        return NetworkInterfaceStatistics(
            bytesSent: networkData.pointee.ifi_obytes,
            bytesReceived: networkData.pointee.ifi_ibytes
        )
    }
}

extension NetworkInterfaceStatistics: AdditiveArithmetic {
    public static var zero = NetworkInterfaceStatistics(bytesSent: 0, bytesReceived: 0)

    public static func + (
        lhs: NetworkInterfaceStatistics,
        rhs: NetworkInterfaceStatistics
    ) -> NetworkInterfaceStatistics {
        NetworkInterfaceStatistics(
            bytesSent: lhs.bytesSent + rhs.bytesSent,
            bytesReceived: lhs.bytesReceived + rhs.bytesReceived
        )
    }

    public static func - (
        lhs: NetworkInterfaceStatistics,
        rhs: NetworkInterfaceStatistics
    ) -> NetworkInterfaceStatistics {
        NetworkInterfaceStatistics(
            bytesSent: lhs.bytesSent - rhs.bytesSent,
            bytesReceived: lhs.bytesReceived - rhs.bytesReceived
        )
    }

}
