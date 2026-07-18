import Foundation

struct UsageResponse: Decodable {
    let limits: [UsageLimit]
}

struct UsageLimit: Decodable {
    let kind: String
    let group: String
    let percent: Int
    let severity: String
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
