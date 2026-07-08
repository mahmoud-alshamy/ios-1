import Foundation
import Combine

@MainActor
final class NotchViewModel: ObservableObject {
    /// idle  — camouflaged over the hardware notch (invisible).
    /// hover — mouse is over the notch; reveal the compact programmed notch.
    /// open  — full panel with the current activity.
    enum State: Equatable {
        case idle
        case hover
        case open
    }

    @Published var state: State = .idle
    @Published var currentActivity: Activity = .media

    let services: ServiceProvider
    private let order: [Activity] = [.media, .calendar, .fileTray, .bluetooth]

    init(services: ServiceProvider) {
        self.services = services
        currentActivity = enabledActivities.first ?? .media
    }

    var enabledActivities: [Activity] {
        let enabled = services.preferencesManager.preferences.enabledActivities
        let filtered = order.filter { enabled.contains($0) }
        return filtered.isEmpty ? order : filtered
    }

    var isOpen: Bool { state == .open }

    // MARK: - Hover (reveal / conceal)

    func hoverBegan() {
        if state == .idle { state = .hover }
    }

    func hoverEnded() {
        // Only a peeking notch retracts; an opened panel stays open.
        if state == .hover { state = .idle }
    }

    // MARK: - Open / close

    func open() {
        state = .open
    }

    func close() {
        state = .idle
    }

    func toggle() {
        state = (state == .open) ? .idle : .open
    }

    // MARK: - Activity navigation

    func switchTo(_ activity: Activity) {
        currentActivity = activity
        if state != .open { state = .open }
    }

    func next() {
        let list = enabledActivities
        guard let index = list.firstIndex(of: currentActivity) else { return }
        currentActivity = list[(index + 1) % list.count]
    }

    func previous() {
        let list = enabledActivities
        guard let index = list.firstIndex(of: currentActivity) else { return }
        currentActivity = list[(index - 1 + list.count) % list.count]
    }
}
