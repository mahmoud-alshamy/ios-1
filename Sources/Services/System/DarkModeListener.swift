import Foundation
import AppKit
import Combine

class DarkModeListener {
    @Published var isDarkMode: Bool = false
    private var token: NSObjectProtocol?

    init() {
        Logger.log("DarkModeListener initialized", category: "DarkModeListener")
        updateDarkMode()
        setupListener()
    }

    deinit {
        if let token = token {
            DistributedNotificationCenter.default().removeObserver(token)
        }
    }

    private func setupListener() {
        // Listen for appearance changes via NSApplication notification
        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeOcclusionStateNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateDarkMode()
        }

        token = DistributedNotificationCenter.default().addObserver(
            forName: NSNotification.Name("AppleInterfaceThemeChangedNotification"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateDarkMode()
        }
    }

    private func updateDarkMode() {
        if let appearance = NSAppearance.current {
            isDarkMode = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        } else {
            isDarkMode = false
        }
        Logger.log("Dark mode: \(isDarkMode)", category: "DarkModeListener")
    }
}
