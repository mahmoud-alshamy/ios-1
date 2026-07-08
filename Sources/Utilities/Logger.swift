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
