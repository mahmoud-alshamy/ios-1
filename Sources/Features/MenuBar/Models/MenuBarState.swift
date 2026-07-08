import Foundation

struct MenuBarState {
    var viewState: ViewState = .compact
    var currentActivity: Activity = .media
    var activitiesOrder: [Activity] = [.media, .calendar, .fileTray, .bluetooth]
}
