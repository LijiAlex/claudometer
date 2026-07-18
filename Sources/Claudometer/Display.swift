import Foundation

func label(for limit: UsageLimit) -> String {
    switch limit.kind {
    case "session": return "Session"
    case "weekly_all": return "All models"
    case "weekly_scoped":
        return limit.scope?.model?.displayName ?? "Weekly (scoped)"
    default:
        return limit.kind
            .split(separator: "_")
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
            .joined(separator: " ")
    }
}

func sessionPercentText(_ limits: [UsageLimit]) -> String {
    guard let s = limits.first(where: { $0.kind == "session" }) else { return "–" }
    return "\(s.percent)%"
}

func groupedForDisplay(_ limits: [UsageLimit]) -> (session: [UsageLimit], weekly: [UsageLimit], other: [UsageLimit]) {
    var session: [UsageLimit] = [], weekly: [UsageLimit] = [], other: [UsageLimit] = []
    for l in limits {
        switch l.group {
        case "session": session.append(l)
        case "weekly": weekly.append(l)
        default: other.append(l)
        }
    }
    return (session, weekly, other)
}
