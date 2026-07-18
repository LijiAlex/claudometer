import Foundation
import Security

protocol TokenProviding {
    func accessToken() throws -> String
}

enum TokenError: Error { case notLoggedIn }

final class KeychainReader: TokenProviding {
    private let service: String
    init(service: String = "Claude Code-credentials") { self.service = service }

    func accessToken() throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess,
              let data = item as? Data,
              let token = parseAccessToken(from: data)
        else { throw TokenError.notLoggedIn }
        return token
    }
}
