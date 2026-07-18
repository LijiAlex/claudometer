import AppKit
import SwiftUI
import Combine

@MainActor
final class StatusItemController {
    private let statusItem: NSStatusItem
    private let store: UsageStore
    private let popover = NSPopover()
    private var timer: Timer?
    private var cancellable: AnyCancellable?

    init(store: UsageStore) {
        self.store = store
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "gauge", accessibilityDescription: "Claude usage")
            button.image?.isTemplate = true
            button.imagePosition = .imageLeading
            button.title = "…"
            button.target = self
            button.action = #selector(togglePopover)
        }

        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: PopoverView(store: store,
                                   onRefresh: { [weak self] in self?.triggerRefresh() },
                                   onQuit: { NSApp.terminate(nil) })
        )

        cancellable = store.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateTitle() }

        triggerRefresh()
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.triggerRefresh() }
        }
    }

    private func updateTitle() {
        statusItem.button?.title = menuTitle(for: store.state)
    }

    private func triggerRefresh() {
        Task { await store.refresh(); updateTitle() }
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }
        if popover.isShown { popover.performClose(nil) }
        else {
            updateTitle()
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}
