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

    private func convertPackage(_ package: StatsPackage) -> [KeyValuePair] {
        var metrics = [String: Double]()

        let prefix = package.hostname

        package.cpuLoad?.asDictionary.forEach { metrics[ prefix + "-cpu-" + $0.key] = $0.value }
        package.memoryUsage?.asDictionary.forEach { metrics[ prefix + "-memory-" + $0.key] = Double($0.value) }
        package.diskUsage?.asDictionary.forEach { metrics[ prefix + "-disk-" + $0.key] = Double($0.value) }
        package.networkUsage?.asDictionary.forEach { metrics[ prefix + "-network-" + $0.key] = $0.value }
        package.fanSpeeds.forEach { metrics[prefix + "-fanspeed-" + $0.fanName] = Double($0.rpm) }
        package.temperatures.forEach { metrics[prefix + "-temperature-" + $0.sensorName] = Double($0.temperature) }

        metrics[prefix + "-os-version"] = package.osversion.asDouble

        return metrics.map {
            KeyValuePair(name: $0.key, value: $0.value)
        }
    }

    struct KeyValuePair: Encodable {
        let name: String
        let value: Double
    }
}
