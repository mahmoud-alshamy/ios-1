import SwiftUI

@main
struct DynamicWinApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra("DynamicWin", systemImage: "dot.radiowaves.left.and.right") {
            ExpandedPanelView()
                .environment(\.serviceProvider, appDelegate.serviceProvider)
        }
    }
}
