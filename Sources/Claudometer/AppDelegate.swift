import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var controller: StatusItemController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let client = UsageClient(tokenProvider: KeychainReader())
        let store = UsageStore(client: client)
        controller = StatusItemController(store: store)
    }
}
