import Foundation

public struct AppsMetricsStatsPersistenceStrategy: StatsPackagePersistenceStrategy {
    public let handle: String = "a8c-apps-metrics"

    public init() {}

    public func persist(package: StatsPackage, to url: URL, with requestSigner: HttpRequestSigner?) async throws {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let requestSigner {
            request = try await requestSigner.sign(request: request)
        }

        let data = try JSONEncoder().encode([
            "metrics": self.convertPackage(package)
        ])

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

    struct AppsMetricsPair: Encodable {
        let name: String
        let value: KeyValuePair.ValueType
    }

    private func convertPackage(_ package: StatsPackage) -> [AppsMetricsPair] {
        self.keyValuePairs(from: package).map { AppsMetricsPair(name: $0.key, value: $0.value) }
    }

    private func keyValuePairs(from package: StatsPackage) -> [KeyValuePair] {
        let prefix = package.hostname

        return [
            package.cpuLoad?.asKeyValuePairs.prependingKeysWith(prefix + "-cpu-"),
            package.memoryUsage?.asKeyValuePairs.prependingKeysWith(prefix + "-memory-"),
            package.diskUsage?.asKeyValuePairs.prependingKeysWith(prefix + "-disk-"),
            package.networkUsage?.asKeyValuePairs.prependingKeysWith(prefix + "-disk-"),
            package.fanSpeeds.map(\.asKeyValuePair).prependingKeysWith(prefix + "-fanspeed-"),
            package.temperatures.map(\.asKeyValuePair).prependingKeysWith(prefix + "-temperature-")
        ].compactMap { $0 }.reduce(into: [KeyValuePair](), { $0.append(contentsOf: $1)})
        +
        [
            KeyValuePair(key: prefix + "-os-version", value: .double(package.osversion.asDouble))
        ]
    }
}
