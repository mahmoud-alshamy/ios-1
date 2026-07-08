import AppKit
import Combine

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    let serviceProvider: DefaultServiceProvider = .init()
    private var appCoordinator: AppCoordinator?
    private var menuBarController: MenuBarController?
    private var menuBarViewModel: MenuBarViewModel?

    func applicationDidFinishLaunching(_ notification: Notification) {
        Logger.log("Application launched", category: "AppDelegate")

        appCoordinator = AppCoordinator(serviceProvider: serviceProvider)
        appCoordinator?.start()

        setupMenuBar()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationWillTerminate(_ notification: Notification) {
        Logger.log("Application terminating", category: "AppDelegate")
        appCoordinator?.stop()
    }

    private func setupMenuBar() {
        menuBarViewModel = MenuBarViewModel(services: serviceProvider)

        guard let viewModel = menuBarViewModel else { return }

        menuBarController = MenuBarController(
            viewModel: viewModel,
            screenMonitor: serviceProvider.screenMonitor,
            serviceProvider: serviceProvider
        )

        Logger.log("Menu bar initialized", category: "AppDelegate")
    }
}
