import Testing
import Foundation
@testable import Claudometer

private final class StubFetcher: UsageFetching {
    enum Behavior {
        case succeed([UsageLimit])
        case throwError(Error)
    }
    var behavior: Behavior

    init(behavior: Behavior) { self.behavior = behavior }

    func fetch() async throws -> [UsageLimit] {
        switch behavior {
        case .succeed(let limits): return limits
        case .throwError(let error): throw error
        }
    }
}

private enum OtherError: Error { case boom }

private func makeLimit(_ pct: Int) -> UsageLimit {
    UsageLimit(kind: "session", group: "session", percent: pct, severity: "normal",
               resetsAt: nil, scope: nil, isActive: false)
}

struct UsageStoreTests {
    @MainActor
    @Test func successLoadsIntoLoadedState() async {
        let limits = [makeLimit(10)]
        let store = UsageStore(client: StubFetcher(behavior: .succeed(limits)))
        await store.refresh()

        switch store.state {
        case .loaded(let l, _):
            #expect(l.count == 1)
            #expect(l[0].percent == 10)
        default:
            Issue.record("expected .loaded, got \(store.state)")
        }
    }

    @MainActor
    @Test func unauthorizedMapsToTokenStale() async {
        let store = UsageStore(client: StubFetcher(behavior: .throwError(UsageError.unauthorized)))
        await store.refresh()

        if case .tokenStale = store.state {
            // expected
        } else {
            Issue.record("expected .tokenStale, got \(store.state)")
        }
    }

    @MainActor
    @Test func notLoggedInMapsToNotLoggedInState() async {
        let store = UsageStore(client: StubFetcher(behavior: .throwError(TokenError.notLoggedIn)))
        await store.refresh()

        if case .notLoggedIn = store.state {
            // expected
        } else {
            Issue.record("expected .notLoggedIn, got \(store.state)")
        }
    }

    @MainActor
    @Test func otherErrorMapsToFailedPreservingLastGood() async {
        let limits = [makeLimit(20)]
        let fetcher = StubFetcher(behavior: .succeed(limits))
        let store = UsageStore(client: fetcher)

        await store.refresh()
        guard case .loaded = store.state else {
            Issue.record("expected initial .loaded, got \(store.state)")
            return
        }

        fetcher.behavior = .throwError(OtherError.boom)
        await store.refresh()

        switch store.state {
        case .failed(_, let lastGood):
            guard let good = lastGood else {
                Issue.record("expected lastGood to be preserved, got nil")
                return
            }
            #expect(good.0.count == 1)
            #expect(good.0[0].percent == 20)
        default:
            Issue.record("expected .failed, got \(store.state)")
        }
    }
}
