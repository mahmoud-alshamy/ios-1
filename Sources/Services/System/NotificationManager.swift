import Foundation
import AppKit

class NotificationManager {
    init() { Logger.log("NotificationManager initialized", category: "NotificationManager") }
    func showNotification(title: String, message: String, duration: TimeInterval = 3) { Logger.log("Showing notification: \(title)", category: "NotificationManager") }
    func showError(_ error: Error, duration: TimeInterval = 5) { Logger.log("Showing error notification: \(error.localizedDescription)", category: "NotificationManager") }
}
