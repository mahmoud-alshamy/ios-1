import Foundation
import Combine

@MainActor
class MenuBarViewModel: ObservableObject {
    @Published var viewState: ViewState = .compact
    @Published var currentActivity: Activity = .media
    @Published var activitiesOrder: [Activity] = [.media, .calendar, .fileTray, .bluetooth]

    private let services: ServiceProvider
    private var cancellables = Set<AnyCancellable>()

    init(services: ServiceProvider) {
        self.services = services
    }

    func toggleExpanded() {
        switch viewState {
        case .compact:
            viewState = .expanded(.media)
            Logger.log("Expanding panel", category: "MenuBar")
        case .expanded:
            viewState = .compact
            Logger.log("Collapsing panel", category: "MenuBar")
        case .transitioning:
            break
        }
    }

    func switchActivity(to activity: Activity) {
        guard case .expanded = viewState else { return }
        viewState = .transitioning
        Logger.log("Switching to activity: \(activity.displayName)", category: "MenuBar")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.currentActivity = activity
            self.viewState = .expanded(activity)
        }
    }

    func nextActivity() {
        guard let currentIndex = activitiesOrder.firstIndex(of: currentActivity) else { return }
        let nextIndex = (currentIndex + 1) % activitiesOrder.count
        switchActivity(to: activitiesOrder[nextIndex])
    }

    func previousActivity() {
        guard let currentIndex = activitiesOrder.firstIndex(of: currentActivity) else { return }
        let previousIndex = currentIndex == 0 ? activitiesOrder.count - 1 : currentIndex - 1
        switchActivity(to: activitiesOrder[previousIndex])
    }

    var enabledActivities: [Activity] {
        activitiesOrder.filter { services.preferencesManager.preferences.enabledActivities.contains($0) }
    }
}
