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
        if let token = token { DistributedNotificationCenter.default().removeObserver(token) }
    }

    private func setupListener() {
        token = DistributedNotificationCenter.default().addObserver(
            forName: NSAppearance.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateDarkMode()
        }
    }

    private func updateDarkMode() {
        isDarkMode = NSAppearance.current.bestMatch(from: [.darkAqua, .lightAqua]) == .darkAqua
        Logger.log("Dark mode: \(isDarkMode)", category: "DarkModeListener")
    }
}
