import Foundation

enum ViewState: Equatable {
    case compact
    case expanded(Activity)
    case transitioning

    var isExpanded: Bool {
        if case .expanded = self { return true }
        return false
    }

    var currentActivity: Activity? {
        if case .expanded(let activity) = self { return activity }
        return nil
    }
}
