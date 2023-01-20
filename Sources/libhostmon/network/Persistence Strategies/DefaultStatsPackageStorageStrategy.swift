import Foundation

public struct DefaultStatsPackageUploader: StatsPackagePersistenceStrategy {
    public let handle: String = "default"

    let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    public init() {}

    public func persist(package: StatsPackage, to url: URL, with requestSigner: HttpRequestSigner?) async throws {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        try await requestSigner?.sign(request: request)

        let data = try self.jsonEncoder.encode(package)

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
