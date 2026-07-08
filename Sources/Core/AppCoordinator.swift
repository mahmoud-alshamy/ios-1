import Foundation

class AppCoordinator {
    private let serviceProvider: ServiceProvider
    private var backgroundServices: [BackgroundService] = []
    private var preferencesWindowController: PreferencesWindowController?

    init(serviceProvider: ServiceProvider) {
        self.serviceProvider = serviceProvider
    }

    @MainActor
    func showPreferences() {
        if preferencesWindowController == nil {
            preferencesWindowController = PreferencesWindowController(
                preferencesManager: serviceProvider.preferencesManager
            )
        }
        preferencesWindowController?.showWindow()
    }

    func start() {
        Logger.log("App Coordinator starting", category: "AppCoordinator")
        let preferencesManager = serviceProvider.preferencesManager
        preferencesManager.loadPreferences()
        startBackgroundServices()
        Logger.log("App Coordinator ready", category: "AppCoordinator")
    }

    func stop() {
        Logger.log("App Coordinator stopping", category: "AppCoordinator")
        stopBackgroundServices()
    }

    private func startBackgroundServices() {
        let preferences = serviceProvider.preferencesManager.preferences
        if preferences.enabledActivities.contains(.media) {
            backgroundServices.append(serviceProvider.mediaService)
        }
        if preferences.enabledActivities.contains(.calendar) {
            backgroundServices.append(serviceProvider.calendarService)
        }
        if preferences.enabledActivities.contains(.bluetooth) {
            backgroundServices.append(serviceProvider.bluetoothService)
        }
        backgroundServices.forEach { service in
            Logger.log("Starting background service: \(type(of: service))", category: "AppCoordinator")
        }
    }

    private func stopBackgroundServices() {
        backgroundServices.forEach { service in
            Logger.log("Stopping background service: \(type(of: service))", category: "AppCoordinator")
        }
        backgroundServices.removeAll()
    }
}

protocol BackgroundService {
    func start()
    func stop()
}
