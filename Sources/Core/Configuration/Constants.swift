import Foundation
import AppKit

enum AppConstants {
    static let appName = "DynamicWin"
    static let appVersion = "1.0.0"
    static let appBundleIdentifier = "com.elshamy.dynamicwin"

    enum Panel {
        static let width: CGFloat = 350
        static let height: CGFloat = 280
        static let cornerRadius: CGFloat = 16
        static let shadowRadius: CGFloat = 8
        static let shadowOpacity: Float = 0.3
        static let borderWidth: CGFloat = 0.5
    }

    enum MenuBar {
        static let iconSize: CGFloat = 22
        static let compactWidth: CGFloat = 44
    }

    enum Activity {
        static let indicatorSize: CGFloat = 8
        static let indicatorSpacing: CGFloat = 10
        static let peekAmount: CGFloat = 40
    }

    enum Animation {
        static let expandDuration: TimeInterval = 0.3
        static let collapseDuration: TimeInterval = 0.2
        static let switchActivityDuration: TimeInterval = 0.2
        static let springTension: CGFloat = 100
        static let springFriction: CGFloat = 10
    }

    enum RefreshIntervals {
        static let calendar: TimeInterval = 30
        static let bluetooth: TimeInterval = 10
        static let media: TimeInterval = 2
    }

    enum Storage {
        static let fileTrayDirectory = "DynamicWin/FileTray"
        static let maxFileTrayItems = 50
    }

    enum Paths {
        static var applicationSupportDirectory: URL {
            FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        }

        static var dynamicWinDirectory: URL {
            applicationSupportDirectory.appendingPathComponent(appBundleIdentifier)
        }

        static var fileTrayDirectory: URL {
            dynamicWinDirectory.appendingPathComponent("FileTray")
        }

        static var preferencesFile: URL {
            dynamicWinDirectory.appendingPathComponent("preferences.json")
        }
    }

    enum Timeouts {
        static let mediaPlayerDetection: TimeInterval = 5
        static let calendarSync: TimeInterval = 10
        static let bluetoothUpdate: TimeInterval = 15
    }
}

enum ColorPalette {
    static let background = NSColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1)
    static let backgroundDark = NSColor(red: 0.15, green: 0.15, blue: 0.16, alpha: 1)
    static let textPrimary = NSColor.textColor
    static let textSecondary = NSColor.secondaryLabelColor
    static let accent = NSColor(red: 0.0, green: 0.478, blue: 1.0, alpha: 1)
    static let border = NSColor.separatorColor
}

enum SystemConfiguration {
    static var isDarkMode: Bool {
        if let appearance = NSAppearance.current {
            return appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        }
        return false
    }

    static var hasNotch: Bool {
        NSScreen.main?.safeAreaInsets.top ?? 0 > 0
    }
}
