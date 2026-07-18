import AppKit

// main.swift top-level code is not statically MainActor-isolated, but this
// process is single-threaded and everything here runs on the main thread
// (this is the entry point). AppDelegate is @MainActor, so bridge with
// assumeIsolated rather than weakening its isolation.
MainActor.assumeIsolated {
    let app = NSApplication.shared
    let delegate = AppDelegate()
    app.delegate = delegate
    app.setActivationPolicy(.accessory)
    app.run()
}
