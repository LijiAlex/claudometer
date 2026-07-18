import Foundation
import Testing
@testable import Claudometer

struct CredentialsParserTests {
    @Test func parsesToken() {
        let json = #"{"claudeAiOauth":{"accessToken":"sk-abc123","refreshToken":"r"}}"#
        #expect(parseAccessToken(from: Data(json.utf8)) == "sk-abc123")
    }

    @Test func missingFieldReturnsNil() {
        #expect(parseAccessToken(from: Data(#"{"claudeAiOauth":{}}"#.utf8)) == nil)
        #expect(parseAccessToken(from: Data("not json".utf8)) == nil)
        #expect(parseAccessToken(from: Data(#"{"claudeAiOauth":{"accessToken":""}}"#.utf8)) == nil)
    }
}
