import Foundation
import Combine

@MainActor
class ActivityManager: ObservableObject {
    @Published var currentActivity: Activity = .media
    @Published var isAnimating = false

    private let preferences: PreferencesManager

    init(preferences: PreferencesManager) {
        self.preferences = preferences
        self.currentActivity = .media
    }

    func switchToActivity(_ activity: Activity) {
        guard !isAnimating else { return }
        guard preferences.preferences.enabledActivities.contains(activity) else { return }

        isAnimating = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.currentActivity = activity
            self.isAnimating = false
        }

        Logger.log("Switched to activity: \(activity.displayName)", category: "ActivityManager")
    }

    func nextActivity(from activities: [Activity]) {
        guard let currentIndex = activities.firstIndex(of: currentActivity) else { return }
        let nextIndex = (currentIndex + 1) % activities.count
        switchToActivity(activities[nextIndex])
    }

    func previousActivity(from activities: [Activity]) {
        guard let currentIndex = activities.firstIndex(of: currentActivity) else { return }
        let previousIndex = currentIndex == 0 ? activities.count - 1 : currentIndex - 1
        switchToActivity(activities[previousIndex])
    }

    var enabledActivities: [Activity] {
        Activity.allCases.filter { 
            preferences.preferences.enabledActivities.contains($0)
        }
    }
}
