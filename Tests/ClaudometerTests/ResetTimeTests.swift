import Testing
import Foundation
@testable import Claudometer

struct ResetTimeTests {
    @Test func relativeHoursMinutes() {
        let now = Date(timeIntervalSince1970: 0)
        let then = now.addingTimeInterval(75 * 60) // 1h15m
        #expect(relativeReset(from: then, now: now) == "resets in 1h 15m")
    }

    @Test func relativeMinutesOnly() {
        let now = Date(timeIntervalSince1970: 0)
        #expect(relativeReset(from: now.addingTimeInterval(12 * 60), now: now) == "resets in 12m")
    }

    @Test func relativePast() {
        let now = Date(timeIntervalSince1970: 100)
        #expect(relativeReset(from: now.addingTimeInterval(-60), now: now) == "resetting…")
    }

    @Test func absoluteFormat() {
        // 2026-07-22 18:29 in a fixed calendar/timezone
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "America/New_York")!
        let date = cal.date(from: DateComponents(year: 2026, month: 7, day: 22, hour: 18, minute: 29))!
        #expect(absoluteReset(from: date, calendar: cal) == "resets Wed 6:29 PM")
    }
}
