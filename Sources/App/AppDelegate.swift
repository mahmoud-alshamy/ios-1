import AppKit
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    let serviceProvider: DefaultServiceProvider = .init()
    private var appCoordinator: AppCoordinator?

    func applicationDidFinishLaunching(_ notification: Notification) {
        Logger.log("Application launched", category: "AppDelegate")

        appCoordinator = AppCoordinator(serviceProvider: serviceProvider)
        appCoordinator?.start()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationWillTerminate(_ notification: Notification) {
        Logger.log("Application terminating", category: "AppDelegate")
        appCoordinator?.stop()
    }
}
