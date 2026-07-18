import Foundation
import Testing
@testable import Claudometer

struct DecodingTests {
    private func fixtureData() throws -> Data {
        let url = try #require(Bundle.module.url(forResource: "usage", withExtension: "json"))
        return try Data(contentsOf: url)
    }

    @Test func decodesLimitsArray() throws {
        let resp = try makeUsageDecoder().decode(UsageResponse.self, from: fixtureData())
        #expect(resp.limits.count == 3)

        let session = resp.limits[0]
        #expect(session.kind == "session")
        #expect(session.percent == 5)
        #expect(session.isActive == false)
        #expect(session.scope == nil)

        let scoped = resp.limits[2]
        #expect(scoped.kind == "weekly_scoped")
        #expect(scoped.percent == 37)
        #expect(scoped.scope?.model?.displayName == "Fable")
        #expect(scoped.isActive == true)
    }

    @Test func decodesResetDate() throws {
        let resp = try makeUsageDecoder().decode(UsageResponse.self, from: fixtureData())
        let reset = try #require(resp.limits[0].resetsAt)
        // 2026-07-18T01:50:00Z
        let comps = Calendar(identifier: .gregorian).dateComponents(in: TimeZone(identifier: "UTC")!, from: reset)
        #expect(comps.year == 2026)
        #expect(comps.month == 7)
        #expect(comps.day == 18)
        #expect(comps.hour == 1)
        #expect(comps.minute == 50)
    }
}
