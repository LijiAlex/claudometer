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
