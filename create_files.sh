#!/bin/bash
set -e

PROJ_DIR="/Users/elshamy/Library/CloudStorage/OneDrive-Personal/Mahmoud/ios ideas/DynamicWin-macOS"
cd "$PROJ_DIR"

# Logger.swift
mkdir -p Sources/Utilities
cat > "Sources/Utilities/Logger.swift" << 'SWIFT'
import Foundation
import os.log

enum LogLevel: String {
    case debug = "🔍", info = "ℹ️", warning = "⚠️", error = "❌"
    var osLogType: OSLogType {
        switch self {
        case .debug: return .debug
        case .info: return .info
        case .warning: return .default
        case .error: return .error
        }
    }
}

struct Logger {
    private static let osLog = OSLog(subsystem: AppConstants.appBundleIdentifier, category: "General")

    static func log(
        _ message: String,
        level: LogLevel = .info,
        category: String = "General",
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        #if DEBUG
        let timestamp = DateFormatter.iso8601.string(from: Date())
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let logMessage = "[\(timestamp)][\(level.rawValue)][\(category)][\(fileName):\(line)] \(message)"
        print(logMessage)
        #endif
        os_log("%{public}@", log: osLog, type: level.osLogType, message)
    }

    static func logError(_ error: Error, category: String = "General") {
        let message = "\(type(of: error)): \(error.localizedDescription)"
        log(message, level: .error, category: category)
    }
}

extension DateFormatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
}
SWIFT

# ServiceProvider.swift
cat > "Sources/Services/ServiceProvider.swift" << 'SWIFT'
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
SWIFT

echo "✓ Core utilities created"
