import Foundation

public protocol StatsPackagePersistenceStrategy {
    /// The handle used to invoke this uploader from the command line
    var handle: String { get }

    /// Uploads the package to the service specified by this implementation
    func persist(package: StatsPackage, to url: URL, with requestSigner: HttpRequestSigner?) async throws
}

public protocol HttpRequestSigner {
    /// Mutates the request to be acceptable by the server
    func sign(request: URLRequest) async throws -> URLRequest
}
