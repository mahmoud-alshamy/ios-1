import Foundation

protocol ServiceProvider {
    var mediaService: MediaPlayerService { get }
    var calendarService: CalendarService { get }
    var fileTrayService: FileTrayService { get }
    var bluetoothService: BluetoothService { get }
    var preferencesManager: PreferencesManager { get }
    var hotKeyManager: HotKeyManager { get }
    var notificationManager: NotificationManager { get }
    var screenMonitor: ScreenMonitor { get }
    var darkModeListener: DarkModeListener { get }
    var updateCheckService: UpdateCheckService { get }
}

class DefaultServiceProvider: ServiceProvider {
    lazy var mediaService: MediaPlayerService = { Logger.log("Initializing MediaPlayerService", category: "ServiceProvider"); return MediaPlayerService() }()
    lazy var calendarService: CalendarService = { Logger.log("Initializing CalendarService", category: "ServiceProvider"); return CalendarService() }()
    lazy var fileTrayService: FileTrayService = { Logger.log("Initializing FileTrayService", category: "ServiceProvider"); return FileTrayService() }()
    lazy var bluetoothService: BluetoothService = { Logger.log("Initializing BluetoothService", category: "ServiceProvider"); return BluetoothService() }()
    lazy var preferencesManager: PreferencesManager = { Logger.log("Initializing PreferencesManager", category: "ServiceProvider"); return PreferencesManager() }()
    lazy var hotKeyManager: HotKeyManager = { Logger.log("Initializing HotKeyManager", category: "ServiceProvider"); return HotKeyManager() }()
    lazy var notificationManager: NotificationManager = { Logger.log("Initializing NotificationManager", category: "ServiceProvider"); return NotificationManager() }()
    lazy var screenMonitor: ScreenMonitor = { Logger.log("Initializing ScreenMonitor", category: "ServiceProvider"); return ScreenMonitor() }()
    lazy var darkModeListener: DarkModeListener = { Logger.log("Initializing DarkModeListener", category: "ServiceProvider"); return DarkModeListener() }()
    lazy var updateCheckService: UpdateCheckService = { Logger.log("Initializing UpdateCheckService", category: "ServiceProvider"); return UpdateCheckService() }()
}

private struct ServiceProviderKey: EnvironmentKey {
    static let defaultValue: ServiceProvider = DefaultServiceProvider()
}

extension EnvironmentValues {
    var serviceProvider: ServiceProvider {
        get { self[ServiceProviderKey.self] }
        set { self[ServiceProviderKey.self] = newValue }
    }
}
