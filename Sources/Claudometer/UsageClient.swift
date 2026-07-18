import Foundation

protocol UsageFetching {
    func fetch() async throws -> [UsageLimit]
}

enum UsageError: Error { case unauthorized; case http(Int); case transport(Error) }

final class UsageClient: UsageFetching {
    private let tokenProvider: TokenProviding
    private let transport: (URLRequest) async throws -> (Data, URLResponse)
    private let url = URL(string: "https://api.anthropic.com/api/oauth/usage")!

    init(tokenProvider: TokenProviding,
         transport: @escaping (URLRequest) async throws -> (Data, URLResponse) = { try await URLSession.shared.data(for: $0) }) {
        self.tokenProvider = tokenProvider
        self.transport = transport
    }

    func fetch() async throws -> [UsageLimit] {
        let token = try tokenProvider.accessToken()
        var req = URLRequest(url: url)
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue("oauth-2025-04-20", forHTTPHeaderField: "anthropic-beta")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let data: Data, response: URLResponse
        do { (data, response) = try await transport(req) }
        catch { throw UsageError.transport(error) }

        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            if http.statusCode == 401 { throw UsageError.unauthorized }
            throw UsageError.http(http.statusCode)
        }
        return try makeUsageDecoder().decode(UsageResponse.self, from: data).limits
    }
}
