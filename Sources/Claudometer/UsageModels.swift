import Foundation

struct UsageResponse: Decodable {
    let limits: [UsageLimit]
}

struct UsageLimit: Decodable {
    let kind: String
    let group: String
    let percent: Int
    let severity: String?
    let resetsAt: Date?
    let scope: Scope?
    let isActive: Bool

    struct Scope: Decodable {
        let model: Model?
        struct Model: Decodable {
            let displayName: String?
        }
    }
}

// Note: UsageLimit, UsageLimit.Scope, and UsageLimit.Scope.Model are plain
// structs with no custom initializers in their primary declarations, so Swift
// already synthesizes internal memberwise initializers matching the shapes
// tests need (init(kind:group:percent:severity:resetsAt:scope:isActive:),
// init(model:), init(displayName:)). @testable import exposes them to tests;
// explicit re-declarations here would collide with those synthesized inits.
// The custom Decodable init(from:) lives in an extension below (see
// UsageLimit+Decoding) precisely so it doesn't suppress this memberwise init.

extension UsageLimit {
    enum CodingKeys: String, CodingKey {
        case kind, group, percent, severity, resetsAt, scope, isActive
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        kind = try c.decode(String.self, forKey: .kind)
        group = try c.decode(String.self, forKey: .group)
        if let i = try? c.decode(Int.self, forKey: .percent) {
            percent = i
        } else {
            percent = Int((try c.decode(Double.self, forKey: .percent)).rounded())
        }
        severity = try c.decodeIfPresent(String.self, forKey: .severity)
        resetsAt = try c.decodeIfPresent(Date.self, forKey: .resetsAt)
        scope = try c.decodeIfPresent(Scope.self, forKey: .scope)
        isActive = try c.decodeIfPresent(Bool.self, forKey: .isActive) ?? false
    }
}
