import Testing
import Foundation
@testable import Claudometer

struct DisplayTests {
    private func limit(_ kind: String, _ pct: Int, group: String, model: String? = nil) -> UsageLimit {
        let scope = model.map { UsageLimit.Scope(model: .init(displayName: $0)) }
        return UsageLimit(kind: kind, group: group, percent: pct, severity: "normal",
                          resetsAt: nil, scope: scope, isActive: false)
    }

    @Test func labels() {
        #expect(label(for: limit("session", 5, group: "session")) == "Session")
        #expect(label(for: limit("weekly_all", 22, group: "weekly")) == "All models")
        #expect(label(for: limit("weekly_scoped", 37, group: "weekly", model: "Fable")) == "Fable")
        #expect(label(for: limit("weekly_special_thing", 3, group: "weekly")) == "Weekly Special Thing")
    }

    @Test func sessionPercentTextValue() {
        let limits = [limit("session", 5, group: "session"), limit("weekly_all", 22, group: "weekly")]
        #expect(sessionPercentText(limits) == "5%")
        #expect(sessionPercentText([limit("weekly_all", 22, group: "weekly")]) == "–")
    }

    @Test func grouping() {
        let limits = [
            limit("session", 5, group: "session"),
            limit("weekly_all", 22, group: "weekly"),
            limit("weekly_scoped", 37, group: "weekly", model: "Fable"),
            limit("mystery", 1, group: "other"),
        ]
        let g = groupedForDisplay(limits)
        #expect(g.session.count == 1)
        #expect(g.weekly.count == 2)
        #expect(g.other.count == 1)
    }
}
