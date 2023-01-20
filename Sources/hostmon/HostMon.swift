import Foundation
import ArgumentParser
import libhostmon

@main
struct HostMonApplication: AsyncParsableCommand {

    private static let storageStrategies: [StatsPackagePersistenceStrategy] = [
        DefaultStatsPackageUploader(),
        AppsMetricsStatsPersistenceStrategy()
    ]

    static var configuration = CommandConfiguration(
        abstract: "A utility for monitoring Mac hardware metrics",
        version: "1.0.0"
    )

    enum Errors: Error {
        case invalidEndpointUrl
        case invalidStorageStrategy
    }

    @Option(help: "The network interface to collect metrics for.")
    var networkInterfaceToMonitor: String = "en0"

    @Option(help: "The URL endpoint that will receive metrics")
    var uploadUrl: String

    @Option(help: "A value used to provide authorization to the metrics endpoint")
    var bearerToken: String?

    @Option(name: .long, help: "How frequently to send metrics to the server")
    var interval: UInt64 = 60

    @Option(
        name: .long,
        help: "The storage strategy used to persist metrics",
        completion: .list(Self.storageStrategies.map(\.handle))
    )
    var storageStrategy: String = DefaultStatsPackageUploader().handle

    mutating func run() async throws {
        let hostStatistics = HostStatistics()

        guard let url = URL(string: self.uploadUrl) else {
            Self.exit(withError: Errors.invalidEndpointUrl)
        }

        guard let storageStrategy = Self.storageStrategies.first(where: { $0.handle == self.storageStrategy }) else {
            Self.exit(withError: Errors.invalidStorageStrategy)
        }

        var requestSigner: HttpRequestSigner?

        if let bearerToken {
            requestSigner = BearerTokenRequestSigner(token: bearerToken)
        }

        while true {
            let statsPackage = try StatsPackage(
                cpuLoad: hostStatistics.cpuLoad,
                memoryUsage: hostStatistics.memoryUsage,
                diskUsage: hostStatistics.diskUsage(),
                networkUsage: hostStatistics.networkStatistics(forInterfaceNamed: "en0"),
                temperatures: hostStatistics.temperatureSensorValues(),
                fanSpeeds: hostStatistics.fanSpeedValues()
            )

            try await storageStrategy.persist(package: statsPackage, to: url, with: requestSigner)
            try await Task.sleep(nanoseconds: NSEC_PER_SEC * self.interval)
        }
    }
}
