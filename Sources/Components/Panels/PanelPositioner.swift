import AppKit

struct PanelPositioner {
    static func positionPanelNearMenuBar(
        panelSize: NSSize,
        screenMonitor: ScreenMonitor
    ) -> NSPoint {
        guard let screen = screenMonitor.getMenuBarScreen() else {
            return NSPoint(x: 0, y: 0)
        }

        let screenFrame = screen.frame
        let visibleFrame = screen.visibleFrame

        let panelX = visibleFrame.maxX - panelSize.width - 12
        let panelY = visibleFrame.maxY - panelSize.height - 8

        Logger.log(
            "Panel positioned at (\(panelX), \(panelY)) on screen \(screenFrame.size)",
            category: "PanelPositioner"
        )

        return NSPoint(x: panelX, y: panelY)
    }

    static func positionPanelCentered(
        panelSize: NSSize,
        screenMonitor: ScreenMonitor
    ) -> NSPoint {
        guard let screen = screenMonitor.getScreenWithCursor() ?? NSScreen.main else {
            return NSPoint(x: 0, y: 0)
        }

        let screenFrame = screen.frame
        let panelX = screenFrame.midX - panelSize.width / 2
        let panelY = screenFrame.midY - panelSize.height / 2

        Logger.log(
            "Panel centered at (\(panelX), \(panelY))",
            category: "PanelPositioner"
        )

        return NSPoint(x: panelX, y: panelY)
    }
}
