import AppKit
import Combine

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    let serviceProvider: DefaultServiceProvider = .init()
    private var appCoordinator: AppCoordinator?
    private var notchController: NotchWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        Logger.log("Application launched", category: "AppDelegate")

        // The notch is the entire app: no dock icon, no menu bar presence.
        NSApp.setActivationPolicy(.accessory)

        appCoordinator = AppCoordinator(serviceProvider: serviceProvider)
        appCoordinator?.start()

        notchController = NotchWindowController(
            serviceProvider: serviceProvider,
            onOpenPreferences: { [weak self] in
                self?.appCoordinator?.showPreferences()
            }
        )

        Logger.log("Notch initialized", category: "AppDelegate")
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationWillTerminate(_ notification: Notification) {
        Logger.log("Application terminating", category: "AppDelegate")
        appCoordinator?.stop()
    }
}
