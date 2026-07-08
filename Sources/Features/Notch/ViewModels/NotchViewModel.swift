import Foundation
import Combine

@MainActor
final class NotchViewModel: ObservableObject {
    enum State: Equatable {
        case closed
        case open
    }

    @Published var state: State = .closed
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

    func toggle() {
        state = (state == .open) ? .closed : .open
    }

    func open() {
        guard state != .open else { return }
        state = .open
    }

    func close() {
        guard state != .closed else { return }
        state = .closed
    }

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
