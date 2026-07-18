import Foundation
import Testing
@testable import Claudometer

private struct StubToken: TokenProviding {
    var token = "sk-test"
    func accessToken() throws -> String { token }
}

struct UsageClientTests {
    private func http(_ code: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: URL(string: "https://api.anthropic.com")!, statusCode: code, httpVersion: nil, headerFields: nil)!
    }

    @Test func fetchDecodesLimitsAndSendsHeaders() async throws {
        let body = Data(#"{"limits":[{"kind":"session","group":"session","percent":9,"severity":"normal","resets_at":null,"scope":null,"is_active":false}]}"#.utf8)
        var captured: URLRequest?
        let client = UsageClient(tokenProvider: StubToken()) { req in
            captured = req
            return (body, self.http(200))
        }
        let limits = try await client.fetch()
        #expect(limits.count == 1)
        #expect(limits[0].percent == 9)
        #expect(captured?.url?.absoluteString == "https://api.anthropic.com/api/oauth/usage")
        #expect(captured?.value(forHTTPHeaderField: "Authorization") == "Bearer sk-test")
        #expect(captured?.value(forHTTPHeaderField: "anthropic-beta") == "oauth-2025-04-20")
    }

    @Test func unauthorizedMapsToError() async {
        let client = UsageClient(tokenProvider: StubToken()) { _ in (Data(), self.http(401)) }
        await #expect(throws: UsageError.self) { try await client.fetch() }
    }
}
