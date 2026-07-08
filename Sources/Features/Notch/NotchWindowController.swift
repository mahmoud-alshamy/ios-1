import AppKit
import SwiftUI
import Combine

/// Owns the notch overlay window, pins it to the top-center of the display,
/// bridges notch state to click-through hit testing, and closes on outside clicks.
@MainActor
final class NotchWindowController {
    private let window: NotchWindow
    private let container: NotchContainerView
    private let vm: NotchViewModel
    private let services: ServiceProvider
    private var geometry: NotchGeometry

    private var cancellables = Set<AnyCancellable>()
    private var globalClickMonitor: Any?

    init(serviceProvider: ServiceProvider, onOpenPreferences: @escaping () -> Void) {
        self.services = serviceProvider
        self.vm = NotchViewModel(services: serviceProvider)
        self.geometry = NotchGeometry.current(for: NotchWindowController.notchScreen())

        let windowSize = geometry.windowSize
        let rect = NSRect(origin: .zero, size: windowSize)

        window = NotchWindow(contentRect: rect)
        container = NotchContainerView(frame: rect)

        let root = NotchRootView(vm: vm, geometry: geometry, onOpenPreferences: onOpenPreferences)
        let hosting = NSHostingView(rootView: root)
        hosting.frame = container.bounds
        hosting.autoresizingMask = [.width, .height]
        // Force a dark rendering so system control colors read correctly on black.
        hosting.appearance = NSAppearance(named: .darkAqua)
        if #available(macOS 13.0, *) {
            hosting.sizingOptions = []
        }
        container.addSubview(hosting)

        window.contentView = container

        positionWindow()
        updateInteractiveFrame()
        window.orderFrontRegardless()

        observeState()
        observeScreenChanges()
        installGlobalClickMonitor()
        startEnabledServices()

        Logger.log("Notch window controller ready", category: "Notch")
    }

    deinit {
        if let monitor = globalClickMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }

    // MARK: - Positioning

    /// The display that owns the notch (or the primary display as a fallback).
    private static func notchScreen() -> NSScreen? {
        NSScreen.screens.first(where: { $0.safeAreaInsets.top > 0 })
            ?? NSScreen.main
            ?? NSScreen.screens.first
    }

    private func positionWindow() {
        guard let screen = NotchWindowController.notchScreen() else { return }
        let size = geometry.windowSize
        let origin = NSPoint(
            x: screen.frame.midX - size.width / 2,
            y: screen.frame.maxY - size.height
        )
        window.setFrame(NSRect(origin: origin, size: size), display: true)
    }

    // MARK: - Hit testing

    /// Keep the click-through region in sync with the current notch bounds.
    private func updateInteractiveFrame() {
        let size: CGSize = vm.state == .open ? geometry.open : geometry.peek
        let windowSize = geometry.windowSize
        let inset: CGFloat = 8
        let rect = CGRect(
            x: (windowSize.width - size.width) / 2 - inset,
            y: 0,
            width: size.width + inset * 2,
            height: size.height + inset
        )
        container.interactiveFrame = rect
    }

    // MARK: - Observation

    private func observeState() {
        vm.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateInteractiveFrame()
            }
            .store(in: &cancellables)
    }

    private func observeScreenChanges() {
        NotificationCenter.default.publisher(
            for: NSApplication.didChangeScreenParametersNotification
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
            self?.positionWindow()
        }
        .store(in: &cancellables)
    }

    /// Any click outside the overlay collapses an open notch.
    private func installGlobalClickMonitor() {
        globalClickMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown]
        ) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.vm.isOpen else { return }
                self.vm.close()
            }
        }
    }

    // MARK: - Services

    private func startEnabledServices() {
        let enabled = services.preferencesManager.preferences.enabledActivities
        if enabled.contains(.media) { services.mediaService.start() }
        if enabled.contains(.calendar) { services.calendarService.start() }
        if enabled.contains(.fileTray) { services.fileTrayService.start() }
        if enabled.contains(.bluetooth) { services.bluetoothService.start() }
        Logger.log("Enabled activity services started", category: "Notch")
    }
}
