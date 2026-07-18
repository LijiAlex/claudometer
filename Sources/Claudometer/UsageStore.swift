import Foundation

enum LoadState {
    case loading
    case loaded([UsageLimit], at: Date)
    case notLoggedIn
    case tokenStale
    case failed(String, lastGood: ([UsageLimit], Date)?)
}

func menuTitle(for state: LoadState) -> String {
    switch state {
    case .loading: return "…"
    case .loaded(let limits, _): return sessionPercentText(limits)
    case .notLoggedIn, .tokenStale: return "–"
    case .failed(_, let lastGood):
        if let good = lastGood { return sessionPercentText(good.0) }
        return "–"
    }
}

@MainActor
final class UsageStore: ObservableObject {
    @Published private(set) var state: LoadState = .loading
    private let client: UsageFetching

    init(client: UsageFetching) { self.client = client }

    private func lastGood() -> ([UsageLimit], Date)? {
        switch state {
        case .loaded(let l, let at): return (l, at)
        case .failed(_, let g): return g
        default: return nil
        }
    }

    func refresh() async {
        do {
            let limits = try await client.fetch()
            state = .loaded(limits, at: Date())
        } catch UsageError.unauthorized {
            state = .tokenStale
        } catch is TokenError {
            state = .notLoggedIn
        } catch {
            state = .failed("\(error)", lastGood: lastGood())
        }
    }
}
