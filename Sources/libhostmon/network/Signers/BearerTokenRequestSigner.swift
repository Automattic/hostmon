import Foundation

public struct BearerTokenRequestSigner: HttpRequestSigner {

    private let token: String

    public init(token: String) {
        self.token = token
    }

    public func sign(request: URLRequest) async throws -> URLRequest {
        var mutableRequest = request
        mutableRequest.setValue("Bearer " + self.token, forHTTPHeaderField: "Authorization")
        return mutableRequest
    }
}
