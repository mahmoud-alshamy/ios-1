import AppKit
import SwiftUI
import Combine

@MainActor
class MenuBarController: NSObject, ObservableObject {
    @Published var isVisible = false

    private var statusItem: NSStatusItem?
    private var floatingPanel: FloatingPanelWindow?
    private let viewModel: MenuBarViewModel
    private let screenMonitor: ScreenMonitor
    private let serviceProvider: ServiceProvider
    private var cancellables = Set<AnyCancellable>()

    init(
        viewModel: MenuBarViewModel,
        screenMonitor: ScreenMonitor,
        serviceProvider: ServiceProvider
    ) {
        self.viewModel = viewModel
        self.screenMonitor = screenMonitor
        self.serviceProvider = serviceProvider
        super.init()

        setupStatusItem()
        observeViewState()
        startBackgroundServices()
    }

    private func setupStatusItem() {
        let statusBar = NSStatusBar.system
        statusItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)

        guard let statusItem = statusItem else {
            Logger.log("Failed to create status item", level: .error, category: "MenuBar")
            return
        }

        let compactView = CompactMenuBarView(viewModel: viewModel)
        let hostingView = NSHostingView(rootView: compactView)
        hostingView.frame = NSRect(x: 0, y: 0, width: 44, height: 22)

        statusItem.button?.addSubview(hostingView)
        statusItem.button?.target = self
        statusItem.button?.action = #selector(togglePanel)

        Logger.log("Status item created successfully", category: "MenuBar")
    }

    private func observeViewState() {
        viewModel.$viewState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] viewState in
                switch viewState {
                case .compact:
                    self?.hidePanel()
                case .expanded:
                    self?.showPanel()
                case .transitioning:
                    break
                }
            }
            .store(in: &cancellables)
    }

    private func startBackgroundServices() {
        serviceProvider.mediaService.start()
        serviceProvider.calendarService.start()
        Logger.log("Background services started", category: "MenuBar")
    }

    @objc
    nonisolated private func togglePanel() {
        Task { @MainActor in
            self.viewModel.toggleExpanded()
        }
    }

    private func showPanel() {
        if floatingPanel == nil {
            createPanel()
        }

        guard let panel = floatingPanel else { return }

        let panelSize = NSSize(
            width: AppConstants.Panel.width,
            height: AppConstants.Panel.height
        )

        let position = PanelPositioner.positionPanelNearMenuBar(
            panelSize: panelSize,
            screenMonitor: screenMonitor
        )

        panel.setFrameOrigin(position)
        panel.setContentSize(panelSize)
        panel.makeKeyAndOrderFront(nil)

        isVisible = true

        Logger.log("Panel shown", category: "MenuBar")
    }

    private func hidePanel() {
        floatingPanel?.orderOut(nil)
        isVisible = false

        Logger.log("Panel hidden", category: "MenuBar")
    }

    private func createPanel() {
        let panelSize = NSSize(
            width: AppConstants.Panel.width,
            height: AppConstants.Panel.height
        )

        let position = PanelPositioner.positionPanelNearMenuBar(
            panelSize: panelSize,
            screenMonitor: screenMonitor
        )

        let panelView = PanelContentView(viewModel: viewModel, serviceProvider: serviceProvider)

        floatingPanel = FloatingPanelWindow(
            rootView: panelView,
            frameRect: NSRect(origin: position, size: panelSize)
        )

        floatingPanel?.delegate = self

        Logger.log("Floating panel created", category: "MenuBar")
    }

    nonisolated func windowWillClose() {
        Task { @MainActor in
            self.viewModel.viewState = .compact
        }
    }
}

// MARK: - NSWindowDelegate

extension MenuBarController: NSWindowDelegate {
    nonisolated func windowWillClose(_ notification: Notification) {
        windowWillClose()
    }

    nonisolated func windowDidResignKey(_ notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            Task { @MainActor in
                self.viewModel.viewState = .compact
            }
        }
    }
}
