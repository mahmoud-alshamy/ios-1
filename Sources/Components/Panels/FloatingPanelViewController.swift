import AppKit
import SwiftUI

class FloatingPanelViewController: NSViewController {
    let hostingController: NSHostingController<AnyView>

    init<Content: View>(rootView: Content) {
        self.hostingController = NSHostingController(rootView: AnyView(rootView))
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = hostingController.view
    }
}

class FloatingPanelWindow: NSPanel {
    init<Content: View>(
        rootView: Content,
        frameRect: NSRect
    ) {
        let viewController = FloatingPanelViewController(rootView: rootView)

        super.init(
            contentRect: frameRect,
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        self.contentViewController = viewController
        self.titlebarAppearsTransparent = true
        self.titleVisibility = .hidden
        self.isMovable = false
        self.isOpaque = false
        self.backgroundColor = NSColor.clear
        self.hasShadow = true
        self.level = .floating
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.isReleasedWhenClosed = false

        Logger.log("FloatingPanelWindow initialized", category: "FloatingPanel")
    }

    override func close() {
        NSApplication.shared.hide(nil)
        super.close()
    }
}
