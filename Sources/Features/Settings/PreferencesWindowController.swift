import Cocoa
import SwiftUI

@MainActor
class PreferencesWindowController: NSWindowController {
    private let preferencesManager: PreferencesManager

    init(preferencesManager: PreferencesManager) {
        self.preferencesManager = preferencesManager

        let preferencesView = PreferencesView(preferencesManager: preferencesManager)
        let hostingController = NSHostingController(rootView: preferencesView)

        let window = NSWindow(
            contentViewController: hostingController
        )
        window.title = "DynamicWin Preferences"
        window.setContentSize(NSSize(width: 500, height: 450))
        window.styleMask = [.titled, .closable]
        window.center()
        window.isReleasedWhenClosed = false

        super.init(window: window)
        self.window?.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showWindow() {
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

extension PreferencesWindowController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        Logger.log("Preferences window closed", category: "Preferences")
    }
}
