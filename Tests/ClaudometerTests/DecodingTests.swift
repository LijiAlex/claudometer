import XCTest
@testable import Claudometer

final class DecodingTests: XCTestCase {
    private func fixtureData() throws -> Data {
        let url = try XCTUnwrap(Bundle.module.url(forResource: "usage", withExtension: "json"))
        return try Data(contentsOf: url)
    }

    func testDecodesLimitsArray() throws {
        let resp = try makeUsageDecoder().decode(UsageResponse.self, from: fixtureData())
        XCTAssertEqual(resp.limits.count, 3)

        let session = resp.limits[0]
        XCTAssertEqual(session.kind, "session")
        XCTAssertEqual(session.percent, 5)
        XCTAssertEqual(session.isActive, false)
        XCTAssertNil(session.scope)

        let scoped = resp.limits[2]
        XCTAssertEqual(scoped.kind, "weekly_scoped")
        XCTAssertEqual(scoped.percent, 37)
        XCTAssertEqual(scoped.scope?.model?.displayName, "Fable")
        XCTAssertEqual(scoped.isActive, true)
    }

    func testDecodesResetDate() throws {
        let resp = try makeUsageDecoder().decode(UsageResponse.self, from: fixtureData())
        let reset = try XCTUnwrap(resp.limits[0].resetsAt)
        // 2026-07-18T01:50:00Z
        let comps = Calendar(identifier: .gregorian).dateComponents(in: TimeZone(identifier: "UTC")!, from: reset)
        XCTAssertEqual(comps.year, 2026)
        XCTAssertEqual(comps.month, 7)
        XCTAssertEqual(comps.day, 18)
        XCTAssertEqual(comps.hour, 1)
        XCTAssertEqual(comps.minute, 50)
    }
}
