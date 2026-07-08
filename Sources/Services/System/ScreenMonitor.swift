import Foundation
import AppKit
import Combine

class ScreenMonitor {
    @Published var activeScreen: NSScreen?
    @Published var screenCount: Int = 1

    init() {
        Logger.log("ScreenMonitor initialized", category: "ScreenMonitor")
        activeScreen = NSScreen.main
        screenCount = NSScreen.screens.count
    }

    func getScreenWithCursor() -> NSScreen? {
        let cursorLocation = NSEvent.mouseLocation
        return NSScreen.screens.first { screen in screen.frame.contains(cursorLocation) } ?? NSScreen.main
    }

    func getMenuBarScreen() -> NSScreen? { NSScreen.main }
}
