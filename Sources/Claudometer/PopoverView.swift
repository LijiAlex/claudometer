import SwiftUI

struct PopoverView: View {
    @ObservedObject var store: UsageStore
    let onRefresh: () -> Void
    let onQuit: () -> Void
    @State private var launchAtLogin = LaunchAtLogin.isEnabled

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Claude Usage").font(.headline)
            content
            Divider()
            footer
        }
        .padding(14)
        .frame(width: 300)
    }

    @ViewBuilder private var content: some View {
        switch store.state {
        case .loading:
            Text("Loading…").foregroundStyle(.secondary)
        case .notLoggedIn:
            Text("Claude Code not logged in — run `claude` once.").foregroundStyle(.secondary)
        case .tokenStale:
            Text("Login token stale — open Claude Code to refresh.").foregroundStyle(.secondary)
        case .loaded(let limits, _):
            groups(limits)
        case .failed(_, let lastGood):
            if let good = lastGood { groups(good.0) }
            else { Text("Couldn’t reach Anthropic. Retrying…").foregroundStyle(.secondary) }
        }
    }

    @ViewBuilder private func groups(_ limits: [UsageLimit]) -> some View {
        let g = groupedForDisplay(limits)
        if !g.session.isEmpty { section("SESSION", g.session, relative: true) }
        if !g.weekly.isEmpty { section("WEEKLY", g.weekly, relative: false) }
        if !g.other.isEmpty { section("OTHER", g.other, relative: false) }
    }

    @ViewBuilder private func section(_ title: String, _ limits: [UsageLimit], relative: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            ForEach(Array(limits.enumerated()), id: \.offset) { _, l in
                row(l, relative: relative)
            }
        }
    }

    @ViewBuilder private func row(_ l: UsageLimit, relative: Bool) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text(label(for: l))
                Spacer()
                Text("\(l.percent)%").monospacedDigit().foregroundStyle(barColor(l.percent))
            }
            ProgressView(value: Double(min(l.percent, 100)), total: 100).tint(barColor(l.percent))
            if let r = l.resetsAt {
                Text(relative ? relativeReset(from: r, now: Date()) : absoluteReset(from: r))
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
    }

    private func barColor(_ pct: Int) -> Color {
        pct >= 90 ? .red : (pct >= 70 ? .orange : .accentColor)
    }

    @ViewBuilder private var footer: some View {
        HStack {
            Toggle("Launch at login", isOn: $launchAtLogin)
                .toggleStyle(.checkbox)
                .onChange(of: launchAtLogin) { newValue in
                    LaunchAtLogin.set(newValue)
                    launchAtLogin = LaunchAtLogin.isEnabled
                }
            Spacer()
            Button("Refresh", action: onRefresh)
            Button("Quit", action: onQuit)
        }
        .font(.caption)
    }
}
