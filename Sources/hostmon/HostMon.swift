import Foundation
import ArgumentParser
import libhostmon

@main
struct HostMonApplication: AsyncParsableCommand {

    static var configuration = CommandConfiguration(
        abstract: "A utility for monitoring Mac hardware metrics",
        version: "1.0.0"
    )

    enum Errors: Error {
        case invalidEndpointUrl
    }

    @Option(help: "The network interface to collect metrics for.")
    var networkInterfaceToMonitor: String = "en0"

    @Option(help: "The URL endpoint that will receive metrics")
    var uploadUrl: String

    @Option(name: .long, help: "How frequently to send metrics to the server")
    var interval: UInt64 = 60

    lazy var jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    mutating func run() async throws {
        let hostStatistics = HostStatistics()

        guard let url = URL(string: self.uploadUrl) else {
            Self.exit(withError: Errors.invalidEndpointUrl)
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

            let data = try self.jsonEncoder.encode(statsPackage)
            try await self.sendMetrics(data, to: url)
            try await Task.sleep(nanoseconds: NSEC_PER_SEC * self.interval)
        }
    }

    private func sendMetrics(_ data: Data, to url: URL) async throws {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let (body, response) = try await URLSession.shared.upload(for: request, from: data)

        print("===Metrics Uploaded===")
        print("Server Response:")
        if let response = response as? HTTPURLResponse {
            for (key, value) in response.allHeaderFields {
                print(  "\(key): \(value)")
            }
        }

        if let body = String(data: body, encoding: .utf8) {
            print(body)
        }

        print("=====================")
        print("")
    }
}
