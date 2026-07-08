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
        setupApplicationMenu()
    }

    private func setupApplicationMenu() {
        let mainMenu = NSMenu()
        let appMenu = NSMenu()

        let prefsItem = NSMenuItem(
            title: "Preferences...",
            action: #selector(showPreferences),
            keyEquivalent: ","
        )
        prefsItem.target = self
        appMenu.addItem(prefsItem)

        appMenu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(
            title: "Quit DynamicWin",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        appMenu.addItem(quitItem)

        let appMenuItem = NSMenuItem()
        appMenuItem.submenu = appMenu
        mainMenu.addItem(appMenuItem)

        NSApplication.shared.mainMenu = mainMenu
    }

    @objc
    private func showPreferences() {
        appCoordinator?.showPreferences()
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
